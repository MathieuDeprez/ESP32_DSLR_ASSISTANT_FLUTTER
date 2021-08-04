import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:esp32_dslr_assistant_flutter/Constants/MyColor.dart';
import 'package:image/image.dart' as Ima;
import 'package:opencv/opencv.dart';

class LiveViewProvider with ChangeNotifier {
  Color _liveviewColor = mySecondColor;
  int _lastMillisImageReceived = DateTime.now().millisecondsSinceEpoch;

  bool _sobel = false;
  bool _laplacian = false;
  bool _fullMode = false;
  bool _overlayMode = false;

  int blurNumberTaken = 0;

  Uint8List _imageData;
  String _fpsText = "99ms";
  Ima.Image maskLaplacianRealTime; //black image with color dots when rough
  Ima.Image maskLaplacianFix;

  LiveViewProvider() {
    loadAsset();
  }

  int get lastMillisImageReceived => _lastMillisImageReceived;

  void loadAsset() async {
    print('LoadAsset Start');
    Uint8List _imageData =
        (await rootBundle.load('assets/images/imageLVdefault.jpg'))
            .buffer
            .asUint8List();
    this._imageData = _imageData;
    notifyListeners();
  }

  bool get fullMode => _fullMode;
  set fullMode(bool state) {
    _fullMode = state;
    if (state && _overlayMode) _overlayMode = false;
  }

  bool get overlayMode => _overlayMode;
  set overlayMode(bool state) {
    _overlayMode = state;
    if (state && _fullMode) _fullMode = false;
  }

  bool get sobel => _sobel;

  set sobel(bool state) {
    _sobel = state;
    if (state && _laplacian) _laplacian = false;

    print("sobel: $sobel");
    print("laplacian: $laplacian");
    notifyListeners();
  }

  bool get laplacian => _laplacian;

  set laplacian(bool state) {
    _laplacian = state;
    if (state && _sobel) _sobel = false;
    print("sobel: $sobel");
    print("laplacian: $laplacian");
    notifyListeners();
  }

  Uint8List get imageData => _imageData;

  set imageData(Uint8List list) {
    _imageData = list;
    notifyListeners();
  }

  String get fpsText => _fpsText;

  set fpsText(String fpsText) {
    print("set fps: " + fpsText);
    _fpsText = fpsText.toString();
    notifyListeners();
  }

  Color get colorLv => _liveviewColor;

  set colorLv(Color color) {
    _liveviewColor = color;
    notifyListeners();
  }

  Future<void> updateImage(Uint8List imageSource) async {
    if (_sobel && _overlayMode) {
      _imageData = sobelConverter(imageSource);
    } else if (_laplacian && _overlayMode) {
      _imageData = await laplacianConverter(imageSource);
    } else if (_sobel && _fullMode) {
      _imageData = fullSobelConverter(imageSource);
    } else if (_laplacian && _fullMode) {
      _imageData = await fullLaplacianConverter(imageSource);
    } else {
      _imageData = imageSource;
    }
    notifyListeners();
  }

  Future<Uint8List> laplacianConverter(Uint8List imageList) async {
    Uint8List firstList = await ImgProc.laplacian(imageList, 10); //laplacian
    Uint8List secondList =
        await ImgProc.dilate(firstList, [2, 2]); //laplcian agrandi

    Ima.Image _imageDateBase = Ima.decodeImage(imageList.buffer.asUint8List());
    Ima.Image _imageDateLaplacian =
        Ima.decodeImage(secondList.buffer.asUint8List());

    if (_imageDateLaplacian != null) {
      if (maskLaplacianRealTime == null) {
        maskLaplacianRealTime =
            Ima.Image(_imageDateLaplacian.width, _imageDateLaplacian.height);
      }
      if (maskLaplacianFix == null) {
        maskLaplacianFix =
            Ima.Image(_imageDateLaplacian.width, _imageDateLaplacian.height);
      }

      for (int i = 0; i < _imageDateLaplacian.length; i++) {
        int R = (_imageDateLaplacian[i] & 0x00FF0000) >> 16;
        int G = (_imageDateLaplacian[i] & 0x0000FF00) >> 8;
        int B = _imageDateLaplacian[i] & 0x000000FF;

        if (R + G + B < 200) {
          maskLaplacianRealTime[i] = 0xFF000000;
        } else {
          maskLaplacianRealTime[i] = 0xFF0000FF;
        }
      }

      Ima.Image _imageDataBlur =
          new Ima.Image(_imageDateBase.width, _imageDateBase.height);

      for (int i = 0; i < _imageDataBlur.length; i++) {
        _imageDataBlur[i] =
            maskLaplacianRealTime[i] | _imageDateBase[i] | maskLaplacianFix[i];
      }
      return Ima.encodeJpg(_imageDataBlur);
    } else {
      Ima.Image _imageDataBlur =
          new Ima.Image(_imageDateBase.width, _imageDateBase.height);
      for (int i = 0; i < _imageDataBlur.length; i++) {
        _imageDataBlur[i] = _imageDateBase[i] | maskLaplacianFix[i];
      }
      return Ima.encodeJpg(_imageDataBlur);
    }
  }

  Future<Uint8List> fullLaplacianConverter(Uint8List imageList) async {
    Uint8List firstList = await ImgProc.laplacian(imageList, 10);
    Uint8List secondList = await ImgProc.dilate(firstList, [2, 2]);
    Ima.Image _imageDateLaplacian =
        Ima.decodeImage(secondList.buffer.asUint8List());

    return Ima.encodeJpg(_imageDateLaplacian);
  }

  Future<void> addBlurMask() async {
    blurNumberTaken++;
    for (int i = 0; i < maskLaplacianRealTime.length; i++) {
      int factor = (blurNumberTaken + 1) * blurNumberTaken;

      HSVColor myHsvPixel = HSVColor.fromColor(Color(maskLaplacianRealTime[i]));
      HSVColor myFuturHsv = HSVColor.fromAHSV(myHsvPixel.alpha,
          myHsvPixel.hue / factor, myHsvPixel.saturation, myHsvPixel.value);
      Color myFuturColor = myFuturHsv.toColor();

      double factorFix = blurNumberTaken / (blurNumberTaken - 1);
      HSVColor myHsvPixelFix = HSVColor.fromColor(Color(maskLaplacianFix[i]));
      HSVColor myFuturHsvFix = HSVColor.fromAHSV(
          myHsvPixelFix.alpha,
          myHsvPixelFix.hue / factorFix,
          myHsvPixelFix.saturation,
          myHsvPixelFix.value);
      Color myFuturColorFix = myFuturHsvFix.toColor();

      if (myHsvPixel.value != 0) {
        maskLaplacianFix[i] = myFuturColor.value;
      } else {
        maskLaplacianFix[i] = myFuturColorFix.value;
      }
    }
  }

  Uint8List fullSobelConverter(Uint8List imageList) {
    Ima.Image _imageDataImage = Ima.decodeImage(imageList.buffer.asUint8List());
    Ima.Image _sobelImage = Ima.sobel(_imageDataImage, amount: 0.8);
    return Ima.encodeJpg(_sobelImage);
  }

  Uint8List sobelConverter(Uint8List imageList) {
    Ima.Image _imageDataImage = Ima.decodeImage(imageList.buffer.asUint8List());
    Ima.Image _imageDateBase = Ima.decodeImage(imageList.buffer.asUint8List());

    Ima.Image _sobelImage = Ima.sobel(_imageDataImage, amount: 0.8);

    Ima.Image _imageDataBlur =
        new Ima.Image(_imageDataImage.width, _imageDataImage.height);
    for (int i = 0; i < _imageDataBlur.length; i++) {
      int R = (_sobelImage[i] & 0x00FF0000) >> 16;
      int G = (_sobelImage[i] & 0x0000FF00) >> 8;
      int B = _sobelImage[i] & 0x000000FF;

      if (R + G + B < 500) {
        _imageDataBlur[i] = _imageDateBase[i];
      } else {
        _imageDataBlur[i] = 0xFF0000FF;
      }
    }

    return Ima.encodeJpg(_imageDataBlur);
  }

  void updateFps() {
    int timeLatence =
        DateTime.now().millisecondsSinceEpoch - _lastMillisImageReceived;
    _fpsText = timeLatence.toString() + "ms";
    notifyListeners();
    _lastMillisImageReceived = DateTime.now().millisecondsSinceEpoch;
  }
}
