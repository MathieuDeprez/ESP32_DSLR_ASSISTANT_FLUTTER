import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';

class MyBottomBar extends StatelessWidget {
  final void Function(int) onTap;
  final Color colorBluetooth;
  final Color colorFocus;
  final Color colorLiveView;
  final Color colorProfile;

  const MyBottomBar({this.onTap, this.colorBluetooth, this.colorFocus, this.colorLiveView, this.colorProfile});

  @override
  Widget build(BuildContext context) {
    return ConvexAppBar(
      items: [
        TabItem(
            icon: Icon(
              Icons.bluetooth,
              color: colorBluetooth,
            ),
            //icon: Icons.bluetooth,
            title: 'Connexion'),
        TabItem(
            icon: Icon(
              Icons.center_focus_strong_outlined,
              color: colorFocus,
            ),
            title: 'Focus'),
        TabItem(
            icon: Icons.camera,
            title: 'Capture'),
        TabItem(
            icon: Icon(
              Icons.photo_camera_outlined,
              color: colorLiveView,
            ),
            title: 'Live view'),
        TabItem(
            icon: Icon(
              Icons.people,
              color: colorProfile,
            ),
            title: 'Profile'),
      ],
      style: TabStyle.fixedCircle,
      color: Colors.white,
      activeColor: Colors.white,
      initialActiveIndex: 2,
      //optional, default as 0
      cornerRadius: 30,
      top: -30,
      onTap: (int i) => onTap(i),
    );
  }
}
