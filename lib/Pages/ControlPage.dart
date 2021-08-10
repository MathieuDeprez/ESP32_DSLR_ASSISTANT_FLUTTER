import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:esp32_dslr_assistant_flutter/Constants/MyColor.dart';
import 'package:esp32_dslr_assistant_flutter/ItemList.dart';
import 'package:esp32_dslr_assistant_flutter/Pages/PersoPage.dart';
import 'package:esp32_dslr_assistant_flutter/models/DslrSettingsProvider.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';
import '../BluetoothUtils.dart';
import '../widgets/ExpoBiasWidget.dart';
import '../widgets/HorizontalPicker.dart';

import '../widgets/MainControlWidget.dart';
import '../widgets/SelectorWidget.dart';
import '../models/BluetoothProvider.dart';

class ControlPage extends StatefulWidget {
  final Function(Uint8List) onChanged;

  const ControlPage({
    Key key,
    @required this.onChanged,
  }) : super(key: key);

  @override
  _ControlPageState createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  Uint8List int32BigEndianBytes(int value) =>
      Uint8List(4)..buffer.asByteData().setInt32(0, value, Endian.big);

  void updateLongExpoList(int longExposureTime) {
    final bytesBuilder = BytesBuilder();
    bytesBuilder.add([
      utf8.encode('L')[0],
    ]);

//Add delay[0]
    bytesBuilder.add([
      int32BigEndianBytes(longExposureTime)[2],
    ]);

    //Add delay[0]
    bytesBuilder.add([
      int32BigEndianBytes(longExposureTime)[3],
    ]);

    //Add end List
    bytesBuilder.add([
      utf8.encode(";")[0],
    ]);
    widget.onChanged(bytesBuilder.toBytes());
  }

  @override
  Widget build(BuildContext context) {
    print("*** BUILD Control Page");
    var dslrSettings = Provider.of<DslrSettingsProvider>(context);
    return Container(
      color: Colors.teal,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              MainControlWidget(),
              Divider(color: Colors.black),
              Text(
                "Exposure Compensation",
                style: TextStyle(
                    color: mySecondColor, fontWeight: FontWeight.bold),
              ),
              ExpoBiasWidget(),
              Divider(color: Colors.black),
              Opacity(
                opacity:
                    dslrSettings.shutterObject.selectedValue == "BULB" ? 1 : 0,
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        "Long exposure",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          NumberPicker(
                            value: dslrSettings.longExposureTime,
                            minValue: 1,
                            maxValue: 1000,
                            itemCount: 5,
                            itemWidth: 70,
                            itemHeight: 60,
                            axis: Axis.horizontal,
                            textStyle:
                                TextStyle(color: Colors.white, fontSize: 10),
                            selectedTextStyle:
                                TextStyle(color: Colors.white, fontSize: 30),
                            onChanged: (value) {
                              dslrSettings.longExposureTime = value;
                              updateLongExpoList(value);
                            },
                          ),
                        ],
                      ),
                      Text(
                        "seconds",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
