import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:esp32_dslr_assistant_flutter/models/BrowserModel.dart';
import 'package:esp32_dslr_assistant_flutter/models/ObjectHandlesModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:esp32_dslr_assistant_flutter/Constants/MyColor.dart';
import 'package:esp32_dslr_assistant_flutter/models/DslrSettingsProvider.dart';
import 'package:esp32_dslr_assistant_flutter/models/LiveViewProvider.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:opencv/opencv.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ext_storage/ext_storage.dart';

import '../BluetoothUtils.dart';
import '../SelectBondedDevicePage.dart';
import 'package:image/image.dart' as Ima;

class BluetoothProvider with ChangeNotifier {
  DslrSettingsProvider _dslrSettingsProvider;
  LiveViewProvider _liveViewProvider;
  BrowserModel _browserModel;

  DslrSettingsProvider get dslrSettings => _dslrSettingsProvider;
  LiveViewProvider get liveViewProvider => _liveViewProvider;
  BrowserModel get browserModel => _browserModel;

  set dslrSettings(DslrSettingsProvider newDslrSettings) {
    _dslrSettingsProvider = newDslrSettings;
    notifyListeners();
  }

  set liveViewProvider(LiveViewProvider newLiveViewProvider) {
    _liveViewProvider = newLiveViewProvider;
    notifyListeners();
  }

  set browserModel(BrowserModel newbrowserModel) {
    _browserModel = newbrowserModel;
    notifyListeners();
  }

  BluetoothConnection _connection;
  bool isConnecting = true;
  bool get isConnected => _connection != null && _connection.isConnected;
  bool isDisconnecting = false;
  bool _lvEnable = false;

  Color _bluetoothColor = mySecondColor;

  var downloadingImage = false;
  //1: LV, 2:Thumbnail
  int imageTypeArriving = 0;
  String handleDownloading = "";
  var timerDownloadImage = 0;
  List<int> wholeMessageHex = [];

  Color get color => _bluetoothColor;

  set color(Color color) {
    _bluetoothColor = color;
    notifyListeners();
  }

  BluetoothConnection get connexion => _connection;

  bool get lvEnable => _lvEnable;

  set lvEnable(bool enable) {
    _lvEnable = enable;
    notifyListeners();
  }

  int _tryRecoBlt = 0;

  Future<void> bluetoothConnexion(BuildContext context) async {
    if (_connection != null && _connection.isConnected) {
      print("Deconnexion");
      _tryRecoBlt = 0;
      _connection.close();
      _lvEnable = false;
      _dslrSettingsProvider.setAperture(0x4E);
      _dslrSettingsProvider.setExpoBias(0x4E);
      _dslrSettingsProvider.setIso(0x4E);
      _dslrSettingsProvider.setShutterSpeed(0x4E);
    } else {
      final BluetoothDevice selectedDevice = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return SelectBondedDevicePage(checkAvailability: false);
          },
        ),
      );

      if (selectedDevice != null) {
        _dslrSettingsProvider.myDevice = selectedDevice;
        print('Connect -> selected ' + selectedDevice.address);
        await connectToBluetooth(selectedDevice);
      } else {
        print('Connect -> no device selected');
      }
    }
  }

  Future<void> connectToBluetooth(BluetoothDevice server) async {
    /*try {
      BluetoothConnection connection =
          await BluetoothConnection.toAddress(server.address)
              .catchError((error) {
        print("error2 $error");
      });
      print('Connected to the device');
      connection.input.listen((Uint8List data) {
        print('Data incoming: ${ascii.decode(data)}');
        connection.output.add(data); // Sending data
        if (ascii.decode(data).contains('!')) {
          connection.finish(); // Closing connection
          print('Disconnecting by local host');
        }
      }).onDone(() {
        print('Disconnected by remote request');
      });
    } catch (exception) {
      print('Cannot connect, exception occured');
    }*/

    /*try {
      BluetoothConnection connection =
          await BluetoothConnection.toAddress(server.address)
              .onError((error, stackTrace) {
        print("error $error");
        return;
      });
      _lvEnable = false;
      _bluetoothColor = myMainColor;
      this._connection = connection;
      isConnecting = false;
      isDisconnecting = false;
      notifyListeners();
      print('Connected to the device');

      connection.input.listen(_onDataReceived).onDone(() {
        print('Disconnected by remote request');
        _bluetoothColor = mySecondColor;
        notifyListeners();

        print('reconnexion try -> selected ' +
            _dslrSettingsProvider.myDevice.address);

        if (_tryRecoBlt > 0) {
          _tryRecoBlt -= 1;
          try {
            bluetoothReconnexion();
          } catch (e) {
            print("excpetion connect ble: ${e.toString()}");
          }
        }
      });
      askInfo();
    } catch (exception) {
      print('Cannot connect, exception occured ${exception.toString()}');
    }*/

    BluetoothConnection.toAddress(server.address).then((_connection) {
      print('Connected to the device');
      _tryRecoBlt = 3;
      _lvEnable = false;
      _bluetoothColor = myMainColor;
      this._connection = _connection;
      isConnecting = false;
      isDisconnecting = false;
      notifyListeners();
      this._connection.input.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Disconnecting locally!');
          _bluetoothColor = mySecondColor;
          notifyListeners();
          /*setState(() {
            colorBluetooth = mySecondColor;
            apertureColor = myThirdColor;
            shutterColor = myThirdColor;
            isoColor = myThirdColor;
          });*/
        } else {
          print('Disconnected remotely!');
          _bluetoothColor = mySecondColor;
          notifyListeners();

          print('reconnexion try -> selected ' +
              _dslrSettingsProvider.myDevice.address);

          if (_tryRecoBlt > 0) {
            _tryRecoBlt -= 1;
            try {
              bluetoothReconnexion();
            } catch (e) {
              print("excpetion connect ble: ${e.toString()}");
            }
          }

          /*setState(() {
            colorBluetooth = mySecondColor;
            apertureColor = myThirdColor;
            shutterColor = myThirdColor;
            isoColor = myThirdColor;
          });*/
        }
        /*if (this.mounted) {
          //setState(() {});
        }*/
      });
      askInfo();
    }).catchError((error) {
      print('Cannot connect, exception occured');
      _bluetoothColor = mySecondColor;
      notifyListeners();
      /*setState(() {
        colorBluetooth = mySecondColor;
        apertureColor = myThirdColor;
        shutterColor = myThirdColor;
        isoColor = myThirdColor;
      });*/
      print(error);
    });
  }

  Future<void> bluetoothReconnexion() async {
    await _connection.close();
    await _connection.finish();
    await connectToBluetooth(_dslrSettingsProvider.myDevice);
  }

  void askInfo() {
    List<int> bytesString = utf8.encode("I");
    final bytesBuilder = BytesBuilder();
    for (int i = 0; i < bytesString.length; i++) {
      bytesBuilder.add([
        bytesString[i],
      ]);
    }
    Uint8List byteList = bytesBuilder.toBytes();
    print(byteList); // [42, 0, 5, 255]
    BluetoothUtils.sendByteMessage(byteList, _connection);
  }

  int JPEG_LENGTH = 1;

  void _onDataReceived(Uint8List data) {
    for (int i = 0; i < data.length; i++) {
      if (!downloadingImage && data[i] == 0xFF && data.length - i >= 3) {
        //Nouvel Event
        if (data[i + 1] == 225 && data[i + 2] == 0xFF) {
          print('image arriving !!!');
          imageTypeArriving = 1; //1: LiveViewImage
          timerDownloadImage = DateTime.now().millisecondsSinceEpoch;
        } else if (imageTypeArriving == 1 &&
            !downloadingImage &&
            data[i + 1] == 0xD8 &&
            data[i + 2] == 0xFF) {
          downloadingImage = true;
          print('debut image !!!');
        } else if (data[i + 1] == 220 && data[i + 2] == 0xFF) {
          // AF
          print('Response autoFocus: ');
          if (data.length - i >= 4) {
            _dslrSettingsProvider.setAf(data[i + 3]);
          }
        } else if (data[i + 1] == 219 && data[i + 2] == 0xFF) {
          // Iso
          print('Response iso: ');
          if (data.length - i >= 4) {
            _dslrSettingsProvider.setIso(data[i + 3]);
          }
        } else if (data[i + 1] == 217 && data[i + 2] == 0xFF) {
          // Shutter
          print('Response shutter Speed: ');
          if (data.length - i >= 4) {
            _dslrSettingsProvider.setShutterSpeed(data[i + 3]);
          }
        } else if (data[i + 1] == 218 && data[i + 2] == 0xFF) {
          // Aperture
          print('Response aperture: ');
          if (data.length - i >= 4) {
            _dslrSettingsProvider.setAperture(data[i + 3]);
          }
        } else if (data[i + 1] == 221 && data[i + 2] == 0xFF) {
          // Aperture
          print('Response expoBias: ');
          if (data.length - i >= 4) {
            _dslrSettingsProvider.setExpoBias(data[i + 3]);
          }
        } else if (data[i + 1] == 222 && data[i + 2] == 0xFF) {
          print('Response expo Mod: ');
          List<String> listPriorityModes = [
            "Manual",
            "AutoProg",
            "Aperture",
            "Shutter"
          ];
          _dslrSettingsProvider.priorityMode = listPriorityModes[data[i + 3]];
        } else if (data[i + 1] == 228 && data[i + 2] == 0xFF) {
          print("end object handle list !!!");
          _browserModel.endObjectHandleList();
        } else if (data[i + 1] == 223 &&
            data[i + 2] == 0xFF &&
            data.length - i >= 30) {
          /*int handle = (data[i + 3] << 24) |
              (data[i + 4] << 16) |
              (data[i + 5] << 8) |
              data[i + 6];*/
          String handle = data[i + 6].toRadixString(16).padLeft(2, '0') +
              data[i + 5].toRadixString(16).padLeft(2, '0') +
              data[i + 4].toRadixString(16).padLeft(2, '0') +
              data[i + 3].toRadixString(16).padLeft(2, '0');
          //print("handle: $handle");

          String photoName = utf8.decode(data.sublist(i + 7, i + 19));
          print("photoName: $photoName");

          String photoTime = utf8.decode(data.sublist(i + 19, i + 35));
          //print("photoTime: $photoTime");

          ObjectHandlesModel objectHandlesModel = ObjectHandlesModel(
              handle, photoName, photoTime, 0, Uint8List(0), 0);
          _browserModel.addHandle(objectHandlesModel);
          /*print('handle begin: ');
          for (int m = 0; m < 32; m++) {
            print(data[i + m]);
          }
          print('handle finish');*/
        } else if (data[i + 1] == 224 && data[i + 2] == 0xFF) {
          print("downloading thumbnail !!!");
          imageTypeArriving = 2; //2: ThumbnailImage
        } else if (imageTypeArriving == 2 &&
            !downloadingImage &&
            data[i + 1] == 0xD8 &&
            data[i + 2] == 0xFF) {
          downloadingImage = true;
          print('debut image thumbnail !!!');
        } else if (data[i + 1] == 226 && data[i + 2] == 0xFF) {
          print("downloading jpeg !!!");
          imageTypeArriving = 3; //3: Jpeg
          int jpegLength = data[i + 3] |
              (data[i + 4] << 8) |
              (data[i + 5] << 16) |
              (data[i + 6] << 24);
          print("length jpeg: $jpegLength");
          JPEG_LENGTH = jpegLength;
        } else if (imageTypeArriving == 3 &&
            !downloadingImage &&
            data[i + 1] == 0xD8 &&
            data[i + 2] == 0xFF) {
          downloadingImage = true;
          print('debut image Jpeg !!!');
        } else if (data[i + 1] == 227 && data[i + 2] == 0xFF) {
          print("downloading jpeg Hq !!!");
          imageTypeArriving = 4; //4: Jpeg Hq
          int jpegLength = data[i + 3] |
              (data[i + 4] << 8) |
              (data[i + 5] << 16) |
              (data[i + 6] << 24);
          print("length jpegHq: $jpegLength");
          JPEG_LENGTH = jpegLength;
        } else if (imageTypeArriving == 4 &&
            !downloadingImage &&
            data[i + 1] == 0xD8 &&
            data[i + 2] == 0xFF) {
          downloadingImage = true;
          print('debut image Jpeg Hq !!!');
        }
      }

      if (downloadingImage) {
        wholeMessageHex.add(data[i]);
        if (wholeMessageHex.length % 10000 == 0) {
          double percent = wholeMessageHex.length / JPEG_LENGTH;
          _browserModel.addPercent(percent);
          print("length: $percent");
        }

        //todo add percent download
      }

      if (downloadingImage && i > 0 && data[i - 1] == 0xFF && data[i] == 0xD9) {
        print('fin image !!!: ' + (wholeMessageHex.length).toString());
        downloadingImage = false;

        switch (imageTypeArriving) {
          case 1: //LiveView
            {
              print("timer Download image: " +
                  (DateTime.now().millisecondsSinceEpoch - timerDownloadImage)
                      .toString() +
                  "ms");
              liveViewProvider.updateImage(Uint8List.fromList(wholeMessageHex));
              liveViewProvider.updateFps();
              if (_lvEnable) {
                BluetoothUtils.sendMessage("A", _connection);
              }
            }
            break;
          case 2:
            {
              //ObjectHandlesModel
              print("add image to browserProv");
              //print(Uint8List.fromList(wholeMessageHex));
              _browserModel.addImage(Uint8List.fromList(wholeMessageHex));
            }
            break;
          case 3:
            {
              //ObjectHandlesModel
              print("add image to browserProv");
              //print(Uint8List.fromList(wholeMessageHex));
              //_browserModel.addImage(Uint8List.fromList(wholeMessageHex));
              saveImageToGallery(Uint8List.fromList(wholeMessageHex));
            }
            break;
          case 4:
            {
              //ObjectHandlesModel
              print("add imageHq to browserProv");
              //print(Uint8List.fromList(wholeMessageHex));
              //_browserModel.addImage(Uint8List.fromList(wholeMessageHex));
              saveImageToGallery(Uint8List.fromList(wholeMessageHex));
            }
            break;
          default:
        }
        imageTypeArriving = 0;
        wholeMessageHex = [];
      }
    }

    return;
  }

  _askPermission() async {
    if (Platform.isIOS) {
      //Map<Permission, PermissionStatus> permissions = await PermissionHandler();
    } else {
      PermissionStatus permission = await Permission.storage.request();
      print(permission);
      if (await Permission.storage.request().isGranted) {
        print("permission granted!");
      }
    }
  }

  saveImageToGallery(Uint8List image) async {
    if (Platform.isAndroid) {
      await _askPermission();
    }

    try {
      /*final result = await ImageGallerySaver.saveImage(image);
      print(result);
      _toastInfo(result.toString());*/
      ObjectHandlesModel objectHandlesModel =
          _browserModel.getHandleDownloadingObject();
      String photoName = objectHandlesModel.name;
      String photoTime = objectHandlesModel.time;

      Random random = new Random();
      final directory = (await ExtStorage.getExternalStorageDirectory());
      File imgFile = File('$directory/Pictures/DslrAssistant/' +
          photoName.substring(0, photoName.length - 4) +
          "_" +
          /*photoTime +
          "_" +*/
          random.nextInt(10000).toString() +
          '.jpg');
      print("path: ${imgFile.toString()}");
      _browserModel.JpegDownloaded();
      imgFile.writeAsBytesSync(image);
      _toastInfo("Save in: ${imgFile.toString()}");
    } catch (e) {
      print("excpetion save: ${e.toString()}");
    }
  }

  _toastInfo(String info) {
    Fluttertoast.showToast(msg: info, toastLength: Toast.LENGTH_LONG);
  }

  void cronLv() {
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (_lvEnable) {
        if (DateTime.now().millisecondsSinceEpoch -
                liveViewProvider.lastMillisImageReceived >
            3000) {
          print("cronLv");
          BluetoothUtils.sendMessage("A", _connection);
        }
      }
    });
  }

  void liveViewSwitch() {
    if (_lvEnable) {
      _lvEnable = false;
      print("lvEnable false");
      BluetoothUtils.sendMessage("B", _connection);
      liveViewProvider.colorLv = mySecondColor;
      notifyListeners();
    } else {
      _lvEnable = true;
      print("lvEnable true");
      BluetoothUtils.sendMessage("A", _connection);
      cronLv();
      liveViewProvider.colorLv = myMainColor;
      notifyListeners();
    }
  }

  Uint8List int32BigEndianBytes(int value) =>
      Uint8List(4)..buffer.asByteData().setInt32(0, value, Endian.big);

  void makeAutoFocus() {
    _dslrSettingsProvider.colorFocus = mySecondColor;
    print("makeAF: " +
        _dslrSettingsProvider.afX.toString() +
        ' ' +
        _dslrSettingsProvider.afY.toString());

    Uint8List byteX = int32BigEndianBytes(_dslrSettingsProvider.afX);
    Uint8List byteY = int32BigEndianBytes(_dslrSettingsProvider.afY);
    final bytesBuilder = BytesBuilder();
    bytesBuilder.add([
      utf8.encode("F")[0],
      byteX[0],
      byteX[1],
      byteX[2],
      byteX[3],
      byteY[0],
      byteY[1],
      byteY[2],
      byteY[3]
    ]);
    Uint8List byteList = bytesBuilder.toBytes();
    print(byteList); // [42, 0, 5, 255]

    BluetoothUtils.sendByteMessage(byteList, _connection);
  }

  void focusDslr() {
    Uint8List byteX = int32BigEndianBytes(_dslrSettingsProvider.afX);
    Uint8List byteY = int32BigEndianBytes(_dslrSettingsProvider.afY);
    final bytesBuilder = BytesBuilder();
    bytesBuilder.add([
      utf8.encode("F")[0],
      byteX[0],
      byteX[1],
      byteX[2],
      byteX[3],
      byteY[0],
      byteY[1],
      byteY[2],
      byteY[3]
    ]);
    Uint8List byteList = bytesBuilder.toBytes();
    print(byteList); // [42, 0, 5, 255]

    BluetoothUtils.sendByteMessage(byteList, _connection);
  }
}
