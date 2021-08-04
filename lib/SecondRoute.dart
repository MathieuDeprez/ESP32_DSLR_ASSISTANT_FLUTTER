import 'package:flutter/material.dart';

class SecondRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("*** SecondRoute");
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Route"),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              // Navigate back to first route when tapped.
            },
            child: Text('Go back!'),
          ),
          Hero(
            tag: "DemoTag4",
            child: Icon(
              Icons.people,
              size: 150.0,
            ),
          ),
        ],
      ),
    );
  }
}
