// new_page.dart
import 'package:flutter/material.dart';
import 'package:flareline/pages/layout.dart';
import 'map_widget/map_widget.dart';

class NewPage extends LayoutWidget {
  const NewPage({super.key, required this.routeObserver});

  final RouteObserver<PageRoute> routeObserver;

  @override
  String breakTabTitle(BuildContext context) {
    return "";
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return MapWidget(routeObserver: routeObserver);
  }

  @override
  EdgeInsetsGeometry? get customPadding => const EdgeInsets.only(top: 16);
}
