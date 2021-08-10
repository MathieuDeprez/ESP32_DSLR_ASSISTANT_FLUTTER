import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:esp32_dslr_assistant_flutter/Constants/MyColor.dart';
import 'package:esp32_dslr_assistant_flutter/models/LiveViewLongExpoModel.dart';
import 'package:provider/provider.dart';

import '../utils.dart';

class TimeLapsePage extends StatefulWidget {
  final Function(Uint8List) onChanged;

  const TimeLapsePage({
    Key key,
    @required this.onChanged,
  }) : super(key: key);

  @override
  _TimeLapsePageState createState() => _TimeLapsePageState();
}

class _TimeLapsePageState extends State<TimeLapsePage>
    with TickerProviderStateMixin {
  LiveViewLongExpoModel testProv;
  int _fpsNumer = 24;
  int _initialTime = 60;
  int _finalTime = 10;
  String _indexParameter = "Final/Initial duration";
  int _factorMult = 1;
  double _rawDelay = 1;
  double finalDelay = 1;

  AnimationController _controllerAnimation;

  @override
  void initState() {
    super.initState();
    testProv = Provider.of<LiveViewLongExpoModel>(context, listen: false);
    updateTimeLaseList();

    _controllerAnimation = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controllerAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("*** BUILD TimeLapsePage");
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.teal,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  myDropDownMenu(fixParameterChangeFct, _indexParameter),
                  Container(
                    decoration: BoxDecoration(
                        color: Color(0x5fffffff),
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.symmetric(vertical: 10),

                    //Durée initiale/finale
                    child: _indexParameter == "Final/Initial duration"
                        ? Column(
                            children: [
                              Row(
                                children: [
                                  myTimeLapseParameter(
                                      "Initial duration",
                                      changeInitialTime,
                                      1,
                                      _initialTime.toString()),
                                  myTimeLapseParameter(
                                      "Final duration",
                                      changeFinalTime,
                                      1,
                                      _finalTime.toString()),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(child: Container()),
                                  myTimeLapseParameter("Fps", changeFps, 2,
                                      _fpsNumer.toString()),
                                  Expanded(child: Container()),
                                ],
                              ),
                            ],
                          )
                        : _indexParameter == "Multiplying factor"
                            ? Container(
                                child: Row(
                                  children: [
                                    myTimeLapseParameter(
                                        "Multiplying factor",
                                        changeFactorMult,
                                        1,
                                        _factorMult.toString()),
                                    myTimeLapseParameter("Fps", changeFps, 1,
                                        _fpsNumer.toString()),
                                  ],
                                ),
                              )
                            : Container(
                                padding: EdgeInsets.symmetric(horizontal: 80),
                                child: Row(
                                  children: [
                                    myTimeLapseParameter(
                                        "Delay",
                                        changeRawDelay,
                                        1,
                                        _rawDelay.toStringAsFixed(3)),
                                  ],
                                ),
                              ),
                  ),
                  Text(
                      "A photo will be taken every ${finalDelay.toStringAsFixed(3)}s"),
                ],
              ),
            ),
          ),
        ),
        Consumer<LiveViewLongExpoModel>(
          builder: (context, prov, child) {
            return Container(
              width: double.infinity,
              alignment: Alignment.bottomCenter,
              child: testProv.timelapseEnabled
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RotationTransition(
                          turns: Tween(begin: 0.0, end: 1.0)
                              .animate(_controllerAnimation),
                          child: Icon(
                            Icons.autorenew_rounded,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "TimeLapse Activated ...",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        RotationTransition(
                          turns: Tween(begin: 0.0, end: 1.0)
                              .animate(_controllerAnimation),
                          child: Icon(
                            Icons.autorenew_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                  : Container(),
              color: Colors.teal,
            );
          },
        ),
      ],
    );
  }

  calculDelay() {
    if (_indexParameter == "Final/Initial duration") {
      finalDelay = calculDureeIniFinal();
    } else if (_indexParameter == "Multiplying factor") {
      finalDelay = calculDureeFactor();
    } else if (_indexParameter == "Raw delay") {
      finalDelay = _rawDelay;
    }
    setState(() {});
  }

  void fixParameterChangeFct(String index) {
    //setState(() {
    _indexParameter = index;
    calculDelay();
    //});
    print("new index: $_indexParameter");
  }

  double calculDureeIniFinal() {
    return _initialTime / _finalTime / _fpsNumer;
  }

  double calculDureeFactor() {
    return 1 / _fpsNumer * _factorMult;
  }

  void changeRawDelay(double delay) {
    _rawDelay = delay;
    calculDelay();
  }

  void changeFactorMult(int factor) {
    _factorMult = factor;
    calculDelay();
  }

  void changeFps(int fpsNumer) {
    _fpsNumer = fpsNumer;
    calculDelay();
    print("new fps: $_fpsNumer");
  }

  void changeInitialTime(int time) {
    _initialTime = time;
    calculDelay();
    print("new initTime: $_initialTime");
  }

  void changeFinalTime(int time) {
    _finalTime = time;
    calculDelay();
    print("new finalTime: $_finalTime");
  }

  Uint8List int32BigEndianBytes(int value) =>
      Uint8List(4)..buffer.asByteData().setInt32(0, value, Endian.big);

  void updateTimeLaseList() {
    final bytesBuilder = BytesBuilder();
    bytesBuilder.add([
      utf8.encode('T')[0],
    ]);

    //Add timer[0]
    bytesBuilder.add([
      int32BigEndianBytes(testProv.timer)[2],
    ]);

    //Add timer[1]
    bytesBuilder.add([
      int32BigEndianBytes(testProv.timer)[3],
    ]);

    //Add end List
    bytesBuilder.add([
      utf8.encode(";")[0],
    ]);
    widget.onChanged(bytesBuilder.toBytes());
  }
}

Widget myTimeLapseParameter(
    String title, Function changeValueFct, int flex, String initialValue) {
  return Expanded(
    flex: flex,
    child: Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          width: double.infinity,
          child: Text(
            title,
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
              color: mySecondColor,
              borderRadius: BorderRadius.all(Radius.circular(30))),
          child: Container(
            padding: EdgeInsets.only(left: 15),
            child: TextFormField(
              initialValue: initialValue,
              onChanged: (text) {
                if (double.tryParse(text) != null) {
                  if (title == "Delay") {
                    changeValueFct(double.parse(text));
                  } else {
                    changeValueFct(int.parse(text));
                  }
                } else {
                  if (title == "Delay") {
                    changeValueFct(0.0);
                  } else {
                    changeValueFct(0);
                  }
                }
              },
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: TextStyle(),
              decoration: InputDecoration(
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget myDropDownMenu(Function changeFct, String value) {
  //String dropdownValue = 'Durée initiale/finale';

  return Column(
    children: [
      Text(
        "Paramètre fixe",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
            color: mySecondColor,
            borderRadius: BorderRadius.all(Radius.circular(30))),
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.arrow_drop_down),
          iconSize: 24,
          elevation: 16,
          style:
              TextStyle(color: myMainColorAccent, fontWeight: FontWeight.bold),
          /*underline: Container(
              height: 2,
              color: Colors.deepPurpleAccent,
            ),*/
          underline: Container(),
          onChanged: (String newValue) {
            changeFct(newValue);
            //value = newValue;
          },
          items: <String>[
            'Final/Initial duration',
            'Multiplying factor',
            'Raw delay'
          ].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    ],
  );
}
