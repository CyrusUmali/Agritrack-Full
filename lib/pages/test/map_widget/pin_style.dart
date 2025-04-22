import 'package:flutter/material.dart';
import 'package:iconify_flutter_plus/iconify_flutter_plus.dart';
import 'package:iconify_flutter_plus/icons/mdi.dart';

enum PinStyle {
  rice,
  corn,
  highvaluecrop,
  livestock,
  fishery,
  organic,
}

Widget getPinIcon(PinStyle pinStyle) {
  switch (pinStyle) {
    case PinStyle.rice:
      return const Iconify(Mdi.rice, color: Colors.white, size: 24);
    case PinStyle.corn:
      return const Iconify(Mdi.corn, color: Colors.white, size: 24);
    case PinStyle.highvaluecrop:
      return const Iconify(Mdi.fruit_grapes_outline,
          color: Color.fromARGB(255, 255, 255, 255), size: 24);
    case PinStyle.livestock:
      return const Iconify(Mdi.cow, color: Colors.white, size: 24);
    case PinStyle.fishery:
      return const Iconify(Mdi.fish,
          color: Color.fromARGB(255, 255, 255, 255), size: 24);
    case PinStyle.organic:
      return const Iconify(Mdi.leaf, color: Colors.white, size: 24);
  }
}

Color getPinColor(PinStyle pinStyle) {
  switch (pinStyle) {
    case PinStyle.rice:
      return Colors.grey;
    case PinStyle.corn:
      return Colors.yellow;
    case PinStyle.highvaluecrop:
      return Colors.orange;
    case PinStyle.livestock:
      return Colors.brown;
    case PinStyle.fishery:
      return Colors.blue;
    case PinStyle.organic:
      return Colors.green;
  }
}

PinStyle parsePinStyle(String pinStyle) {
  switch (pinStyle.toLowerCase()) {
    // Case-insensitive matching
    case 'rice':
      return PinStyle.rice;
    case 'corn':
      return PinStyle.corn;
    case 'highvaluecrop':
      return PinStyle.highvaluecrop;
    case 'livestock':
      return PinStyle.livestock;
    case 'fishery':
      return PinStyle.fishery;
    case 'organic':
      return PinStyle.organic;
    default:
      return PinStyle.fishery;
  }
}
