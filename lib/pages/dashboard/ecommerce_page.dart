import 'package:flareline/pages/dashboard/analytics_widget.dart';
import 'package:flareline/pages/dashboard/channel_widget.dart';
import 'package:flareline/pages/dashboard/grid_card.dart';
import 'package:flareline/pages/dashboard/map/map_chart_widget.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flutter/material.dart';
import 'package:flareline/pages/layout.dart';

import 'revenue_widget.dart';

class EcommercePage extends LayoutWidget {
  const EcommercePage({super.key});

  @override
  String breakTabTitle(BuildContext context) {
    return 'Home';
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return Column(
      children: [
        const GridCard(),
        const SizedBox(
          height: 16,
        ),
        const AnalyticsWidget(),
        const SizedBox(
          height: 30,
        ),
        const SizedBox(height: 20),
        RevenueWidget(),
        SizedBox(
          height: 16,
        ),
        ChannelWidget(),
        const SizedBox(
          height: 30,
        ),
        SizedBox(
          height: 700, // Fixed height
          child: CommonCard(
            child: ConstrainedBox(
              constraints: BoxConstraints.expand(), // Takes all available space
              child: MapChartWidget(),
            ),
          ),
        )
      ],
    );
  }
}
