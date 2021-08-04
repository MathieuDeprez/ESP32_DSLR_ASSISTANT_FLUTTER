import 'package:flutter/material.dart';

class AnimationCombo {
  TickerProvider tickerProvider;
  AnimationController animationController;
  CurvedAnimation curvedAnimation;
  Animation animation;

  AnimationCombo(TickerProvider tickerProvider) {
    this.tickerProvider = tickerProvider;

    animationController = new AnimationController(
      vsync: tickerProvider,
      duration: Duration(
        milliseconds: 100,
      ),
    );

    curvedAnimation = new CurvedAnimation(
        parent: animationController, curve: Curves.easeInOutSine);

    animation = new Tween(begin: 0.85, end: 1.5).animate(curvedAnimation)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          animationController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          // _controllerFocus.forward();
        }
      });
  }
}
