import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'BluetoothUtils.dart';
import 'Constants/MyColor.dart';
import 'HorizontalPicker.dart';
import 'ItemList.dart';

class ExpoBiasWidget extends StatefulWidget {
  final GroupItemListClass gilc;
  final BluetoothConnection connection;

  const ExpoBiasWidget(
      {Key key, @required this.gilc, @required this.connection})
      : super(key: key);

  @override
  _ExpoBiasWidgetState createState() =>
      _ExpoBiasWidgetState(this.gilc, this.connection);
}

class _ExpoBiasWidgetState extends State<ExpoBiasWidget> {
  GroupItemListClass gilc;

  BluetoothConnection connection;

  _ExpoBiasWidgetState(this.gilc, this.connection); //constructor

  @override
  Widget build(BuildContext context) {
    //_scrollController.jumpToItem(curItem);
    return GestureDetector(
      onTap: () {
        print("send expo: " + gilc.expoObject.selectedValue);
        BluetoothUtils.sendDslrValue(gilc.expoObject, connection);
      },
      child: Container(
        decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 7,
              colors: [
                Colors.white,
                gilc.expoObject.color,
              ],
            )
        ),
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
            gilc.expoObject.selectedValue = gilc.expoObject.listValue[index];
            setState(() {
              gilc.expoObject.color = mySecondColor;
            });
          },
        ),
      ),
    );
  }
}
