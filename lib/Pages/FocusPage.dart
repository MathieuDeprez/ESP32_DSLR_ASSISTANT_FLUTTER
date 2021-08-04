import 'dart:convert';
//import 'dart:ffi';

//import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as Ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:esp32_dslr_assistant_flutter/Constants/MyColor.dart';
import 'package:esp32_dslr_assistant_flutter/ItemList.dart';
import 'package:esp32_dslr_assistant_flutter/Pages/PersoPage.dart';
import 'package:esp32_dslr_assistant_flutter/models/FocusModel.dart';
import 'package:esp32_dslr_assistant_flutter/models/LiveViewProvider.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:image/image.dart' as Ima;
import 'package:opencv/core/core.dart';
import 'package:provider/provider.dart';
import '../BluetoothUtils.dart';
import '../widgets/ExpoBiasWidget.dart';
import '../widgets/HorizontalPicker.dart';

import '../widgets/MainControlWidget.dart';
import '../widgets/SelectorWidget.dart';

//import 'package:opencv/opencv.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../models/BluetoothProvider.dart';

class FocusPage extends StatefulWidget {
  final Function onMoveFocus;

  const FocusPage({Key key, @required this.onMoveFocus}) : super(key: key);

  @override
  _FocusPageState createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage> {
  @override
  void initState() {
    super.initState();
  }

  bool toggle = false;
  double depth = 4;

  int indexFirstList = 0;
  int indexSecondList = 0;

  @override
  void dispose() {
    super.dispose();
  }

  List<Widget> itemsFilterMod = [
    ListTile(
      trailing: Icon(Icons.cancel_presentation_sharp, size: 25),
      title: Text('Aucun'),
    ),
    ListTile(
      trailing: Icon(Icons.settings_overscan_outlined, size: 25),
      title: Text('Overlay'),
    ),
    ListTile(
      trailing: Icon(Icons.open_in_full_sharp, size: 25),
      title: Text('Full'),
    ),
  ];

  List<Widget> itemsFilterName = [
    ListTile(
      leading: Icon(Icons.face_outlined, size: 25),
      title: Text('Sobel'),
    ),
    ListTile(
      leading: Icon(Icons.face_retouching_natural, size: 25),
      title: Text('Laplacian'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    print("*** BUILD Focus Page");
    var focusProv = Provider.of<FocusModel>(context, listen: false);
    var liveViewProv = Provider.of<LiveViewProvider>(context, listen: false);
    //String dropdownValue = 'One';
    //

    return Container(
      color: Colors.teal,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Text(
              "Move Focus",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // myButton("<<<", resetBtn),
                myButton("<<", focusBackwardS),
                myButton("<", focusBackward),
                myButton(">", focusForward),
                myButton(">>", focusForwardS),
                // myButton(">>>", resetBtn),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.emoji_nature_rounded),
                Icon(
                  Icons.circle,
                  size: 5,
                ),
                Icon(
                  Icons.circle,
                  size: 7,
                ),
                Icon(
                  Icons.circle,
                  size: 10,
                ),
                Icon(Icons.landscape_rounded),
              ],
            ),
            Divider(),
            Text(
              "Filter",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Consumer<FocusModel>(builder: (context, prov, child) {
              return Container(
                margin: EdgeInsets.only(right: 10, top: 10),
                padding: EdgeInsets.only(top: 10, left: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 5,
                      color: Color(0x60000000),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        child: Column(
                          children: [
                            Text(
                              "Filter mode",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: myMainColorAccent,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 10, right: 10),
                              //color: Colors.yellow,
                              child: DropdownButton<String>(
                                value: prov.filterMode,
                                icon: const Icon(Icons.arrow_downward),
                                iconSize: 24,
                                isExpanded: true,
                                elevation: 16,
                                //style: const TextStyle(color: Colors.deepPurple),
                                onChanged: (String newValue) {
                                  focusProv.filterMode = newValue;
                                  if (focusProv.filterMode != "Aucun") {
                                    if (focusProv.filterType == "Sobel") {
                                      if (focusProv.filterMode == "Overlay")
                                        liveViewProv.overlayMode = true;
                                      else
                                        liveViewProv.fullMode = true;
                                      liveViewProv.sobel = true;
                                    } else {
                                      if (focusProv.filterMode == "Overlay")
                                        liveViewProv.overlayMode = true;
                                      else
                                        liveViewProv.fullMode = true;
                                      liveViewProv.laplacian = true;
                                    }
                                  } else {
                                    liveViewProv.sobel = false;
                                    liveViewProv.laplacian = false;
                                  }
                                },
                                items: <String>[
                                  'Aucun',
                                  'Overlay',
                                  'Full',
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    prov.filterMode != "Aucun"
                        ? Expanded(
                            child: Column(
                              children: [
                                Text(
                                  "Filter type",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: myMainColorAccent,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 10, right: 10),
                                  child: DropdownButton<String>(
                                    value: prov.filterType,
                                    icon: const Icon(Icons.arrow_downward),
                                    iconSize: 24,
                                    isExpanded: true,
                                    elevation: 16,
                                    onChanged: (String newValue) {
                                      focusProv.filterType = newValue;
                                      if (focusProv.filterMode != "Aucun") {
                                        if (focusProv.filterType == "Sobel") {
                                          if (focusProv.filterMode == "Overlay")
                                            liveViewProv.overlayMode = true;
                                          else
                                            liveViewProv.fullMode = true;
                                          liveViewProv.sobel = true;
                                        } else {
                                          if (focusProv.filterMode == "Overlay")
                                            liveViewProv.overlayMode = true;
                                          else
                                            liveViewProv.fullMode = true;
                                          liveViewProv.laplacian = true;
                                        }
                                      } else {
                                        liveViewProv.sobel = false;
                                        liveViewProv.laplacian = false;
                                      }
                                    },
                                    items: <String>[
                                      'Sobel',
                                      'Laplacian',
                                    ].map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  focusBackwardS() => widget.onMoveFocus(-10);

  focusBackward() => widget.onMoveFocus(-1);

  focusForward() => widget.onMoveFocus(1);

  focusForwardS() => widget.onMoveFocus(10);

  Widget myButton(String text, Function function) {
    return Container(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Colors.white,
          onPrimary: myMainColorAccent,
          elevation: 3,
          //side: BorderSide(width: 1.0, color: myMainColorAccent),
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(30.0),
          ),
        ),
        child: Text(text),
        onPressed: () => function(),
      ),
    );
  }
}
