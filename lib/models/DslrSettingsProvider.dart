import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:esp32_dslr_assistant_flutter/Constants/MyColor.dart';
import 'package:esp32_dslr_assistant_flutter/Constants/MyLists.dart';
import 'package:esp32_dslr_assistant_flutter/models/BluetoothProvider.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import '../ItemList.dart';

class DslrSettingsProvider extends ChangeNotifier {
  BluetoothDevice _myDevice;

  BluetoothDevice get myDevice => _myDevice;

  set myDevice(BluetoothDevice device) {
    _myDevice = device;
    notifyListeners();
  }
  /*BluetoothProvider _bluetoothProvider;

  BluetoothProvider get bluetooth => _bluetoothProvider;

  set bluetooth(BluetoothProvider newBluetooth) {
    _bluetoothProvider = newBluetooth;
    // Notify listeners, in case the new catalog provides information
    // different from the previous one. For example, availability of an item
    // might have changed.
    notifyListeners();
  }*/

  void notify() {
    notifyListeners();
  }

  SettingModel _apertureObject = new SettingModel(apertureColor,
      selectedAperture, apertureList, prefixAperture, titleAperture);
  SettingModel _shutterObject = new SettingModel(
      shutterColor, selectedShutter, shutterList, prefixShutter, titleShutter);
  SettingModel _isoObject =
      new SettingModel(isoColor, selectedIso, isoList, prefixIso, titleIso);
  SettingModel _expoObject = new SettingModel(
      expoColor, selectedExpo, expoList, prefixExpo, titleExpo);

  SettingModel get apertureObject => _apertureObject;
  SettingModel get shutterObject => _shutterObject;
  SettingModel get isoObject => _isoObject;
  SettingModel get expoObject => _expoObject;

  DslrSettingsProvider() {}

  Color _colorFocus = mySecondColor;
  String _priorityMode = "Unknown";

  int _afX = 0;
  int _afY = 0;

  int _count = 1;

  int _longExposureTime = 60;

  int get longExposureTime => _longExposureTime;

  set longExposureTime(int value) {
    _longExposureTime = value;
    notifyListeners();
  }

  String get priorityMode => _priorityMode;

  set priorityMode(String mode) {
    _priorityMode = mode;
    notifyListeners();
  }

  int get afX => _afX;

  set afX(int afX) {
    _afX = afX;
    //notifyListeners();
  }

  int get afY => _afY;

  set afY(int afY) {
    _afY = afY;
    //notifyListeners();
  }

  int get count => _count;

  set count(int count) {
    _count = count;
    notifyListeners();
  }

  Color get colorFocus => _colorFocus;

  set colorFocus(Color color) {
    _colorFocus = color;
    notifyListeners();
  }

  void increment() {
    _count++;
    notifyListeners();
  }

  //GroupItemListClass get gilc => _gilc;

  void setShutterSpeed(int value) {
    print("setShutterSpeed: $value");
    if (value == 0x59) {
      print("Success"); //0x59 == 'Y'
      _shutterObject.color = myMainColor;
    } else if (value == 0x4E) {
      print("Fail"); // 0x4E == 'N'
      _shutterObject.color = mySecondColorAccent;
    } else {
      _shutterObject.selectedValue = _shutterObject.listValue[value];
      _shutterObject.color = myMainColor;
    }
    notifyListeners();
  }

  void setIso(int value) {
    if (value == 0x59) {
      print("Success"); //0x59 == 'Y'
      _isoObject.color = myMainColor;
    } else if (value == 0x4E) {
      print("Fail"); // 0x4E == 'N'
      _isoObject.color = mySecondColorAccent;
    } else {
      _isoObject.selectedValue = _isoObject.listValue[value];
      _isoObject.color = myMainColor;
    }
    notifyListeners();
  }

  void setAperture(int value) {
    if (value == 0x59) {
      print("Success"); //0x59 == 'Y'
      _apertureObject.color = myMainColor;
    } else if (value == 0x4E) {
      print("Fail"); // 0x4E == 'N'
      _apertureObject.color = mySecondColorAccent;
    } else {
      _apertureObject.selectedValue = _apertureObject.listValue[value];
      _apertureObject.color = myMainColor;
    }
    notifyListeners();
  }

  void setExpoBias(int value) {
    if (value == 0x59) {
      print("Success"); //0x59 == 'Y'
      _expoObject.color = myMainColor;
    } else if (value == 0x4E) {
      print("Fail"); // 0x4E == 'N'
      _expoObject.color = mySecondColorAccent;
    } else {
      _expoObject.selectedValue = _expoObject.listValue[value];
      _expoObject.color = myMainColor;
    }
    notifyListeners();
  }

  void setAf(int value) {
    if (value == 0x59) {
      print("Success"); //0x59 == 'Y'
      _colorFocus = myMainColor;
    } else if (value == 0x4E) {
      print("Fail"); // 0x4E == 'N'
      _colorFocus = mySecondColorAccent;
    } else {
      print(value);
    }
    notifyListeners();
  }
}

class SettingModel {
  Color color;
  String selectedValue;
  List<String> listValue;
  String prefix;
  String title;

  SettingModel(Color color, String selectedValue, List<String> listValue,
      String prefix, String title) {
    this.color = color;
    this.selectedValue = selectedValue;
    this.listValue = listValue;
    this.prefix = prefix;
    this.title = title;
  }
}
