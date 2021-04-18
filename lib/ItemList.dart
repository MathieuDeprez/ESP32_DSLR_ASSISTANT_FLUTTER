import 'package:flutter/material.dart';

import 'Constants/MyColor.dart';

class GroupItemListClass {
  ItemListClass apertureObject = new ItemListClass(
      apertureColor, selectedAperture, apertureList, prefixAperture);
  ItemListClass shutterObject = new ItemListClass(
      shutterColor, selectedShutter, shutterList, prefixShutter);
  ItemListClass isoObject =
      new ItemListClass(isoColor, selectedIso, isoList, prefixIso);
  ItemListClass expoObject =
      new ItemListClass(expoColor, selectedExpo, expoList, prefixExpo);
}

class ItemListClass {
  Color color;
  String selectedValue;
  List<String> listValue;
  String prefix;

  ItemListClass(Color color, String selectedValue, List<String> listValue,
      String prefix) {
    this.color = color;
    this.selectedValue = selectedValue;
    this.listValue = listValue;
    this.prefix = prefix;
  }
}

String prefixAperture = "V";
Color apertureColor = mySecondColor;
var selectedAperture = "F3.5";
List<String> apertureList = <String>[
  'F2.8',
  'F3.2',
  'F3.5',
  'F4',
  'F4.5',
  'F5',
  'F5.6',
  'F6.3',
  'F7.1',
  'F8',
  'F9',
  'F10',
  'F11',
  'F13',
  'F14',
  'F16',
  'F18',
  'F20',
  'F22'
];

String prefixShutter = "S";
var selectedShutter = "1/400";
Color shutterColor = mySecondColor;
List<String> shutterList = <String>[
  '1/4000',
  '1/3200',
  '1/2500',
  '1/2000',
  '1/1600',
  '1/1250',
  '1/1000',
  '1/800',
  '1/640',
  '1/500',
  '1/400',
  '1/320',
  '1/250',
  '1/200',
  '1/160',
  '1/125',
  '1/100',
  '1/80',
  '1/60',
  '1/50',
  '1/40',
  '1/30',
  '1/25',
  '1/20',
  '1/15',
  '1/13',
  '1/13',
  '1/10',
  '1/8',
  '1/6',
  '1/5',
  '1/4',
  '1/3',
  '1/2.5',
  '1/2',
  '1/1.6',
  '1/1.3',
  '1',
  '1.3',
  '1.6',
  '2',
  '2.5',
  '3',
  '4',
  '5',
  '6',
  '8',
  '10',
  '13',
  '15',
  '20',
  '25',
  '30',
  'TIME',
  'BULB',
];

String prefixIso = "O";
var selectedIso = "400";
Color isoColor = mySecondColor;
List<String> isoList = <String>[
  '100',
  '200',
  '400',
  '800',
  '1600',
  '3200',
  '6400',
  '12800',
  '25600',
];

String prefixExpo = "X";
var selectedExpo = "0";
Color expoColor = mySecondColor;
List<String> expoList = <String>[
  '-5',
  '-4.67',
  '-4.33',
  '-4',
  '-3.67',
  '-3.33',
  '-3',
  '-2.67',
  '-2.33',
  '-2',
  '-1.67',
  '-1.33',
  '-1',
  '-0.67',
  '-0.33',
  '0',
  '+0.33',
  '+0.67',
  '+1',
  '+1.33',
  '+1.67',
  '+2',
  '+2.33',
  '+2.67',
  '+3',
  '+3.33',
  '+3.67',
  '+4',
  '+4.33',
  '+4.67',
  '+5',
];
