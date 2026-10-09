#include "exam_ocr_channel.h"
#include <winrt/Windows.Foundation.h>
#include <winrt/Windows.Foundation.Collections.h>
#include <winrt/Windows.Globalization.h>
#include <winrt/Windows.Graphics.Imaging.h>
#include <winrt/Windows.Media.Ocr.h>
#include <winrt/Windows.Storage.h>
#include <winrt/Windows.Storage.Streams.h>
#include <algorithm>
#include <cmath>
#include <mutex>
#include <string>
#include <stdexcept>
#include <thread>

using flutter::EncodableList;
using flutter::EncodableMap;
using flutter::EncodableValue;

struct ExamOcrChannel::State {
  std::mutex mutex;
  HWND window = nullptr;
  bool closed = false;
  std::unique_ptr<flutter::MethodResult<EncodableValue>> result;
  EncodableList words;
  std::string error;
};

ExamOcrChannel::ExamOcrChannel(flutter::BinaryMessenger* messenger, HWND window)
    : state_(std::make_shared<State>()),
      channel_(std::make_unique<flutter::MethodChannel<EncodableValue>>(
          messenger, "trackmystudy/exam_ocr", &flutter::StandardMethodCodec::GetInstance())) {
  state_->window = window;
  channel_->SetMethodCallHandler([state = state_](const auto& call, auto result) {
    if (call.method_name() != "recognize") { result->NotImplemented(); return; }
    const auto* path = std::get_if<std::string>(call.arguments());
    if (!path || path->empty()) { result->Error("invalid_image", "Choose an image file."); return; }
    {
      std::lock_guard<std::mutex> lock(state->mutex);
      if (state->result) { result->Error("busy", "An image is already being processed."); return; }
      state->result = std::move(result);
    }
    try {
      std::thread([state, image_path = *path]() {
        EncodableList words;
        std::string error;
        try {
          winrt::init_apartment(winrt::apartment_type::multi_threaded);
          struct ApartmentScope { ~ApartmentScope() { winrt::uninit_apartment(); } } apartment_scope;
          {
            using namespace winrt::Windows;
            Media::Ocr::OcrEngine engine{nullptr};
            for (const auto& language : Media::Ocr::OcrEngine::AvailableRecognizerLanguages()) {
              if (winrt::to_string(language.LanguageTag()).rfind("en", 0) == 0) {
                engine = Media::Ocr::OcrEngine::TryCreateFromLanguage(language);
                if (engine) break;
              }
            }
            if (!engine) throw std::runtime_error("English OCR is not installed. In Windows Settings, add English language OCR under Language options, then try again.");
            auto file = Storage::StorageFile::GetFileFromPathAsync(winrt::to_hstring(image_path)).get();
            auto stream = file.OpenAsync(Storage::FileAccessMode::Read).get();
            auto decoder = Graphics::Imaging::BitmapDecoder::CreateAsync(stream).get();
            const auto width = decoder.OrientedPixelWidth();
            const auto height = decoder.OrientedPixelHeight();
            if (!width || !height || static_cast<uint64_t>(width) * height > 60000000) throw std::runtime_error("The image is too large. Use an image under 60 megapixels.");
            const auto limit = Media::Ocr::OcrEngine::MaxImageDimension();
            const double scale = std::min(3.0, static_cast<double>(limit) / width);
            const auto scaled_width = static_cast<uint32_t>(std::floor(width * scale));
            const auto scaled_height = static_cast<uint32_t>(std::floor(height * scale));
            const uint32_t overlap = std::min<uint32_t>(128, limit / 4);
            for (uint32_t top = 0; top < scaled_height;) {
              { std::lock_guard<std::mutex> lock(state->mutex); if (state->closed) break; }
              const auto tile_height = std::min(limit, scaled_height - top);
              Graphics::Imaging::BitmapTransform transform;
              transform.ScaledWidth(static_cast<uint32_t>(std::floor(decoder.PixelWidth() * scale)));
              transform.ScaledHeight(static_cast<uint32_t>(std::floor(decoder.PixelHeight() * scale)));
              transform.Bounds(Graphics::Imaging::BitmapBounds{0, top, scaled_width, tile_height});
              auto bitmap = decoder.GetSoftwareBitmapAsync(
                  Graphics::Imaging::BitmapPixelFormat::Gray8,
                  Graphics::Imaging::BitmapAlphaMode::Ignore, transform,
                  Graphics::Imaging::ExifOrientationMode::RespectExifOrientation,
                  Graphics::Imaging::ColorManagementMode::DoNotColorManage).get();
              auto recognition = engine.RecognizeAsync(bitmap).get();
              for (const auto& line : recognition.Lines()) {
                for (const auto& word : line.Words()) {
                  const auto rect = word.BoundingRect();
                  words.emplace_back(EncodableMap{
                    {EncodableValue("text"), EncodableValue(winrt::to_string(word.Text()))},
                    {EncodableValue("left"), EncodableValue(rect.X / scale)},
                    {EncodableValue("top"), EncodableValue((static_cast<double>(rect.Y) + top) / scale)},
                    {EncodableValue("width"), EncodableValue(rect.Width / scale)},
                    {EncodableValue("height"), EncodableValue(rect.Height / scale)}
                  });
                }
              }
              bitmap.Close();
              if (top + tile_height >= scaled_height) break;
              top += tile_height - overlap;
            }
            stream.Close();
          }
        } catch (const winrt::hresult_error& exception) {
          error = winrt::to_string(exception.message());
        } catch (const std::exception& exception) { error = exception.what(); }
        std::lock_guard<std::mutex> lock(state->mutex);
        if (state->closed) return;
        state->words = std::move(words);
        state->error = std::move(error);
        PostMessage(state->window, kCompleted, 0, 0);
      }).detach();
    } catch (const std::exception& exception) {
      std::lock_guard<std::mutex> lock(state->mutex);
      state->result->Error("ocr_failed", exception.what());
      state->result.reset();
    }
  });
}

ExamOcrChannel::~ExamOcrChannel() {
  channel_->SetMethodCallHandler(nullptr);
  std::lock_guard<std::mutex> lock(state_->mutex);
  state_->closed = true;
  state_->result.reset();
}

bool ExamOcrChannel::HandleMessage(UINT message) {
  if (message != kCompleted) return false;
  std::unique_ptr<flutter::MethodResult<EncodableValue>> result;
  EncodableList words;
  std::string error;
  {
    std::lock_guard<std::mutex> lock(state_->mutex);
    result = std::move(state_->result);
    words = std::move(state_->words);
    error = std::move(state_->error);
  }
  if (result) {
    if (error.empty()) result->Success(EncodableValue(std::move(words)));
    else result->Error("ocr_failed", error);
  }
  return true;
}
