//import 'dart:ffi';

import 'dart:async';
import 'dart:ffi';

import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:esp32_dslr_assistant_flutter/Pages/BrowserPage.dart';
import 'package:flutter/material.dart';
import 'package:esp32_dslr_assistant_flutter/BluetoothUtils.dart';
import 'package:esp32_dslr_assistant_flutter/models/LiveViewProvider.dart';
import 'package:esp32_dslr_assistant_flutter/models/LiveViewLongExpoModel.dart';
import 'package:esp32_dslr_assistant_flutter/widgets/SelectorWidget.dart';

import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:esp32_dslr_assistant_flutter/models/DslrSettingsProvider.dart';
import 'package:esp32_dslr_assistant_flutter/widgets/LiveviewWidget.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:opencv/core/core.dart';
import 'package:opencv/core/imgproc.dart';
import 'package:provider/provider.dart';

//import 'package:charts_flutter/flutter.dart' as charts;
import '../SelectBondedDevicePage.dart';
import 'dart:math';
import "dart:typed_data";
import 'package:flutter_picker/flutter_picker.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:esp32_dslr_assistant_flutter/ItemList.dart';
import 'ControlPage.dart';
import 'HdrPage.dart';
import 'FocusPage.dart';
import '../Constants/MyColor.dart';
import '../MyBottomBar.dart';
import '../widgets/MyBottomBar2.dart';
import '../widgets/MyFocusRectangle.dart';
import 'TimeLapsePage.dart';
import '../SecondRoute.dart';
import '../widgets/SelectorWidget.dart';
import 'package:image/image.dart' as Ima;
import '../models/BluetoothProvider.dart';
import 'package:timer_builder/timer_builder.dart';

class PersoPage extends StatefulWidget {
  //final BluetoothDevice server;
  //const PersoPage({this.server});
  const PersoPage();

  @override
  _PersoPage createState() => new _PersoPage();
}

class _PersoPage extends State<PersoPage> with TickerProviderStateMixin {
  BuildContext contextBuilt = null;
  LiveViewLongExpoModel testProv;

  Uint8List imageData; // image from liveview

  Color colorBluetooth = mySecondColor;
  Color colorPeople = mySecondColor;

  bool blurDetectionEnable = false;
  //int blurNumberTaken = 0;
  //String priorityMode = "Unknown";

  Uint8List hdrByteList;
  Uint8List timeLapseByteList;
  Uint8List longExposureByteList = Uint8List.fromList([76, 0, 60, 59]);

  //GroupItemListClass gilc = new GroupItemListClass();

  @override
  void initState() {
    _controller = TabController(
      length: 5,
      vsync: this,
    );
    super.initState();
    print('initState');
    testProv = Provider.of<LiveViewLongExpoModel>(context, listen: false);

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
      setState(() {
        oldIndex = _controller.index;
      });
    }
  }

  TabController _controller;
  Timer _timerLongExpo;
  int _startLongExpo = 0;

  @override
  void dispose() {
    _controller.dispose();
    _timerLongExpo.cancel();
    super.dispose();
  }

  void startTimerLongExpo(int seconds) {
    setState(() {
      _startLongExpo = seconds + 1;
      print("_startLongExpo: $_startLongExpo");
    });
  }

  int a = 1;

  Uint8List int32BigEndianBytes(int value) =>
      Uint8List(4)..buffer.asByteData().setInt32(0, value, Endian.big);

  double xPosition = 0;
  double yPosition = 0;
  GlobalKey key = GlobalKey();

  bottomBarClick(int i) {
    var bluetoothCoPro =
        Provider.of<BluetoothProvider>(contextBuilt, listen: false);
    var liveViewProv =
        Provider.of<LiveViewProvider>(contextBuilt, listen: false);
    var dslrSettings =
        Provider.of<DslrSettingsProvider>(context, listen: false);
    switch (i) {
      case 0:
        {
          print("Bluetooth connexion");
          bluetoothCoPro.bluetoothConnexion(contextBuilt);
        }
        break;

      case 1:
        {
          print("focus");
          bluetoothCoPro.makeAutoFocus();
        }
        break;

      case 2:
        {
          switch (_controller.index) {
            case 0:
              print("capture from Control");

              if (dslrSettings.shutterObject.selectedValue == "BULB") {
                print("capture from Long exposure");
                testProv.lvEnable = false;
                BluetoothUtils.sendByteMessage(
                    longExposureByteList, bluetoothCoPro.connexion);

                print(
                    "longExposureByteList " + longExposureByteList.toString());

                int seconds = 0;
                if (longExposureByteList == null) {
                  seconds = 60;
                } else {
                  for (int i = 1; i < longExposureByteList.length - 1; i++) {
                    seconds |= longExposureByteList[i] <<
                        (longExposureByteList.length - 2 - i) * 8;
                  }
                }

                print("seconds " + seconds.toString());

                startTimerLongExpo(seconds);
              } else {
                final bytesBuilder = BytesBuilder();
                bytesBuilder.add([
                  utf8.encode("C")[0],
                  0,
                  utf8.encode(";")[0],
                ]);
                Uint8List byteList = bytesBuilder.toBytes();

                BluetoothUtils.sendByteMessage(
                    byteList, bluetoothCoPro.connexion);
              }
              break;

            case 1:
              print("capture from HDR" + hdrByteList.toString());
              var bluetoothCoPro =
                  Provider.of<BluetoothProvider>(contextBuilt, listen: false);
              bluetoothCoPro.lvEnable = false;
              print("lvEnable false");
              /*setState(() {
                colorLiveView = mySecondColor;
              });*/

              liveViewProv.colorLv = mySecondColor;
              BluetoothUtils.sendByteMessage(
                  hdrByteList, bluetoothCoPro.connexion);
              break;
            case 2:
              print("capture from Blur");

              final bytesBuilder = BytesBuilder();
              bytesBuilder.add([
                utf8.encode("C")[0],
                0,
                utf8.encode(";")[0],
              ]);
              Uint8List byteList = bytesBuilder.toBytes();

              BluetoothUtils.sendByteMessage(
                  byteList, bluetoothCoPro.connexion);

              liveViewProv.addBlurMask();
              break;
            case 3:
              print("capture from TimeLapse");
              testProv.lvEnable = false;
              if (!testProv.timelapseEnabled) {
                testProv.timelapseEnabled = true;
                BluetoothUtils.sendByteMessage(
                    timeLapseByteList, bluetoothCoPro.connexion);
              } else {
                testProv.timelapseEnabled = false;
                Uint8List timelapseStop = Uint8List.fromList([69]);

                BluetoothUtils.sendByteMessage(
                    timelapseStop, bluetoothCoPro.connexion);
              }

              break;
            case 4:
              print("capture from Long exposure");
              testProv.lvEnable = false;
              BluetoothUtils.sendByteMessage(
                  longExposureByteList, bluetoothCoPro.connexion);

              print("longExposureByteList " + longExposureByteList.toString());

              break;
          }
        }
        break;

      case 3:
        {
          print("Live view");
          var bluetoothCoPro =
              Provider.of<BluetoothProvider>(contextBuilt, listen: false);
          bluetoothCoPro.liveViewSwitch();
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

  @override
  Widget build(BuildContext context) {
    print("*** BUILD PersoPage");
    contextBuilt = context;
    var dslrSettings =
        Provider.of<DslrSettingsProvider>(context, listen: false);
    var liveViewProv = Provider.of<LiveViewProvider>(context, listen: false);

    return Scaffold(
      bottomNavigationBar: MyBottomBar2(
        onTap: (int i) => bottomBarClick(i),
        colorFocus: dslrSettings.colorFocus,
        colorProfile: colorPeople,
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.only(top: 10),
          color: mydarkColor,
          child: Column(
            children: <Widget>[
              TabBar(
                controller: _controller,
                labelColor: mySecondColor,
                unselectedLabelColor: Colors.teal,
                indicator: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                    color: Colors.teal),
                tabs: [
                  Tab(
                    text: "Control",
                    //icon: Icon(Icons.settings_remote),
                  ),
                  Tab(
                    text: "HDR",
                    //icon: Icon(Icons.brightness_high),
                  ),
                  Tab(
                    text: "Focus",
                    //icon: Icon(Icons.blur_circular),
                  ),
                  Tab(
                    text: "TimeLapse",
                    //icon: Icon(Icons.timelapse),
                  ),
                  Tab(
                    text: "Browser",
                    //icon: Icon(Icons.timelapse),
                  )
                ],
              ),
              _controller.index != 4 ? LiveviewWidget() : Container(),
              Expanded(
                child: Stack(
                  children: [
                    TabBarView(
                      controller: _controller,
                      children: [
                        ControlPage(
                          onChanged: (longExposureByteList) {
                            this.longExposureByteList = longExposureByteList;
                          },
                        ),
                        HdrPage(onChanged: (hdrByteList) {
                          this.hdrByteList = hdrByteList;
                        }),
                        FocusPage(
                          onMoveFocus: (distance) {
                            moveFocus(distance);
                          },
                        ),
                        TimeLapsePage(onChanged: (timeLapseByteList) {
                          this.timeLapseByteList = timeLapseByteList;
                        }),
                        BrowserPage(
                          downloadThumb: (handle) {
                            downloadThumbnail(handle);
                          },
                          getList: () {
                            getListHandles();
                          },
                          downloadJpeg: (handle) {
                            downloadJpeg(handle);
                          },
                          downloadJpegHQ: (handle) {
                            downloadJpegHQ(handle);
                          },
                          downloadRaw: (handle) {
                            downloadRaw(handle);
                          },
                        ),
                      ],
                    ),
                    TimerBuilder.periodic(
                      Duration(seconds: 1),
                      builder: (context) {
                        _startLongExpo--;
                        return _startLongExpo > 0
                            ? Positioned(
                                //LongExpo
                                bottom: 0,
                                right: 1,
                                left: 1,
                                child: Center(
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10)),
                                      color: mydarkColor,
                                    ),
                                    child: Text(
                                      _startLongExpo.toString(),
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              )
                            : Container();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void getListHandles() {
    print("getListHandles");
    final bytesBuilder = BytesBuilder();
    bytesBuilder.add([
      utf8.encode("M")[0],
    ]);
    Uint8List byteList = bytesBuilder.toBytes();
    print(byteList);
    var bluetoothCoPro =
        Provider.of<BluetoothProvider>(contextBuilt, listen: false);
    BluetoothUtils.sendByteMessage(byteList, bluetoothCoPro.connexion);
  }

  void downloadJpeg(String handle) {
    print("downloadJpeg: $handle");
    final bytesBuilder = BytesBuilder();
    List<int> handleInt = [
      int.parse(handle.substring(0, 2), radix: 16),
      int.parse(handle.substring(2, 4), radix: 16),
      int.parse(handle.substring(4, 6), radix: 16),
      int.parse(handle.substring(6, 8), radix: 16)
    ];
    bytesBuilder.add([
      78,
      handleInt[0],
      handleInt[1],
      handleInt[2],
      handleInt[3],
      utf8.encode(";")[0],
    ]);
    Uint8List byteList = bytesBuilder.toBytes();
    print(byteList); // [42, 0, 5, 255]
    var bluetoothCoPro =
        Provider.of<BluetoothProvider>(contextBuilt, listen: false);
    BluetoothUtils.sendByteMessage(byteList, bluetoothCoPro.connexion);
  }

  void downloadJpegHQ(String handle) {
    print("downloadJpegHQ: $handle");
    final bytesBuilder = BytesBuilder();
    List<int> handleInt = [
      int.parse(handle.substring(0, 2), radix: 16),
      int.parse(handle.substring(2, 4), radix: 16),
      int.parse(handle.substring(4, 6), radix: 16),
      int.parse(handle.substring(6, 8), radix: 16)
    ];
    bytesBuilder.add([
      80,
      handleInt[0],
      handleInt[1],
      handleInt[2],
      handleInt[3],
      utf8.encode(";")[0],
    ]);
    Uint8List byteList = bytesBuilder.toBytes();
    print(byteList); // [42, 0, 5, 255]
    var bluetoothCoPro =
        Provider.of<BluetoothProvider>(contextBuilt, listen: false);
    BluetoothUtils.sendByteMessage(byteList, bluetoothCoPro.connexion);
  }

  void downloadRaw(String handle) {
    print("downloadRaw: $handle");
    final bytesBuilder = BytesBuilder();
    List<int> handleInt = [
      int.parse(handle.substring(0, 2), radix: 16),
      int.parse(handle.substring(2, 4), radix: 16),
      int.parse(handle.substring(4, 6), radix: 16),
      int.parse(handle.substring(6, 8), radix: 16)
    ];
    bytesBuilder.add([
      81,
      handleInt[0],
      handleInt[1],
      handleInt[2],
      handleInt[3],
      utf8.encode(";")[0],
    ]);
    Uint8List byteList = bytesBuilder.toBytes();
    print(byteList); // [42, 0, 5, 255]
    var bluetoothCoPro =
        Provider.of<BluetoothProvider>(contextBuilt, listen: false);
    BluetoothUtils.sendByteMessage(byteList, bluetoothCoPro.connexion);
  }

  void downloadThumbnail(String handle) {
    print("downloadThumbnail: $handle");
    final bytesBuilder = BytesBuilder();
    List<int> handleInt = [
      int.parse(handle.substring(0, 2), radix: 16),
      int.parse(handle.substring(2, 4), radix: 16),
      int.parse(handle.substring(4, 6), radix: 16),
      int.parse(handle.substring(6, 8), radix: 16)
    ];
    bytesBuilder.add([
      utf8.encode("K")[0],
      handleInt[0],
      handleInt[1],
      handleInt[2],
      handleInt[3],
      utf8.encode(";")[0],
    ]);
    Uint8List byteList = bytesBuilder.toBytes();
    print(byteList); // [42, 0, 5, 255]
    var bluetoothCoPro =
        Provider.of<BluetoothProvider>(contextBuilt, listen: false);
    BluetoothUtils.sendByteMessage(byteList, bluetoothCoPro.connexion);
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
    var bluetoothCoPro =
        Provider.of<BluetoothProvider>(contextBuilt, listen: false);
    BluetoothUtils.sendByteMessage(byteList, bluetoothCoPro.connexion);
  }
}
