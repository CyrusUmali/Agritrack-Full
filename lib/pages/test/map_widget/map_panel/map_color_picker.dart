import 'package:flutter/material.dart';

class ColorPickerButton extends StatelessWidget {
  final Color selectedColor;
  final VoidCallback onColorPicked;

  const ColorPickerButton({
    Key? key,
    required this.selectedColor,
    required this.onColorPicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Select Polygon Color:", style: TextStyle(fontSize: 16)),
        GestureDetector(
          onTap: onColorPicked,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: selectedColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }
}
