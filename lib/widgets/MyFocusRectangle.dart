import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:esp32_dslr_assistant_flutter/Constants/MyColor.dart';

class MyFocusRectangle extends StatelessWidget {
  final double yPosition;
  final double xPosition;
  final Color color;

  const MyFocusRectangle({this.yPosition, this.xPosition, this.color});

  @override
  Widget build(BuildContext context) {
    //print("*** My Focus Rectangle");
    return Positioned(
      top: yPosition,
      left: xPosition,
      child: IgnorePointer(
        child: Container(
          width: 50,
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(
              color: color,
              width: 3,
            ),
          ),
          alignment: Alignment.center,
          child: Container(
            //alignment: Alignment.center,
            width: 2,
            height: 2,
            color: color,
          ),
        ),
      ),
    );
  }
}
