import 'package:esp32_dslr_assistant_flutter/models/BrowserModel.dart';
import 'package:flutter/material.dart';
import 'package:esp32_dslr_assistant_flutter/Pages/PersoPage.dart';
import 'package:esp32_dslr_assistant_flutter/models/DslrSettingsProvider.dart';
import 'package:esp32_dslr_assistant_flutter/models/FocusModel.dart';
import 'package:esp32_dslr_assistant_flutter/models/HdrModel.dart';
import 'package:esp32_dslr_assistant_flutter/models/LiveViewProvider.dart';
import 'package:esp32_dslr_assistant_flutter/models/LiveViewLongExpoModel.dart';
import 'package:image/image.dart';
import 'package:provider/provider.dart';

import 'models/BluetoothProvider.dart';

void main() => runApp(new ExampleApplication());

class ExampleApplication extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DslrSettingsProvider()),
        ChangeNotifierProvider(create: (context) => LiveViewProvider()),
        ChangeNotifierProvider(create: (context) => LiveViewLongExpoModel()),
        ChangeNotifierProvider(create: (context) => HdrModel()),
        ChangeNotifierProvider(create: (context) => FocusModel()),
        ChangeNotifierProvider(create: (context) => BrowserModel()),
        ChangeNotifierProxyProvider3<DslrSettingsProvider, LiveViewProvider,
            BrowserModel, BluetoothProvider>(
          create: (context) => BluetoothProvider(),
          update: (context, dslrSettings, liveViewProvider, browserModel,
              bluetooth) {
            if (bluetooth == null) throw ArgumentError.notNull('bluetooth');
            bluetooth.dslrSettings = dslrSettings;
            bluetooth.liveViewProvider = liveViewProvider;
            bluetooth.browserModel = browserModel;
            return bluetooth;
          },
        ),
      ],
      child: MaterialApp(
        home: PersoPage(),
      ),
    );
  }
}
