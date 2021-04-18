import 'package:flutter/material.dart';
import 'package:flutter_app_01/Constants/MyColor.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'BluetoothUtils.dart';
import 'ItemList.dart';
import 'SelectorWidget.dart';

class MainControlWidget extends StatefulWidget {
  final GroupItemListClass gilc;
  final BluetoothConnection connection;

  const MainControlWidget(
      {Key key, @required this.gilc, @required this.connection})
      : super(key: key);

  @override
  _MainControlWidgetState createState() =>
      _MainControlWidgetState(this.gilc, this.connection);
}

class _MainControlWidgetState extends State<MainControlWidget> {
  GroupItemListClass gilc;

  BluetoothConnection connection;

  _MainControlWidgetState(this.gilc, this.connection); //constructor

  @override
  Widget build(BuildContext context) {
    //_scrollController.jumpToItem(curItem);
    return Container(
      padding: EdgeInsets.all(0),
      margin: EdgeInsets.all(0),
      alignment: Alignment.center,
      child: Column(
        children: [
          Text("Main control"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SelectorWidget(
                  onValueSelected: (String value) {
                    setState(() {
                      gilc.apertureObject.selectedValue = value;
                    });
                    BluetoothUtils.sendDslrValue(
                        gilc.apertureObject, connection);
                    setState(() {
                      gilc.apertureObject.color = mySecondColor;
                    });
                  },
                  color: gilc.apertureObject.color,
                  list: gilc.apertureObject.listValue,
                  selectedValue: gilc.apertureObject.selectedValue,
                  text: "Select the Aperture"),
              SelectorWidget(
                  onValueSelected: (String value) {
                    setState(() {
                      gilc.shutterObject.selectedValue = value;
                    });
                    BluetoothUtils.sendDslrValue(
                        gilc.shutterObject, connection);
                    setState(() {
                      gilc.shutterObject.color = mySecondColor;
                    });
                  },
                  color: gilc.shutterObject.color,
                  list: gilc.shutterObject.listValue,
                  selectedValue: gilc.shutterObject.selectedValue,
                  text: "Select the Shutter"),
              SelectorWidget(
                  onValueSelected: (String value) {
                    setState(() {
                      gilc.isoObject.selectedValue = value;
                    });
                    BluetoothUtils.sendDslrValue(gilc.isoObject, connection);
                    setState(() {
                      gilc.isoObject.color = mySecondColor;
                    });
                  },
                  color: gilc.isoObject.color,
                  list: gilc.isoObject.listValue,
                  selectedValue: gilc.isoObject.selectedValue,
                  text: "Select the Iso"),
              SelectorWidget(
                  onValueSelected: (String value) {
                    setState(() {
                      gilc.expoObject.selectedValue = value;
                    });
                    BluetoothUtils.sendDslrValue(gilc.expoObject, connection);
                    setState(() {
                      gilc.expoObject.color = mySecondColor;
                    });
                  },
                  color: gilc.expoObject.color,
                  list: gilc.expoObject.listValue,
                  selectedValue: gilc.expoObject.selectedValue,
                  text: "Select the Expo"),
            ],
          ),
        ],
      ),
    );
  }
}
