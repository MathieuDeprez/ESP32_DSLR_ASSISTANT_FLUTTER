import 'dart:typed_data';

import 'package:esp32_dslr_assistant_flutter/models/ObjectHandlesModel.dart';
import 'package:flutter/cupertino.dart';

class BrowserModel with ChangeNotifier {
  List<ObjectHandlesModel> _myHandlesList = [];

  String _handleDownloading = "";
  bool _downloadingList = false;

  String _path = "/Pictures/DslrAssistant/";
  String pathKey = "pathKeyStorage";

  String get path => _path;
  set path(String path) {
    _path = path;
    notifyListeners();
  }

  set downloadingList(bool state) {
    _downloadingList = state;
  }

  bool get downloadingList => _downloadingList;

  String get handleDownloading => _handleDownloading;

  set handleDownloading(String handle) {
    _handleDownloading = handle;
  }

  ObjectHandlesModel getHandleDownloadingObject() {
    for (var handleObject in _myHandlesList) {
      if (handleObject.handle == _handleDownloading) {
        return handleObject;
      }
    }
  }

  List<ObjectHandlesModel> get myHandlesList => _myHandlesList;

  set myHandlesList(List<ObjectHandlesModel> myList) {
    _myHandlesList = myList;
    notifyListeners();
  }

  void endObjectHandleList() {
    _downloadingList = false;
    notifyListeners();
  }

  void addHandle(ObjectHandlesModel handle) {
    _myHandlesList.add(handle);
    //notifyListeners();
  }

  void emptyHandle() {
    _myHandlesList = [];
    notifyListeners();
  }

  void displayJpeg(String handle) {
    for (var handleObject in _myHandlesList) {
      if (handleObject.handle == handle) {
        handleObject.thumb = 2;
        _handleDownloading = handle;
        break;
      }
    }
    notifyListeners();
  }

  void displayJpegHq(String handle) {
    for (var handleObject in _myHandlesList) {
      if (handleObject.handle == handle) {
        handleObject.thumb = 3;
        _handleDownloading = handle;
        break;
      }
    }
    notifyListeners();
  }

  void JpegDownloaded() {
    for (var handleObject in _myHandlesList) {
      if (handleObject.handle == _handleDownloading) {
        handleObject.thumb = 0;
        break;
      }
    }
    notifyListeners();
  }

  void displayThumb(String handle) {
    for (var handleObject in _myHandlesList) {
      if (handleObject.handle == handle) {
        handleObject.thumb = 1;
        break;
      }
    }
    notifyListeners();
  }

  void addImage(Uint8List image) {
    for (var handleObject in _myHandlesList) {
      if (handleObject.handle == _handleDownloading) {
        handleObject.image = image;
        break;
      }
    }
    notifyListeners();
  }

  void addPercent(double percent) {
    for (var handleObject in _myHandlesList) {
      if (handleObject.handle == _handleDownloading) {
        handleObject.percent = percent;
        break;
      }
    }
    notifyListeners();
  }

  Uint8List getThumbnail(String handle) {
    for (var handleObject in _myHandlesList) {
      if (handleObject.handle == handle) {
        return handleObject.image;
      }
    }
  }
}
