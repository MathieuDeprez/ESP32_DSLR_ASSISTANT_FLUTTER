import 'dart:ffi';

import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_01/BluetoothUtils.dart';
import 'package:flutter_app_01/SelectorWidget.dart';

import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:opencv/core/core.dart';
import 'package:opencv/core/imgproc.dart';

//import 'package:charts_flutter/flutter.dart' as charts;
import './SelectBondedDevicePage.dart';
import 'dart:math';
import "dart:typed_data";
import 'package:flutter_picker/flutter_picker.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:flutter_app_01/ItemList.dart';
import 'Child1Page.dart';
import 'Child2Page.dart';
import 'Child3Page.dart';
import 'Constants/MyColor.dart';
import 'MyBottomBar.dart';
import 'MyBottomBar2.dart';
import 'MyFocusRectangle.dart';
import 'SecondRoute.dart';
import 'SelectorWidget.dart';
import 'package:image/image.dart' as Ima;

class PersoPage extends StatefulWidget {
  //final BluetoothDevice server;
  //const PersoPage({this.server});
  const PersoPage();

  @override
  _PersoPage createState() => new _PersoPage();
}

class _PersoPage extends State<PersoPage> with TickerProviderStateMixin {
  Uint8List imageData; // image from liveview
  Ima.Image maskLaplacianRealTime; //black image with color dots when rough
  Ima.Image maskLaplacianFix;

  BluetoothConnection connection;
  bool isConnecting = true;

  bool get isConnected => connection != null && connection.isConnected;

  bool isDisconnecting = false;

  bool lvEnable = false;
  String fpsText = "99ms";
  int lastMillisImageReceived = DateTime.now().millisecondsSinceEpoch;
  Color colorBluetooth = mySecondColor;
  Color colorFocus = mySecondColor;
  Color colorLiveView = mySecondColor;
  Color colorPeople = mySecondColor;

  bool blurDetectionEnable = false;
  int blurNumberTaken = 0;
  String priorityMode = "Unknown";

  Uint8List hdrByteList;

  GroupItemListClass gilc = new GroupItemListClass();

  @override
  void initState() {
    _controller = TabController(
      length: 3,
      vsync: this,
    );
    super.initState();
    loadAsset(); //

    /*final bytesBuilder = BytesBuilder();
    bytesBuilder.add([
      utf8.encode('H')[0],
    ]);

    //Add number
    bytesBuilder.add([
      int32BigEndianBytes(3)[3],
    ]);

    //Add Pas
    int pasInt = (1 * 10).toInt();
    bytesBuilder.add([
      int32BigEndianBytes(pasInt)[3],
    ]);

    //Add offset
    int offset = expoList.indexOf("0");
    bytesBuilder.add([
      int32BigEndianBytes(offset)[3],
    ]);

    //Add end List
    bytesBuilder.add([
      utf8.encode(";")[0],
    ]);
    hdrByteList = bytesBuilder.toBytes();*/
    print('initState');

    _controller.addListener(_tabListener);

    // setState(() {
    //   topWidget = liveViewWidget();
    // });
  }

  int oldIndex = 0;

  void _tabListener() {
    print("Tab click: " + _controller.index.toString());
    if (_controller.index != oldIndex) {
      if (_controller.index == 2) {
        blurDetectionEnable = true;
      } else if (oldIndex == 2) {
        blurDetectionEnable = false;
      }
      // if(_controller.index==2){
      //   print("hide topWidget");
      //   setState(() {
      //     topWidget=Container();
      //   });
      // } else if(oldIndex ==2){
      //   setState(() {
      //     topWidget=liveViewWidget();
      //   });
      // }
      //
      oldIndex = _controller.index;
    }
  }

  void connectToBluetooth(BluetoothDevice server) {
    BluetoothConnection.toAddress(server.address).then((_connection) {
      print('Connected to the device');
      lvEnable = false;
      setState(() {
        colorBluetooth = myMainColor;
      });
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection.input.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Disconnecting locally!');
          setState(() {
            colorBluetooth = mySecondColor;
            apertureColor = myThirdColor;
            shutterColor = myThirdColor;
            isoColor = myThirdColor;
          });
        } else {
          print('Disconnected remotely!');
          setState(() {
            colorBluetooth = mySecondColor;
            apertureColor = myThirdColor;
            shutterColor = myThirdColor;
            isoColor = myThirdColor;
          });
        }
        if (this.mounted) {
          setState(() {});
        }
      });
      askInfo();
    }).catchError((error) {
      print('Cannot connect, exception occured');
      setState(() {
        colorBluetooth = mySecondColor;
        apertureColor = myThirdColor;
        shutterColor = myThirdColor;
        isoColor = myThirdColor;
      });
      print(error);
    });
  }

  TabController _controller;

  @override
  void dispose() {
    _controller.dispose();
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }


  void loadAsset() async {
    print('LoadAsset Start');
    Uint8List _imageData =
        (await rootBundle.load('assets/images/imageLVdefault.jpg'))
            .buffer
            .asUint8List();
    //setState(() => this.imageData = _imageData);
    await emptyLaplacianMask();
    Ima.Image _imageDateBase = Ima.decodeImage(_imageData.buffer.asUint8List());
    Ima.Image _imageMasked = Ima.Image(_imageDateBase.width, _imageDateBase.height);
    for(int i=0; i<_imageDateBase.length; i++){
      if(maskLaplacianRealTime[i] == 0xFF000000){
        _imageMasked[i] = _imageDateBase[i];
      } else{
        _imageMasked[i] = maskLaplacianRealTime[i];
      }
    }
    setState(() => this.imageData = Ima.encodeJpg(_imageMasked));
    print('LoadAsset End');
    // setState(() {
    //   topWidget = liveViewWidget();
    // });
  }

  Future<void> emptyLaplacianMask() async {
    maskLaplacianRealTime= Ima.Image(640, 424);
    maskLaplacianFix= Ima.Image(640, 424);
    for(int i=0; i<maskLaplacianRealTime.length; i++){
      maskLaplacianRealTime[i] = 0xFF000000;
      maskLaplacianFix[i] = 0xFF000000;
    }
  }



  void updateImage(Uint8List imageList) async {
    if (blurDetectionEnable) {
      Uint8List newImage = await laplacian(imageList);
      setState(() {
        //this.imageData = sobel(imageList);
        this.imageData = newImage;
      });
    } else {
      setState(() {
        this.imageData = imageList;
      });
    }
  }

  Future<Uint8List> laplacian(Uint8List imageList) async {
    Uint8List firstList = await ImgProc.laplacian(imageList, 10);
    Uint8List secondList = await ImgProc.dilate(firstList, [2, 2]);

    Ima.Image _imageDateBase = Ima.decodeImage(imageList.buffer.asUint8List());
    Ima.Image _imageDateLaplacian =
        Ima.decodeImage(secondList.buffer.asUint8List());

    //print(maskLaplacian.width.toString() +" "+ maskLaplacian.height.toString());
    //maskLaplacian = Ima.Image(_imageDateBase.width, _imageDateBase.height);

    if (_imageDateLaplacian != null) {
      print("laplacian: ");
      print(((_imageDateLaplacian[0] & 0x00FF0000) >> 16).toString());
      print(((_imageDateLaplacian[0] & 0x0000FF00) >> 8).toString());
      print((_imageDateLaplacian[0] & 0x000000FF).toString());

      /*Ima.Image _imageDataBlur =
          new Ima.Image(_imageDateBase.width, _imageDateBase.height);*/
      //incrementColorLaplacian();

      for (int i = 0; i < _imageDateLaplacian.length; i++) {
        int R = (_imageDateLaplacian[i] & 0x00FF0000) >> 16;
        int G = (_imageDateLaplacian[i] & 0x0000FF00) >> 8;
        int B = _imageDateLaplacian[i] & 0x000000FF;

        if (R + G + B < 200) {
          maskLaplacianRealTime[i] =  0xFF000000;
        } else {
          maskLaplacianRealTime[i] = 0xFF0000FF;
        }
      }

      Ima.Image _imageDataBlur =
          new Ima.Image(_imageDateBase.width, _imageDateBase.height);
      for (int i = 0; i < _imageDataBlur.length; i++) {
        _imageDataBlur[i] = maskLaplacianRealTime[i] | _imageDateBase[i] | maskLaplacianFix[i];
      }

      return Ima.encodeJpg(_imageDataBlur);
    } else {
      print("NULL ??? " + firstList.length.toString());

      Ima.Image _imageDataBlur =
      new Ima.Image(_imageDateBase.width, _imageDateBase.height);
      for (int i = 0; i < _imageDataBlur.length; i++) {
        _imageDataBlur[i] = _imageDateBase[i] | maskLaplacianFix[i];
      }
      return Ima.encodeJpg(_imageDataBlur);

    }
  }





  Uint8List sobel(Uint8List imageList) {
    Ima.Image _imageDataImage = Ima.decodeImage(imageList.buffer.asUint8List());

    print("len N: " + imageList.length.toString());

    Ima.Image _imageDateBase = Ima.decodeImage(imageList.buffer.asUint8List());

    Ima.Image _sobel = Ima.sobel(_imageDataImage, amount: 0.8);

    print("sobel: ");
    print(((_sobel[0] & 0x00FF0000) >> 16).toString());
    print(((_sobel[0] & 0x0000FF00) >> 8).toString());
    print((_sobel[0] & 0x000000FF).toString());

    Ima.Image _imageDataBlur =
        new Ima.Image(_imageDataImage.width, _imageDataImage.height);
    for (int i = 0; i < _imageDataBlur.length; i++) {
      int R = (_sobel[i] & 0x00FF0000) >> 16;
      int G = (_sobel[i] & 0x0000FF00) >> 8;
      int B = _sobel[i] & 0x000000FF;

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
        DateTime.now().millisecondsSinceEpoch - lastMillisImageReceived;
    setState(() {
      this.fpsText = timeLatence.toString() + "ms";
    });
    lastMillisImageReceived = DateTime.now().millisecondsSinceEpoch;
  }

  int a = 1;

  Uint8List int32BigEndianBytes(int value) =>
      Uint8List(4)..buffer.asByteData().setInt32(0, value, Endian.big);

  void focusDslr() {
    Uint8List byteX = int32BigEndianBytes(afX);
    Uint8List byteY = int32BigEndianBytes(afY);
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
    BluetoothUtils.sendByteMessage(byteList, connection);
  }

  int afX = 0;
  int afY = 0;

  double xPosition = 0;
  double yPosition = 0;
  GlobalKey key = GlobalKey();

  //Widget topWidget;

  // Widget liveViewWidget() {
  //   print("liveViewWidhget");
  //   return
  // }

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
    BluetoothUtils.sendByteMessage(byteList, connection);
  }

  Future<void> bluetoothConnexion() async {
    if (connection != null && connection.isConnected) {
      print("Deconnexion");
      connection.close();
      lvEnable = false;
    } else {
      final BluetoothDevice selectedDevice = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return SelectBondedDevicePage(checkAvailability: false);
          },
        ),
      );

      if (selectedDevice != null) {
        print('Connect -> selected ' + selectedDevice.address);
        connectToBluetooth(selectedDevice);
      } else {
        print('Connect -> no device selected');
      }
    }
  }

  void makeAutoFocus() {
    setState(() {
      colorFocus = mySecondColor;
    });

    Uint8List byteX = int32BigEndianBytes(afX);
    Uint8List byteY = int32BigEndianBytes(afY);
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
    BluetoothUtils.sendByteMessage(byteList, connection);
  }

  bottomBarClick(int i) {
    switch (i) {
      case 0:
        {
          print("Bluetooth connexion");
          bluetoothConnexion();
        }
        break;

      case 1:
        {
          print("focus");
          makeAutoFocus();
        }
        break;

      case 2:
        {
          switch (_controller.index) {
            case 0:
              print("capture from Control");
              break;

            case 1:
              print("capture from HDR" + hdrByteList.toString());

              lvEnable = false;
              print("lvEnable false");
              setState(() {
                colorLiveView = mySecondColor;
              });

              BluetoothUtils.sendByteMessage(hdrByteList, connection);
              break;
            case 2:
              print("capture from Blur");
              addBlurMask();
          }
        }
        break;

      case 3:
        {
          print("Live view");
          liveViewSwitch();
        }
        break;

      case 4:
        {
          print("profile");
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => SecondRoute()),
          // );
        }
        break;
    }
  }

  Future<void> addBlurMask() async{
    blurNumberTaken++;
    for(int i=0; i<maskLaplacianRealTime.length;i++){
      int factor = (blurNumberTaken+1)*blurNumberTaken;

      HSVColor myHsvPixel = HSVColor.fromColor(Color(maskLaplacianRealTime[i]));
      HSVColor myFuturHsv = HSVColor.fromAHSV(myHsvPixel.alpha, myHsvPixel.hue/factor, myHsvPixel.saturation, myHsvPixel.value);
      Color myFuturColor = myFuturHsv.toColor();


      double factorFix = blurNumberTaken /   (blurNumberTaken - 1) ;
      HSVColor myHsvPixelFix = HSVColor.fromColor(Color(maskLaplacianFix[i]));
      HSVColor myFuturHsvFix = HSVColor.fromAHSV(myHsvPixelFix.alpha, myHsvPixelFix.hue/factorFix, myHsvPixelFix.saturation, myHsvPixelFix.value);
      Color myFuturColorFix = myFuturHsvFix.toColor();

      if(myHsvPixel.value!=0){
        maskLaplacianFix[i] = myFuturColor.value;
      } else {
        maskLaplacianFix[i] = myFuturColorFix.value;
      }
      //maskLaplacianFix[i] = myFuturColor.value | myFuturColorFix.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              children: <Widget>[
                GestureDetector(
                  onTapDown: (tapInfo) {
                    setState(() {
                      colorFocus = mySecondColor;
                    });
                    RenderBox box = key.currentContext.findRenderObject();
                    Offset position = box.localToGlobal(Offset.zero);
                    double x = position.dx;
                    double y = position.dy;
                    print("Key: " + x.toString() + " : " + y.toString());
                    print("Tap: " +
                        (tapInfo.globalPosition.dx).toInt().toString() +
                        " : " +
                        (tapInfo.globalPosition.dy).toInt().toString());
                    setState(() {
                      xPosition = tapInfo.globalPosition.dx - x - 25;
                      yPosition = tapInfo.globalPosition.dy - y - 25;
                    });
                    print("pos: " +
                        xPosition.toString() +
                        " : " +
                        yPosition.toString());
                    afX = (tapInfo.globalPosition.dx - x) *
                        6000 ~/
                        MediaQuery.of(context).size.width;
                    afY = (tapInfo.globalPosition.dy - y) *
                        6000 ~/
                        MediaQuery.of(context).size.width;
                    print(afX.toString() + " | " + afY.toString());
                  },
                  key: key,
                  child: imageData != null
                      ? Image.memory(
                          imageData,
                          scale: 1.0,
                          gaplessPlayback: true,
                        )
                      : Text('loading...'),
                ),
                Text(
                  fpsText,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TabBar(
                  controller: _controller,
                  labelColor: myMainColorAccent,
                  tabs: [
                    Tab(
                      text: "Control",
                      icon: Icon(Icons.settings_remote),
                    ),
                    Tab(
                      text: "HDR",
                      icon: Icon(Icons.brightness_high),
                    ),
                    Tab(
                      text: "Focus",
                      icon: Icon(Icons.blur_circular),
                    )
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _controller,
                    children: [
                      Child1Page(
                        gilc: gilc,
                        connection: connection,
                      ),
                      Child2Page(
                          gilc: gilc,
                          connection: connection,
                          priorityMode: priorityMode,
                          //hdrByteList: hdrByteList,
                          onChanged: (hdrByteList) {
                            setState(() {
                              this.hdrByteList = hdrByteList;
                            });
                          }),
                      Child3Page(
                        gilc: gilc,
                        connection: connection,
                        onResetTap: onResetTap,
                        onMoveFocus: (distance) {moveFocus(distance);},
                      ),
                    ],
                  ),
                ),
                MyBottomBar2(
                  onTap: (int i) => bottomBarClick(i),
                  colorBluetooth: colorBluetooth,
                  colorFocus: colorFocus,
                  colorLiveView: colorLiveView,
                  colorProfile: colorPeople,
                )
              ],
            ),
            MyFocusRectangle(
              yPosition: yPosition,
              xPosition: xPosition,
              color: colorFocus,
            ),
          ],
        ),
      ),
    );
  }

  void onResetTap(){
    print("on reset tap persoPage");
    emptyLaplacianMask();
  }

  var downloadingImage = false;
  var timerDownloadImage = 0;
  List<int> wholeMessageHex = [];

  void _onDataReceived(Uint8List data) {
    for (int i = 0; i < data.length; i++) {
      if (!downloadingImage && data[i] == 0xFF && data.length - i >= 3) {
        //Nouvel Event
        if (data[i + 1] == 0xD8 && data[i + 2] == 0xFF) {
          print('debut image !!!');
          downloadingImage = true;
          timerDownloadImage = DateTime.now().millisecondsSinceEpoch;
        }
        if (data[i + 1] == 220 && data[i + 2] == 0xFF) {
          // AF
          print('Response autoFocus: ');
          if (data.length - i >= 4) {
            if (data[i + 3] == 0x59) {
              //0x59 == 'Y'
              print("Success");
              setState(() {
                colorFocus = myMainColor;
              });
            } else if (data[i + 3] == 0x4E) {
              // 0x4E == 'N'
              print("Fail");
              setState(() {
                colorFocus = mySecondColorAccent;
              });
            } else {
              print(data[i + 3]);
            }
          }
        } else if (data[i + 1] == 219 && data[i + 2] == 0xFF) {
          // Iso
          print('Response iso: ');
          if (data.length - i >= 4) {
            if (data[i + 3] == 0x59) {
              //0x59 == 'Y'
              print("Success");
              setState(() {
                gilc.isoObject.color = myMainColor;
              });
            } else if (data[i + 3] == 0x4E) {
              // 0x4E == 'N'
              print("Fail");
              setState(() {
                gilc.isoObject.color = myMainColor;
              });
            } else {
              setState(() {
                gilc.isoObject.selectedValue =
                    gilc.isoObject.listValue[data[i + 3]];
                gilc.isoObject.color = myMainColor;
              });
            }
          }
        } else if (data[i + 1] == 217 && data[i + 2] == 0xFF) {
          // Shutter
          print('Response shutter Speed: ');
          if (data.length - i >= 4) {
            if (data[i + 3] == 0x59) {
              //0x59 == 'Y'
              print("Success");
              setState(() {
                gilc.shutterObject.color = myMainColor;
              });
            } else if (data[i + 3] == 0x4E) {
              // 0x4E == 'N'
              print("Fail");
              gilc.shutterObject.color = mySecondColorAccent;
            } else {
              setState(() {
                gilc.shutterObject.selectedValue =
                    gilc.shutterObject.listValue[data[i + 3]];
                gilc.shutterObject.color = myMainColor;
              });
            }
          }
        } else if (data[i + 1] == 218 && data[i + 2] == 0xFF) {
          // Aperture
          print('Response aperture: ');
          if (data.length - i >= 4) {
            if (data[i + 3] == 0x59) {
              //0x59 == 'Y'
              print("Success");
              setState(() {
                gilc.apertureObject.color = myMainColor;
              });
            } else if (data[i + 3] == 0x4E) {
              // 0x4E == 'N'
              print("Fail");
              setState(() {
                gilc.apertureObject.color = mySecondColorAccent;
              });
            } else {
              setState(() {
                gilc.apertureObject.selectedValue =
                    gilc.apertureObject.listValue[data[i + 3]];
                gilc.apertureObject.color = myMainColor;
              });
            }
          }
        } else if (data[i + 1] == 221 && data[i + 2] == 0xFF) {
          // Aperture
          print('Response expoBias: ');
          if (data.length - i >= 4) {
            if (data[i + 3] == 0x59) {
              //0x59 == 'Y'
              print("Success");
              setState(() {
                gilc.expoObject.color = myMainColor;
              });
            } else if (data[i + 3] == 0x4E) {
              // 0x4E == 'N'
              print("Fail");
              setState(() {
                gilc.expoObject.color = mySecondColorAccent;
              });
            } else {
              setState(() {
                gilc.expoObject.selectedValue =
                    gilc.expoObject.listValue[data[i + 3]];
                gilc.expoObject.color = myMainColor;
              });
            }
          }
        } else if (data[i + 1] == 222 && data[i + 2] == 0xFF) {
          print('Response expo Mod: ');
          List<String> listPriorityModes = [
            "Manual",
            "AutoProg",
            "Aperture",
            "Shutter"
          ];
          setState(() {
            priorityMode = listPriorityModes[data[i + 3]];
          });
        }
      }

      if (downloadingImage) {
        wholeMessageHex.add(data[i]);
        //wholeMessageHex+=data[i].toRadixString(16);
        //wholeMessageHex+= " ";
      }

      if (downloadingImage && i > 0 && data[i - 1] == 0xFF && data[i] == 0xD9) {
        print('fin image !!!: ' + (wholeMessageHex.length).toString());
        print("timer Download image: " +
            (DateTime.now().millisecondsSinceEpoch - timerDownloadImage)
                .toString() +
            "ms");
        downloadingImage = false;
        //Image.memory(Uint8List.fromList(wholeMessageHex));
        updateImage(Uint8List.fromList(wholeMessageHex));
        wholeMessageHex = [];
        updateFps();

        if (lvEnable) {
          BluetoothUtils.sendMessage("A", connection);
        }
      }
      //print(data[i].toRadixString(16));
    }
    //print(wholeMessageHex);

    /*setState(() {
      messages.add(
        _Message(
          1,
          wholeMessageHex,
        ),
      );
    });*/
    return;
  }

  void liveViewSwitch() {
    if (lvEnable) {
      lvEnable = false;
      print("lvEnable false");
      BluetoothUtils.sendMessage("B", connection);
      setState(() {
        colorLiveView = mySecondColor;
      });
    } else {
      lvEnable = true;
      print("lvEnable true");
      BluetoothUtils.sendMessage("A", connection);
      cronLv();
      setState(() {
        colorLiveView = myMainColor;
      });
    }
  }

  void cronLv() {
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (lvEnable) {
        if (DateTime.now().millisecondsSinceEpoch - lastMillisImageReceived >
            3000) {
          print("cronLv");
          BluetoothUtils.sendMessage("A", connection);
        }
      }
    });
  }

  void moveFocus(int distance) {
    print("moveFocus");
    int direction = 0;
    if (distance > 0) direction = 1;
    distance = distance.abs();

    print("Direction: " +
        direction.toString() +
        " | distance: " +
        distance.toString());

    final bytesBuilder = BytesBuilder();
    bytesBuilder.add([
      utf8.encode("D")[0],
      direction,
      distance,
      utf8.encode(";")[0],
    ]);
    Uint8List byteList = bytesBuilder.toBytes();
    print(byteList); // [42, 0, 5, 255]
    BluetoothUtils.sendByteMessage(byteList, connection);
  }
}
