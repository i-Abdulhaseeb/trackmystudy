#ifndef RUNNER_EXAM_OCR_CHANNEL_H_
#define RUNNER_EXAM_OCR_CHANNEL_H_
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>
#include <memory>

class ExamOcrChannel {
 public:
  ExamOcrChannel(flutter::BinaryMessenger* messenger, HWND window);
  ~ExamOcrChannel();
  bool HandleMessage(UINT message);
 private:
  struct State;
  static constexpr UINT kCompleted = WM_APP + 317;
  std::shared_ptr<State> state_;
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel_;
};
#endif
