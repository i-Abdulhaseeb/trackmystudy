# Bundled OCR runtime

The files in this folder are unmodified third-party binaries and model data, distributed with their license notices.

- Tesseract 5.2.0 Windows x64 executable and DLL; Leptonica 1.82.0 DLL: https://github.com/charlesw/tesseract/tree/b5329d5be92fa670031d94c3875f879651a01f55/src/Tesseract/x64
- Tesseract upstream: https://github.com/tesseract-ocr/tesseract/tree/5.2.0 (Apache-2.0).
- Leptonica upstream: https://github.com/DanBloomberg/leptonica/tree/1.82.0 (BSD-style license).
- English recognition model: https://github.com/tesseract-ocr/tessdata_fast/blob/4.1.0/eng.traineddata (Apache-2.0).
- Included image codec notices cover libjpeg-turbo/IJG, libpng, zlib, libtiff, libwebp, and OpenJPEG. See the licenses directory.

The fallback passes a Flutter-decoded PNG to Tesseract. It runs without a command shell, uses a private temporary directory, and deletes its working image and model copy after recognition. No image or recognized text is sent to a server. The Microsoft Visual C++ 2019 or later x64 runtime is required, as it is for the Flutter Windows application itself.

Keep this folder and its license notices together when distributing the Windows application. The supplied binaries target Windows x64.
