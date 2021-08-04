import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';

class ObjectHandlesModel {
  String handle = "";
  String name = "";
  String time = "";
  int thumb = 0;
  Uint8List image;
  double percent = 0;

  ObjectHandlesModel(String handle, String name, String time, int thumb,
      Uint8List image, double percent) {
    this.handle = handle;
    this.name = name;
    this.time = time;
    this.thumb = thumb;
    this.image = image;
    this.percent = percent;
  }
}
