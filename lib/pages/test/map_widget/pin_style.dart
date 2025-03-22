import 'package:flutter/material.dart';

enum PinStyle {
  rice,
  corn,
  highValueCrop,
  livestock,
  fishery,
  organic,
}

Widget getPinIcon(PinStyle pinStyle) {
  switch (pinStyle) {
    case PinStyle.rice:
      return Icon(Icons.rice_bowl, color: Colors.white);
    case PinStyle.corn:
      return Icon(Icons.eco, color: Colors.yellow);
    case PinStyle.highValueCrop:
      return Icon(Icons.attach_money, color: Colors.green);
    case PinStyle.livestock:
      return Icon(Icons.pets, color: Colors.brown);
    case PinStyle.fishery:
      return Icon(Icons.water, color: Colors.blue);
    case PinStyle.organic:
      return Icon(Icons.spa, color: Colors.green);
  }
}

/// Converts a string to a PinStyle enum value
PinStyle parsePinStyle(String pinStyle) {
  switch (pinStyle) {
    case 'rice':
      return PinStyle.rice;
    case 'corn':
      return PinStyle.corn;
    case 'highValueCrop':
      return PinStyle.highValueCrop;
    case 'livestock':
      return PinStyle.livestock;
    case 'fishery':
      return PinStyle.fishery;
    case 'organic':
      return PinStyle.organic;
    default:
      return PinStyle.fishery; // Default to fishery if not found
  }
}
