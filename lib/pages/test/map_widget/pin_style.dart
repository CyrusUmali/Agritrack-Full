import 'package:flutter/material.dart';
import 'package:iconify_flutter_plus/iconify_flutter_plus.dart';
import 'package:iconify_flutter_plus/icons/mdi.dart';

enum PinStyle {
  Rice,
  Corn,
  HVC,
  Livestock,
  Fishery,
  Organic,
}

int pinStyleToNumber(PinStyle pinStyle) {
  switch (pinStyle) {
    case PinStyle.Rice:
      return 1;
    case PinStyle.Corn:
      return 2;
    case PinStyle.HVC:
      return 3;
    case PinStyle.Livestock:
      return 4;
    case PinStyle.Fishery:
      return 5;
    case PinStyle.Organic:
      return 6;
  }
}

Color getPolygonColor(PinStyle pinStyle) {
  switch (pinStyle) {
    case PinStyle.Rice:
      return Colors.green.withOpacity(0.5);
    case PinStyle.Corn:
      return Colors.yellow.withOpacity(0.5);
    case PinStyle.HVC:
      return Colors.purple.withOpacity(0.5);
    case PinStyle.Livestock:
      return Colors.deepOrange.withOpacity(0.5);
    case PinStyle.Fishery:
      return Colors.blue.withOpacity(0.5);
    case PinStyle.Organic:
      return Colors.grey.withOpacity(0.5);
  }
}

Widget getPinIcon(PinStyle pinStyle) {
  switch (pinStyle) {
    case PinStyle.Rice:
      return const Iconify(Mdi.rice, color: Colors.white, size: 24);
    case PinStyle.Corn:
      return const Iconify(Mdi.corn, color: Colors.white, size: 24);
    case PinStyle.HVC:
      return const Iconify(Mdi.fruit_grapes_outline,
          color: Color.fromARGB(255, 255, 255, 255), size: 24);
    case PinStyle.Livestock:
      return const Iconify(Mdi.cow, color: Colors.white, size: 24);
    case PinStyle.Fishery:
      return const Iconify(Mdi.fish,
          color: Color.fromARGB(255, 255, 255, 255), size: 24);
    case PinStyle.Organic:
      return const Iconify(Mdi.leaf, color: Colors.white, size: 24);
  }
}

Color getPinColor(PinStyle pinStyle) {
  switch (pinStyle) {
    case PinStyle.Rice:
      return Colors.green;
    case PinStyle.Corn:
      return Colors.yellow;
    case PinStyle.HVC:
      return Colors.purple;
    case PinStyle.Livestock:
      return Colors.deepOrange;
    case PinStyle.Fishery:
      return Colors.blue;
    case PinStyle.Organic:
      return Colors.grey;
  }
}

PinStyle parsePinStyle(String pinStyle) {
  switch (pinStyle.toLowerCase()) {
    // Case-insensitive matching
    case 'Rice':
      return PinStyle.Rice;
    case 'Corn':
      return PinStyle.Corn;
    case 'HVC':
      return PinStyle.HVC;
    case 'Livestock':
      return PinStyle.Livestock;
    case 'Fishery':
      return PinStyle.Fishery;
    case 'Organic':
      return PinStyle.Organic;
    default:
      return PinStyle.Fishery;
  }
}
