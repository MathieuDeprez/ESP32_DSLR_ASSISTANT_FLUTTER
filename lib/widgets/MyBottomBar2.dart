import 'dart:math';

import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:esp32_dslr_assistant_flutter/models/LiveViewProvider.dart';
import 'package:provider/provider.dart';

import '../Constants/MyColor.dart';
import '../models/BluetoothProvider.dart';
import '../my_logo_icon_icons.dart';
import '../utils.dart';

class MyBottomBar2 extends StatefulWidget {
  final void Function(int) onTap;
  // final Color colorBluetooth;
  final Color colorFocus;
  //final Color colorLiveView;
  final Color colorProfile;

  const MyBottomBar2({Key key, this.onTap, this.colorFocus, this.colorProfile})
      : super(key: key);

  @override
  _MyBottomBar2State createState() => _MyBottomBar2State();
}

class _MyBottomBar2State extends State<MyBottomBar2>
    with TickerProviderStateMixin {
  AnimationController _controllerAnimation;
  Animation _captureAnimation;
  AnimationController _controllerFocus;
  Animation _focusAnimation;

  //AnimationController _controllerLiveView;
  //Animation _liveViewAnimation;

  AnimationCombo bluetoothAnimationCombo;
  AnimationCombo focusAnimationCombo;
  AnimationCombo liveViewAnimationCombo;
  AnimationCombo peopleAnimationCombo;

  @override
  void initState() {
    _controllerAnimation = new AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 200,
      ),
    );

    _captureAnimation =
        Tween(begin: 0.0, end: pi).animate(_controllerAnimation);

    bluetoothAnimationCombo = new AnimationCombo(this);
    focusAnimationCombo = new AnimationCombo(this);
    liveViewAnimationCombo = new AnimationCombo(this);
    peopleAnimationCombo = new AnimationCombo(this);

    super.initState();
  }

  Widget _MyCaptureItem(int index) {
    return Expanded(
      child: SizedBox(
        height: 60,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () {
              widget.onTap(index);
              _controllerAnimation.isCompleted
                  ? _controllerAnimation.reverse()
                  : _controllerAnimation.forward();
            },
            child: AnimatedBuilder(
              animation: _controllerAnimation,
              builder: (context, child) => Transform.rotate(
                angle: _captureAnimation.value,
                child: Icon(
                  MyLogoIcon.logo,
                  color: myMainColor,
                  size: 40,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _MyItem(
      Color color, IconData icon, int index, AnimationCombo animationCombo) {
    return Expanded(
      child: SizedBox(
        height: 60,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () {
              widget.onTap(index);
              animationCombo.animationController.forward();
            },
            child: AnimatedBuilder(
              animation: animationCombo.animationController,
              builder: (context, child) => Transform.scale(
                scale: animationCombo.animation.value,
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("*** My Bottom Bar 2");
    var bluetoothCoProv = Provider.of<BluetoothProvider>(context);
    var liveViewProv = Provider.of<LiveViewProvider>(context);
    return BottomAppBar(
      child: Container(
        color: mydarkColor,
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            _MyItem(bluetoothCoProv.color, Icons.bluetooth, 0,
                bluetoothAnimationCombo),
            _MyItem(widget.colorFocus, Icons.center_focus_strong_outlined, 1,
                focusAnimationCombo),
            _MyCaptureItem(2),
            _MyItem(liveViewProv.colorLv, Icons.photo_camera_outlined, 3,
                liveViewAnimationCombo),
            _MyItem(widget.colorProfile, Icons.people, 4, peopleAnimationCombo),
          ],
        ),
      ),
      color: Colors.white,
    );
  }
}
