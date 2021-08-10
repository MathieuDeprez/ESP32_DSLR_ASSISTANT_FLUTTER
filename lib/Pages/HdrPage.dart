import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:esp32_dslr_assistant_flutter/Constants/MyColor.dart';
import 'package:esp32_dslr_assistant_flutter/Constants/MyLists.dart';
import 'package:esp32_dslr_assistant_flutter/models/DslrSettingsProvider.dart';
import 'package:esp32_dslr_assistant_flutter/models/HdrModel.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../BluetoothUtils.dart';
import '../ItemList.dart';
import '../models/BluetoothProvider.dart';

class HdrPage extends StatefulWidget {
  final Function(Uint8List) onChanged;

  const HdrPage({
    Key key,
    @required this.onChanged,
  }) : super(key: key);

  @override
  _HdrPageState createState() => _HdrPageState();
}

class _HdrPageState extends State<HdrPage> {
  HdrModel hdrProvider;
  @override
  @override
  void initState() {
    super.initState();
    hdrProvider = Provider.of<HdrModel>(context, listen: false);
    updateHdrList();
  }

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
    print("*** BUILD HDR Page");

    return Container(
      color: Colors.teal,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
            child: Consumer<HdrModel>(builder: (context, data, child) {
          return Column(
            children: [
              MyHdrBar(
                number: data.hdrNumber,
                offset: data.hdrOffset,
                pas: data.hdrPas,
              ),
              NumberPhotoWidget("Number of photos", data.hdrNumber.toString(),
                  minusHdrNumber, addHdrNumber),
              NumberPhotoWidget(
                  "Increment", data.hdrPas.toString(), minusHdrPas, addHdrPas),
              NumberPhotoWidget("Offset", data.hdrOffset.toString(),
                  minusHdrOffset, addHdrOffset),
              Consumer<DslrSettingsProvider>(builder: (context, data, child) {
                return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        "Priority " + data.priorityMode,
                        style: TextStyle(
                            color: mySecondColor, fontWeight: FontWeight.bold),
                      ),
                    ]);
              })
            ],
          );
        })),
      ),
    );
  }

  void minusHdrNumber() {
    int number = min(max(hdrProvider.hdrNumber -= 2, 1), 9);
    hdrProvider.hdrNumber = number;
    updateHdrList();
  }

  void addHdrNumber() {
    int number = min(max(hdrProvider.hdrNumber += 2, 1), 9);
    hdrProvider.hdrNumber = number;
    updateHdrList();
  }

  void minusHdrPas() {
    int index = 0;
    for (String i in expoList) {
      if (double.parse(i) == hdrProvider.hdrPas) {
        break;
      }
      index++;
    }
    index = min(max(17, index), 30);
    hdrProvider.hdrPas = double.parse(expoList[index - 1]);
    updateHdrList();
  }

  void addHdrPas() {
    int index = 0;
    for (String i in expoList) {
      if (double.parse(i) == hdrProvider.hdrPas) {
        break;
      }
      index++;
    }
    index = min(max(17, index), 29);

    hdrProvider.hdrPas = double.parse(expoList[index + 1]);
    updateHdrList();
  }

  void minusHdrOffset() {
    int index = expoList.indexOf(hdrProvider.hdrOffset);
    index = min(max(1, index), 29);
    hdrProvider.hdrOffset = expoList[index - 1];
    updateHdrList();
  }

  void addHdrOffset() {
    int index = expoList.indexOf(hdrProvider.hdrOffset);
    index = min(max(1, index), 29);
    hdrProvider.hdrOffset = expoList[index + 1];
    updateHdrList();
  }

  Uint8List int32BigEndianBytes(int value) =>
      Uint8List(4)..buffer.asByteData().setInt32(0, value, Endian.big);

  void updateHdrList() {
    final bytesBuilder = BytesBuilder();
    bytesBuilder.add([
      utf8.encode('H')[0],
    ]);

    //Add number
    bytesBuilder.add([
      int32BigEndianBytes(hdrProvider.hdrNumber)[3],
    ]);

    //Add Pas
    int pasInt = (hdrProvider.hdrPas * 10).toInt();
    bytesBuilder.add([
      int32BigEndianBytes(pasInt)[3],
    ]);

    //Add offset
    int offset = expoList.indexOf(hdrProvider.hdrOffset);
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
    print("*** MyHdrBar");
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
      //print(indexTaken.toString());
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
              color: mySecondColor,
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
    print("*** MyBackHdrBar");
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
