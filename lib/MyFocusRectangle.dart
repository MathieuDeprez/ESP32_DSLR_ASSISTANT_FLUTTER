import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';

class MyFocusRectangle extends StatelessWidget {

  final double yPosition;
  final double xPosition;
  final Color color;

  const MyFocusRectangle({this.yPosition, this.xPosition, this.color});

  @override
  Widget build(BuildContext context) {
    return
      Positioned(
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
          ),
        ),
      );
  }
}