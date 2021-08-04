import 'package:flutter/material.dart';
import 'package:esp32_dslr_assistant_flutter/models/DslrSettingsProvider.dart';
import 'package:esp32_dslr_assistant_flutter/widgets/MainControlWidget.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:provider/provider.dart';

import '../BluetoothUtils.dart';
import '../Constants/MyColor.dart';
import 'HorizontalPicker.dart';
import '../ItemList.dart';
import '../models/BluetoothProvider.dart';

class ExpoBiasWidget extends StatefulWidget {
  const ExpoBiasWidget({Key key}) : super(key: key);

  @override
  _ExpoBiasWidgetState createState() => _ExpoBiasWidgetState();
}

class _ExpoBiasWidgetState extends State<ExpoBiasWidget> {
  _ExpoBiasWidgetState(); //constructor

  @override
  Widget build(BuildContext context) {
    var bluetoothCoPro = Provider.of<BluetoothProvider>(context, listen: false);
    var dslrSettings = Provider.of<DslrSettingsProvider>(context);
    print("*** BUILD EXPO VIAS W");
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            print("send expo: " + dslrSettings.expoObject.selectedValue);
            BluetoothUtils.sendDslrValue(
                dslrSettings.expoObject, bluetoothCoPro.connexion);
          },
          child: Container(
            height: 60,
            width: double.infinity,
            child: HorizantalPicker(
              minValue: -5,
              maxValue: 5,
              divisions: 30,
              suffix: "",
              showCursor: false,
              backgroundColor: Colors.transparent,
              activeItemTextColor: Colors.black,
              passiveItemsTextColor: Colors.black,
              onChanged: (value) {
                int index = (value * 3).round() + 15;
                print("index expo: " + index.toString());
                dslrSettings.expoObject.selectedValue =
                    dslrSettings.expoObject.listValue[index];
                dslrSettings.expoObject.color = mySecondColorAccent;
                dslrSettings.notify();
              },
            ),
          ),
        ),
        Positioned.fill(
          top: 7,
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: dslrSettings.expoObject.color,
                borderRadius: BorderRadius.all(Radius.circular(10)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
