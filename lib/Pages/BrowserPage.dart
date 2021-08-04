import 'dart:convert';
import 'dart:typed_data';

import 'package:esp32_dslr_assistant_flutter/models/BrowserModel.dart';
import 'package:esp32_dslr_assistant_flutter/models/DslrSettingsProvider.dart';
import 'package:esp32_dslr_assistant_flutter/models/ObjectHandlesModel.dart';
import 'package:flutter/material.dart';
import 'package:esp32_dslr_assistant_flutter/Constants/MyColor.dart';
import 'package:provider/provider.dart';
import '../widgets/ExpoBiasWidget.dart';

import '../widgets/MainControlWidget.dart';
import 'package:numberpicker/numberpicker.dart';

class BrowserPage extends StatefulWidget {
  final Function(String) downloadThumb;
  final Function() getList;
  final Function(String) downloadJpeg;
  final Function(String) downloadJpegHQ;
  final Function(String) downloadRaw;

  const BrowserPage({
    Key key,
    @required this.downloadThumb,
    @required this.getList,
    @required this.downloadJpeg,
    @required this.downloadJpegHQ,
    @required this.downloadRaw,
  }) : super(key: key);

  @override
  _BrowserPageState createState() => _BrowserPageState();
}

class _BrowserPageState extends State<BrowserPage> {
  @override
  Widget build(BuildContext context) {
    //myHandlesList.add(ObjectHandlesModel('G', 'H', 'I'));
    print("*** BUILD Browser Page");
    var objectHandleProv = Provider.of<BrowserModel>(context);
    return Container(
      color: Colors.teal,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.download_rounded),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: myMainColorAccent,
                    elevation: 3,
                    //side: BorderSide(width: 1.0, color: myMainColorAccent),
                    shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0),
                    ),
                  ),
                  label: Text("Get photos list"),
                  onPressed: () {
                    objectHandleProv.emptyHandle();
                    objectHandleProv.downloadingList = true;
                    widget.getList();
                  },
                ),
                Text(
                  objectHandleProv.myHandlesList.length.toString() + " photos",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            objectHandleProv.downloadingList
                ? Expanded(
                    child: Center(
                      child: SizedBox(
                        height: 150,
                        width: 150,
                        child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white)),
                      ),
                    ),
                  )
                : Flexible(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: objectHandleProv.myHandlesList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                                /*border: Border(
                            left: BorderSide(
                              color: Colors.green,
                              width: 3,
                            ),
                          ),*/
                              ),

                              //height: 50,
                              //color: Colors.white,
                              margin: EdgeInsets.all(10),
                              padding: EdgeInsets.all(5),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            objectHandleProv
                                                .myHandlesList[index].name,
                                            style: TextStyle(
                                                color: Colors.teal,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                          Text(
                                            "Le ${int.parse(objectHandleProv.myHandlesList[index].time.substring(6, 8))}/${int.parse(objectHandleProv.myHandlesList[index].time.substring(4, 6))}/${int.parse(objectHandleProv.myHandlesList[index].time.substring(0, 4))} à ${int.parse(objectHandleProv.myHandlesList[index].time.substring(9, 11))}h${int.parse(objectHandleProv.myHandlesList[index].time.substring(11, 13))}m${int.parse(objectHandleProv.myHandlesList[index].time.substring(13, 15))}s",
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          Text(
                                            "Handle: ${objectHandleProv.myHandlesList[index].handle}",
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 10),
                                          ),
                                        ],
                                      ),
                                      Consumer<BrowserModel>(
                                          builder: (context, data, child) {
                                        return data
                                                    .getThumbnail(
                                                        objectHandleProv
                                                            .myHandlesList[
                                                                index]
                                                            .handle)
                                                    .length >
                                                10
                                            ? Image.memory(
                                                data.getThumbnail(
                                                    objectHandleProv
                                                        .myHandlesList[index]
                                                        .handle),
                                                scale: 1.0,
                                                gaplessPlayback: true,
                                              )
                                            : objectHandleProv
                                                        .myHandlesList[index]
                                                        .thumb ==
                                                    1
                                                ? CircularProgressIndicator(
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                            Color>(Colors.teal))
                                                : Icon(
                                                    Icons.preview_rounded,
                                                    color: Colors.teal,
                                                    size: 40,
                                                  );
                                      }),
                                    ],
                                  ),
                                  Consumer<BrowserModel>(
                                      builder: (context, data, child) {
                                    return data
                                                .getThumbnail(objectHandleProv
                                                    .myHandlesList[index]
                                                    .handle)
                                                .length >
                                            10
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              objectHandleProv
                                                          .myHandlesList[index]
                                                          .thumb ==
                                                      2
                                                  ? CircularProgressIndicator(
                                                      value: objectHandleProv
                                                          .myHandlesList[index]
                                                          .percent,
                                                      semanticsLabel:
                                                          'Linear progress indicator',
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                                  Color>(
                                                              Colors.teal))
                                                  : ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        primary: Colors.white,
                                                        onPrimary:
                                                            myMainColorAccent,
                                                        elevation: 3,
                                                        //side: BorderSide(width: 1.0, color: myMainColorAccent),
                                                        shape:
                                                            new RoundedRectangleBorder(
                                                          borderRadius:
                                                              new BorderRadius
                                                                      .circular(
                                                                  30.0),
                                                        ),
                                                      ),
                                                      child: Column(
                                                        children: [
                                                          Icon(Icons.image),
                                                          Text("Jpeg"),
                                                        ],
                                                      ),
                                                      onPressed: () {
                                                        objectHandleProv
                                                            .displayJpeg(
                                                                objectHandleProv
                                                                    .myHandlesList[
                                                                        index]
                                                                    .handle);
                                                        widget.downloadJpeg(
                                                            objectHandleProv
                                                                .myHandlesList[
                                                                    index]
                                                                .handle);
                                                      },
                                                    ),
                                              objectHandleProv
                                                          .myHandlesList[index]
                                                          .thumb ==
                                                      3
                                                  ? CircularProgressIndicator(
                                                      value: objectHandleProv
                                                          .myHandlesList[index]
                                                          .percent,
                                                      semanticsLabel:
                                                          'Linear progress indicator',
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                                  Color>(
                                                              Colors.teal))
                                                  : ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        primary: Colors.white,
                                                        onPrimary:
                                                            myMainColorAccent,
                                                        elevation: 3,
                                                        //side: BorderSide(width: 1.0, color: myMainColorAccent),
                                                        shape:
                                                            new RoundedRectangleBorder(
                                                          borderRadius:
                                                              new BorderRadius
                                                                      .circular(
                                                                  30.0),
                                                        ),
                                                      ),
                                                      child: Column(
                                                        children: [
                                                          Icon(Icons
                                                              .add_photo_alternate),
                                                          Text("Jpeg HQ"),
                                                        ],
                                                      ),
                                                      onPressed: () {
                                                        objectHandleProv
                                                            .displayJpegHq(
                                                                objectHandleProv
                                                                    .myHandlesList[
                                                                        index]
                                                                    .handle);
                                                        widget.downloadJpegHQ(
                                                            objectHandleProv
                                                                .myHandlesList[
                                                                    index]
                                                                .handle);
                                                      },
                                                    ),
                                              /*ElevatedButton(
                                                //icon: Icon(Icons.camera_enhance_rounded),
                                                style: ElevatedButton.styleFrom(
                                                  primary: Colors.white,
                                                  onPrimary: myMainColorAccent,
                                                  elevation: 3,
                                                  //side: BorderSide(width: 1.0, color: myMainColorAccent),
                                                  shape:
                                                      new RoundedRectangleBorder(
                                                    borderRadius:
                                                        new BorderRadius
                                                            .circular(30.0),
                                                  ),
                                                ),
                                                child: Column(
                                                  children: [
                                                    Icon(Icons
                                                        .camera_enhance_rounded),
                                                    Text("RAW"),
                                                  ],
                                                ),
                                                onPressed: () {
                                                  widget.downloadRaw(
                                                      objectHandleProv
                                                          .myHandlesList[index]
                                                          .handle);
                                                },
                                              ),*/
                                            ],
                                          )
                                        : Container();
                                  }),
                                ],
                              ),
                            ),
                            onTap: () {
                              print(
                                  "tap on photo: ${objectHandleProv.myHandlesList[index].name}");
                              objectHandleProv.handleDownloading =
                                  objectHandleProv.myHandlesList[index].handle;
                              objectHandleProv.displayThumb(
                                  objectHandleProv.myHandlesList[index].handle);
                              widget.downloadThumb(
                                  objectHandleProv.myHandlesList[index].handle);
                            });
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
