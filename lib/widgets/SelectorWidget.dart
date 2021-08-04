import 'package:flutter/material.dart';
import 'package:esp32_dslr_assistant_flutter/models/DslrSettingsProvider.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';

import '../Constants/MyColor.dart';

typedef SelectorCallback = void Function(String aperture);

class SelectorWidget extends StatelessWidget {
  /*const SelectorWidget({
    this.onValueSelected,
    this.list,
    this.color,
    this.selectedValue,
    this.text,
  });

  final Color color;
  final List<String> list;
  final String selectedValue;
  final String text;*/

  final SettingModel settingModel;
  final SelectorCallback onValueSelected;

  const SelectorWidget({this.settingModel, this.onValueSelected});

  @override
  Widget build(BuildContext context) {
    print("*** Selector Widget");
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 5,
          right: 5,
        ),
        child: Container(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.white,
              onPrimary: settingModel.color,
              elevation: 3,
              //side: BorderSide(width: 1.0, color: color),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            child: Text(
              settingModel.selectedValue,
              style: TextStyle(color: settingModel.color),
            ),
            onPressed: () => showMaterialScrollPicker(
              context: context,
              title: settingModel.title,
              showDivider: false,
              items: settingModel.listValue,
              selectedItem: settingModel.selectedValue,
              onChanged: (value) => onValueSelected(value),
              /*setState(() => selectedAperture = value),
              onCancelled: () => print("Scroll Picker cancelled"),
              onConfirmed: () => sendAperture("4"),*/
            ),
          ),
        ),
      ),
    );
  }
}
