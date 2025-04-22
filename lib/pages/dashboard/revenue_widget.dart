import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flareline/components/charts/bar_chart.dart';
import 'package:flareline_uikit/components/charts/line_chart.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'package:flareline/pages/sectors/sector_line_Chart.dart';
import 'package:flareline/pages/sectors/sector_bar_Chart.dart';

class RevenueWidget extends StatelessWidget {
  const RevenueWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return _revenueWidget();
  }

  Widget _revenueWidget() {
    return ScreenTypeLayout.builder(
      desktop: _revenueWidgetDesktop,
      mobile: _revenueWidgetMobile,
      tablet: _revenueWidgetMobile,
    );
  }

  Widget _revenueWidgetDesktop(BuildContext context) {
    return SizedBox(
      height: 500,
      child: Row(
        children: [
          Expanded(
            child: SectorLineChart(),
            flex: 2,
          ),
          const SizedBox(
            width: 16,
          ),
          Expanded(
            child: SectorBarChart(),
            flex: 1,
          ),
        ],
      ),
    );
  }

  Widget _revenueWidgetMobile(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 440,
          child: SectorLineChart(),
        ),
        const SizedBox(
          height: 16,
        ),
        SizedBox(
          height: 460,
          child: SectorBarChart(),
        ),
      ],
    );
  }

  _lineChart() {
    return CommonCard(
      child: LineChartWidget(
        title: 'Revenue',
        dropdownItems: ['Daily', 'Monthly', 'Yearly'],
        datas: const [
          {
            'name': 'Marketing Sales',
            'color': Color(0xFFFE8111),
            'data': [
              {'x': 'Jan', 'y': 25},
              {'x': 'Fed', 'y': 75},
              {'x': 'Mar', 'y': 28},
              {'x': 'Apr', 'y': 32},
              {'x': 'May', 'y': 40},
              {'x': 'Jun', 'y': 48},
              {'x': 'Jul', 'y': 44},
              {'x': 'Aug', 'y': 42},
              {'x': 'Sep', 'y': 70},
              {'x': 'Oct', 'y': 65},
              {'x': 'Nov', 'y': 55},
              {'x': 'Dec', 'y': 78}
            ]
          },
          {
            'name': 'Cases Sales',
            'color': Color(0xFF01B7F9),
            'data': [
              {'x': 'Jan', 'y': 70},
              {'x': 'Fed', 'y': 30},
              {'x': 'Mar', 'y': 66},
              {'x': 'Apr', 'y': 44},
              {'x': 'May', 'y': 55},
              {'x': 'Jun', 'y': 51},
              {'x': 'Jul', 'y': 44},
              {'x': 'Aug', 'y': 30},
              {'x': 'Sep', 'y': 100},
              {'x': 'Oct', 'y': 87},
              {'x': 'Nov', 'y': 77},
              {'x': 'Dec', 'y': 20}
            ]
          },
        ],
      ),
    );
  }

  _barChart() {
    return CommonCard(child: BarChartWidget());
  }
}
