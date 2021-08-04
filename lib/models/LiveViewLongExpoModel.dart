import 'package:flutter/cupertino.dart';

class LiveViewLongExpoModel with ChangeNotifier {
  double _xPosition = 0;
  double _yPosition = 0;
  int _timer = 3000;
  bool _lvEnable = false;
  bool _timelapseEnabled = false;

  double get xPosition => _xPosition;
  double get yPosition => _yPosition;

  set xPosition(double value) {
    _xPosition = value;
    notifyListeners();
  }

  set yPosition(double value) {
    _yPosition = value;
    notifyListeners();
  }

  int get timer => _timer;
  set timer(int number) {
    _timer = number;
    notifyListeners();
  }

  bool get lvEnable => _lvEnable;
  set lvEnable(bool value) {
    _lvEnable = value;
    print("lv: $_lvEnable");
    notifyListeners();
  }

  bool get timelapseEnabled => _timelapseEnabled;
  set timelapseEnabled(bool value) {
    _timelapseEnabled = value;
    print("timeLapse: $_timelapseEnabled");
    notifyListeners();
  }
}
