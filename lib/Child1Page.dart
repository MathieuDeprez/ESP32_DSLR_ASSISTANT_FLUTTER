import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_app_01/ItemList.dart';
import 'package:flutter_app_01/PersoPage.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'BluetoothUtils.dart';
import 'ExpoBiasWidget.dart';
import 'HorizontalPicker.dart';

import 'MainControlWidget.dart';
import 'SelectorWidget.dart';

class Child1Page extends StatefulWidget {
  final BluetoothConnection connection;
  final GroupItemListClass gilc;

  const Child1Page({Key key, @required this.gilc, @required this.connection})
      : super(key: key);

  @override
  _Child1PageState createState() => _Child1PageState();
}

class _Child1PageState extends State<Child1Page> {
  //GroupItemListClass gilc;
  //BluetoothConnection connection;

  //_Child1PageState(this.gilc, this.connection); //constructor

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            MainControlWidget(
              gilc: widget.gilc,
              connection: widget.connection,
            ),
            Divider(color: Colors.black),
            Text("Exposition Bias"),
            ExpoBiasWidget(
              gilc: widget.gilc,
              connection: widget.connection,
            ),
            Divider(color: Colors.black),
          ],
        ),
      ),
    );
  }
}

