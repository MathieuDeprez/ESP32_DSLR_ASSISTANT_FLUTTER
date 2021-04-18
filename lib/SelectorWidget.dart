import 'package:flutter/material.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';

typedef SelectorCallback = void Function(String aperture);

class SelectorWidget extends StatelessWidget {
  const SelectorWidget({
    this.onValueSelected,
    this.list,
    this.color,
    this.selectedValue,
    this.text,
  });

  final Color color;
  final List<String> list;
  final String selectedValue;
  final String text;

  final SelectorCallback onValueSelected;

  @override
  Widget build(BuildContext context) {
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
              onPrimary: color,
              elevation: 5,
              side: BorderSide(width: 1.0, color: color),
              // shape: RoundedRectangleBorder(
              //   borderRadius: BorderRadius.circular(0.0),
              // ),
            ),
            child: Text(selectedValue),
            onPressed: () => showMaterialScrollPicker(
              context: context,
              title: text,
              showDivider: false,
              items: list,
              selectedItem: selectedValue,
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
