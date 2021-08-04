import 'package:flutter/material.dart';
import 'package:esp32_dslr_assistant_flutter/Constants/MyColor.dart';
import 'package:esp32_dslr_assistant_flutter/Constants/MyLists.dart';
import 'package:esp32_dslr_assistant_flutter/models/DslrSettingsProvider.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:provider/provider.dart';

import '../BluetoothUtils.dart';
import '../ItemList.dart';
import 'SelectorWidget.dart';
import '../models/BluetoothProvider.dart';

class MainControlWidget extends StatefulWidget {
  const MainControlWidget({Key key}) : super(key: key);

  @override
  _MainControlWidgetState createState() => _MainControlWidgetState();
}

class _MainControlWidgetState extends State<MainControlWidget> {
  _MainControlWidgetState(); //constructor

  @override
  Widget build(BuildContext context) {
    var bluetoothCoPro = Provider.of<BluetoothProvider>(context, listen: false);
    var dslrSettings = Provider.of<DslrSettingsProvider>(context);
    print("*** MAIN CTRL BUILD");
    return Container(
      padding: EdgeInsets.all(0),
      margin: EdgeInsets.all(0),
      alignment: Alignment.center,
      child: Column(
        children: [
          Text(
            "Main control",
            style: TextStyle(color: mySecondColor, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SelectorWidget(
                onValueSelected: (String value) {
                  dslrSettings.apertureObject.selectedValue = value;
                  BluetoothUtils.sendDslrValue(
                      dslrSettings.apertureObject, bluetoothCoPro.connexion);

                  dslrSettings.apertureObject.color = mySecondColorAccent;
                  dslrSettings.notify();
                },
                settingModel: dslrSettings.apertureObject,
              ),
              SelectorWidget(
                onValueSelected: (String value) {
                  dslrSettings.shutterObject.selectedValue = value;
                  BluetoothUtils.sendDslrValue(
                      dslrSettings.shutterObject, bluetoothCoPro.connexion);
                  dslrSettings.shutterObject.color = mySecondColorAccent;
                  dslrSettings.notify();
                },
                settingModel: dslrSettings.shutterObject,
              ),
              SelectorWidget(
                onValueSelected: (String value) {
                  dslrSettings.isoObject.selectedValue = value;
                  BluetoothUtils.sendDslrValue(
                      dslrSettings.isoObject, bluetoothCoPro.connexion);
                  dslrSettings.isoObject.color = mySecondColorAccent;
                  dslrSettings.notify();
                },
                settingModel: dslrSettings.isoObject,
              ),
              /*SelectorWidget(
                onValueSelected: (String value) {
                  dslrSettings.expoObject.selectedValue = value;
                  BluetoothUtils.sendDslrValue(
                      dslrSettings.expoObject, bluetoothCoPro.connexion);
                  dslrSettings.expoObject.color = mySecondColorAccent;
                  dslrSettings.notify();
                },
                settingModel: dslrSettings.expoObject,
              ),*/
            ],
          ),
        ],
      ),
    );
  }
}
