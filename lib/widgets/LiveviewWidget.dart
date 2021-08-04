import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:esp32_dslr_assistant_flutter/Constants/MyColor.dart';
import 'package:esp32_dslr_assistant_flutter/models/BluetoothProvider.dart';
import 'package:esp32_dslr_assistant_flutter/models/DslrSettingsProvider.dart';
import 'package:esp32_dslr_assistant_flutter/models/LiveViewProvider.dart';
import 'package:esp32_dslr_assistant_flutter/models/LiveViewLongExpoModel.dart';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as Ima;
import 'MyFocusRectangle.dart';

class LiveviewWidget extends StatefulWidget {
  const LiveviewWidget({Key key}) : super(key: key);

  @override
  _LiveviewWidgetState createState() => _LiveviewWidgetState();
}

class _LiveviewWidgetState extends State<LiveviewWidget> {
  GlobalKey key = GlobalKey();
  Ima.Image maskLaplacianRealTime;
  Ima.Image maskLaplacianFix;

  @override
  void initState() {
    super.initState();
  }

  Future<void> emptyLaplacianMask() async {
    maskLaplacianRealTime = Ima.Image(640, 424);
    maskLaplacianFix = Ima.Image(640, 424);
    for (int i = 0; i < maskLaplacianRealTime.length; i++) {
      maskLaplacianRealTime[i] = 0xFF000000;
      maskLaplacianFix[i] = 0xFF000000;
    }
  }

  @override
  Widget build(BuildContext context) {
    print("*** BUILD LiveView Widget");
    var dslrSettings =
        Provider.of<DslrSettingsProvider>(context, listen: false);
    var testProv = Provider.of<LiveViewLongExpoModel>(context, listen: false);
    double rawWidth = MediaQuery.of(context).size.width;
    double rawHeight = rawWidth * 2 / 3;

    return Stack(
      children: [
        Stack(
          children: <Widget>[
            GestureDetector(
              onPanUpdate: (details) {
                if (dslrSettings.colorFocus != mySecondColor) {
                  dslrSettings.colorFocus = mySecondColor;
                }
                RenderBox box = key.currentContext.findRenderObject();
                Offset position = box.localToGlobal(Offset.zero);
                double x = position.dx;
                double y = position.dy;

                testProv.xPosition = min(
                    max(details.globalPosition.dx - x - 25, 0), rawWidth - 50);
                testProv.yPosition = min(
                    max(details.globalPosition.dy - y - 20, 0), rawHeight - 40);
                dslrSettings.afX = min(
                    max((details.globalPosition.dx - x) * 6000 ~/ rawWidth, 0),
                    6000);
                dslrSettings.afY = min(
                    max((details.globalPosition.dy - y) * 6000 ~/ rawHeight, 0),
                    4000);
              },
              onTapDown: (tapInfo) {
                if (dslrSettings.colorFocus != mySecondColor) {
                  dslrSettings.colorFocus = mySecondColor;
                }
                RenderBox box = key.currentContext.findRenderObject();
                Offset position = box.localToGlobal(Offset.zero);
                double x = position.dx;
                double y = position.dy;
                testProv.xPosition = min(
                    max(tapInfo.globalPosition.dx - x - 25, 0), rawWidth - 50);
                testProv.yPosition = min(
                    max(tapInfo.globalPosition.dy - y - 20, 0), rawHeight - 40);
                dslrSettings.afX = min(
                    max((tapInfo.globalPosition.dx - x) * 6000 ~/ rawWidth, 0),
                    6000);
                dslrSettings.afY = min(
                    max((tapInfo.globalPosition.dy - y) * 6000 ~/ rawHeight, 0),
                    4000);
              },
              key: key,
              child:
                  Consumer<LiveViewProvider>(builder: (context, data, child) {
                return data.imageData != null
                    ? Image.memory(
                        data.imageData,
                        scale: 1.0,
                        gaplessPlayback: true,
                      )
                    : Text('loading...');
              }),
            ),
            Consumer<LiveViewProvider>(
              builder: (context, data, child) {
                return Positioned(
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(15),
                      ),
                    ),
                    child: Text(
                      data.fpsText,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        Consumer2<LiveViewLongExpoModel, DslrSettingsProvider>(
            builder: (context, data, data2, child) {
          return MyFocusRectangle(
            yPosition: data.yPosition,
            xPosition: data.xPosition,
            color: data2.colorFocus,
          );
        }),
      ],
    );
  }
}
