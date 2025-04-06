import 'package:flareline/pages/dashboard/analytics_widget.dart';
import 'package:flutter/material.dart';
import 'package:flareline/pages/dashboard/grid_card.dart';
import 'package:flareline/pages/dashboard/revenue_widget.dart';
import 'package:flareline/pages/dashboard/channel_widget.dart';
import 'package:flareline/pages/layout.dart';

class EcommercePage extends LayoutWidget {
  const EcommercePage({super.key});

  @override
  String breakTabTitle(BuildContext context) {
    return 'Home';
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return const Column(
      children: [
        GridCard(), // GridCard now includes AnalyticsWidget
        SizedBox(
          height: 16,
        ),

        AnalyticsWidget(),
        const SizedBox(height: 20),
        RevenueWidget(),
        SizedBox(
          height: 16,
        ),
        ChannelWidget(),
      ],
    );
  }
}
