import 'dart:convert';
import 'dart:ffi';

//import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as Ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_01/Constants/MyColor.dart';
import 'package:flutter_app_01/ItemList.dart';
import 'package:flutter_app_01/PersoPage.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:image/image.dart' as Ima;
import 'package:opencv/core/core.dart';
import 'BluetoothUtils.dart';
import 'ExpoBiasWidget.dart';
import 'HorizontalPicker.dart';

import 'MainControlWidget.dart';
import 'SelectorWidget.dart';

//import 'package:opencv/opencv.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class Child3Page extends StatefulWidget {
  final BluetoothConnection connection;
  final GroupItemListClass gilc;
  final Function onResetTap;
  final Function onMoveFocus;

  const Child3Page(
      {Key key,
      @required this.gilc,
      @required this.connection,
      @required this.onResetTap,
      @required this.onMoveFocus})
      : super(key: key);

  @override
  _Child3PageState createState() => _Child3PageState();
}

class _Child3PageState extends State<Child3Page> {
  @override
  void initState() {
    super.initState();
  }

  bool toggle = false;
  double depth = 4;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          myButton("Reset Color", resetBtn),
          Container(
            child: Column(
              children: [
                Text("Focus"),
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
                )
              ],
            ),
          ),
        ],
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
          elevation: 5,
          side: BorderSide(width: 1.0, color: myMainColorAccent),
        ),
        child: Text(text),
        onPressed: () => function(),
      ),
    );
  }

  void resetBtn() {
    widget.onResetTap();
  }
}
