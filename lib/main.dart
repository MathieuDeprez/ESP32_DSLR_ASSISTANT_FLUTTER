import 'package:flutter/material.dart';
import 'package:flutter_app_01/PersoPage.dart';

void main() => runApp(new ExampleApplication());

class ExampleApplication extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: PersoPage());
  }
}
