import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_01/Constants/MyColor.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:google_fonts/google_fonts.dart';

import 'BluetoothUtils.dart';
import 'ItemList.dart';

class Child2Page extends StatefulWidget {
  final BluetoothConnection connection;
  final GroupItemListClass gilc;
  final Function(Uint8List) onChanged;
  final String priorityMode;

  const Child2Page(
      {Key key,
      @required this.gilc,
      @required this.connection,
      @required this.onChanged,
      @required this.priorityMode})
      : super(key: key);

  @override
  _Child2PageState createState() => _Child2PageState();
}

class _Child2PageState extends State<Child2Page> {
  //GroupItemListClass gilc;
  //BluetoothConnection connection;
  //String priorityMode;

  int hdrNumber = 3;
  String hdrOffset = "-1.33";
  double hdrPas = 1;

  bool isSwitched = false;

  //_Child2PageState(this.gilc, this.connection, this.priorityMode); //constructor

  Widget NumberPhotoWidget(String text, String parameter,
      Function minusFunction, Function addFunction) {
    return Container(
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: minusFunction,
            icon: Icon(
              Icons.remove_circle_outline,
              color: myMainColorAccent,
            ),
            iconSize: 30.0,
          ),
          //Text("Number of photos"),
          Text(text),
          Text(
            parameter,
            style: TextStyle(
              color: myMainColorAccent,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          IconButton(
            onPressed: addFunction,
            icon: Icon(
              Icons.add_circle_outline,
              color: myMainColorAccent,
            ),
            iconSize: 30.0,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            MyHdrBar(
              number: hdrNumber,
              offset: hdrOffset,
              pas: hdrPas,
            ),
            NumberPhotoWidget("Number of photos", hdrNumber.toString(),
                minusHdrNumber, addHdrNumber),
            NumberPhotoWidget(
                "Exposition pas", hdrPas.toString(), minusHdrPas, addHdrPas),
            NumberPhotoWidget(
                "Offset", hdrOffset.toString(), minusHdrOffset, addHdrOffset),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Text("Priority " + widget.priorityMode),
            ]),
          ],
        ),
      ),
    );
  }

  void minusHdrNumber() {
    int number = min(max(hdrNumber -= 2, 1), 9);
    setState(() {
      hdrNumber = number;
    });
    updateHdrList();
  }

  void addHdrNumber() {
    int number = min(max(hdrNumber += 2, 1), 9);
    setState(() {
      hdrNumber = number;
    });
    updateHdrList();
  }

  void minusHdrPas() {
    int index = 0;
    for (String i in expoList) {
      if (double.parse(i) == hdrPas) {
        break;
      }
      index++;
    }
    index = min(max(17, index), 30);

    setState(() {
      hdrPas = double.parse(expoList[index - 1]);
    });
    updateHdrList();
  }

  void addHdrPas() {
    int index = 0;
    for (String i in expoList) {
      if (double.parse(i) == hdrPas) {
        break;
      }
      index++;
    }
    index = min(max(17, index), 29);

    setState(() {
      hdrPas = double.parse(expoList[index + 1]);
    });
    updateHdrList();
  }

  void minusHdrOffset() {
    int index = expoList.indexOf(hdrOffset);
    index = min(max(1, index), 29);
    setState(() {
      hdrOffset = expoList[index - 1];
    });
    updateHdrList();
  }

  void addHdrOffset() {
    int index = expoList.indexOf(hdrOffset);
    index = min(max(1, index), 29);
    setState(() {
      hdrOffset = expoList[index + 1];
    });
    updateHdrList();
  }

  Uint8List int32BigEndianBytes(int value) =>
      Uint8List(4)..buffer.asByteData().setInt32(0, value, Endian.big);

  // Uint8List byteX = int32BigEndianBytes(afX);

  void updateHdrList() {
    final bytesBuilder = BytesBuilder();
    bytesBuilder.add([
      utf8.encode('H')[0],
    ]);

    //Add number
    bytesBuilder.add([
      int32BigEndianBytes(hdrNumber)[3],
    ]);

    //Add Pas
    int pasInt = (hdrPas * 10).toInt();
    bytesBuilder.add([
      int32BigEndianBytes(pasInt)[3],
    ]);

    //Add offset
    int offset = expoList.indexOf(hdrOffset);
    bytesBuilder.add([
      int32BigEndianBytes(offset)[3],
    ]);

    //Add end List
    bytesBuilder.add([
      utf8.encode(";")[0],
    ]);
    widget.onChanged(bytesBuilder.toBytes());

    //print("byteHdr: " + byteList.toString()); // [42, 0, 5, 255]
  }
}

class MyHdrBar extends StatelessWidget {
  final int number;
  final String offset;
  final double pas;

  const MyHdrBar({this.number, this.offset, this.pas});

  get math => null;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MyBackgroundHdr(),
        Container(
          padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _buildRowList(number, offset, pas),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildRowList(int number, String offset, double pas) {
    List<Widget> list = []; // this will hold Rows according to available lines

    int indexOfExpo = expoList.indexOf(offset);
    List<int> expoHdrList = [];
    int startIndex = number ~/ 2;
    for (var i = 0; i < number; i++) {
      int indexTaken = ((i - startIndex) * pas * 3 + indexOfExpo).round();
      print(indexTaken.toString());
      expoHdrList.add(indexTaken);
    }

    for (var i = 0; i < 31; i++) {
      double width = 0;
      double height = 0;
      if (expoHdrList.contains(i)) {
        width = 5;
        height = 10;
      }
      list.add(
        Container(
          width: 10,
          child: Column(children: [
            Container(
              height: height,
              color: myMainColorAccent,
              width: width,
            ),
          ]),
        ),
      );
    }
    return list;
  }
}

class MyBackgroundHdr extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _buildRowList(),
      ),
    );
  }

  List<Widget> _buildRowList() {
    List<Widget> list = []; // this will hold Rows according to available lines

    for (var i = 0; i < 31; i++) {
      double width = 1;
      double height = 5;
      String text = "";
      if (i % 3 == 0) {
        width = 3;
        height = 10;
        text = (i / 3 - 5).toInt().toString();
      }
      list.add(
        Container(
          width: 10,
          child: Column(children: [
            Container(
              height: height,
              color: Colors.black,
              width: width,
            ),
            Text(
              text,
              style: TextStyle(fontSize: 10),
            ),
          ]),
        ),
      );
    }
    return list;
  }
}
