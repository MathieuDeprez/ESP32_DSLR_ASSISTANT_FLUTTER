import 'package:flutter/cupertino.dart';

class HdrModel with ChangeNotifier {
  int _hdrNumber = 3;
  String _hdrOffset = "0";
  double _hdrPas = 1;

  int get hdrNumber => _hdrNumber;

  set hdrNumber(int value) {
    _hdrNumber = value;
    notifyListeners();
  }

  String get hdrOffset => _hdrOffset;

  set hdrOffset(String value) {
    _hdrOffset = value;
    notifyListeners();
  }

  double get hdrPas => _hdrPas;

  set hdrPas(double value) {
    _hdrPas = value;
    notifyListeners();
  }
}
