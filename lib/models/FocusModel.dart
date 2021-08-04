import 'package:flutter/cupertino.dart';

class FocusModel with ChangeNotifier {
  String _filterMode = "Aucun";
  String _filterType = "Sobel";

  String get filterMode => _filterMode;

  set filterMode(String value) {
    _filterMode = value;
    print("filterMode: $_filterMode");
    notifyListeners();
  }

  String get filterType => _filterType;

  set filterType(String value) {
    _filterType = value;
    print("filterType: $_filterType");
    notifyListeners();
  }
}
