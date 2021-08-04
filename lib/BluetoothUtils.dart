import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:esp32_dslr_assistant_flutter/models/DslrSettingsProvider.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'ItemList.dart';

class BluetoothUtils {
  static sendDslrValue(
      SettingModel settingModel, BluetoothConnection connection) {
    List<int> bytesString = utf8.encode(settingModel.selectedValue);
    print(bytesString);
    final bytesBuilder = BytesBuilder();
    bytesBuilder.add([
      utf8.encode(settingModel.prefix)[0],
    ]);
    for (int i = 0; i < bytesString.length; i++) {
      bytesBuilder.add([
        bytesString[i],
      ]);
    }
    bytesBuilder.add([
      utf8.encode(";")[0],
    ]);
    Uint8List byteList = bytesBuilder.toBytes();
    print(byteList); // [42, 0, 5, 255]
    sendByteMessage(byteList, connection);
  }

  static void sendByteMessage(
      Uint8List bytesList, BluetoothConnection connection) async {
    if (bytesList.length > 0) {
      try {
        connection.output.add(bytesList);
        await connection.output.allSent;
      } catch (e) {}
    }
  }

  static void sendMessage(String text, BluetoothConnection connection) async {
    text = text.trim();
    if (text.length > 0) {
      try {
        connection.output.add(utf8.encode(text + "\r\n"));
        await connection.output.allSent;
      } catch (e) {}
    }
  }
}
