// File: new_page.dart
import 'package:flutter/material.dart';
import 'package:flareline/pages/layout.dart';
import 'map_widget/map_widget.dart';
// import 'map_widget/map_widget.dart';

class NewPage extends LayoutWidget {
  const NewPage({super.key});

  @override
  String breakTabTitle(BuildContext context) {
    return "";
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return const MapWidget();
  }

  @override
  EdgeInsetsGeometry? get customPadding => const EdgeInsets.only(top: 16);
}
