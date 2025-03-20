import 'package:flareline/core/theme/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flareline_uikit/components/charts/circular_chart.dart';
// import 'package:flareline/components/charts/map_chart.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:flareline/pages/dashboard/climate_widget.dart';

class AnalyticsWidget extends StatelessWidget {
  const AnalyticsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return _analytics();
  }

  _analytics() {
    return ScreenTypeLayout.builder(
      desktop: _analyticsWeb,
      mobile: _analyticsMobile,
      tablet: _analyticsMobile,
    );
  }

  Widget _analyticsWeb(BuildContext context) {
    return SizedBox(
      height: 268,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: CommonCard(
              child: CircularhartWidget(
                title: 'Farmer Distribution',
                palette: const [
                  GlobalColors.warn,
                  GlobalColors.secondary,
                  GlobalColors.primary,
                  GlobalColors.success,
                  GlobalColors.danger,
                  GlobalColors.dark
                ],
                chartData: const [
                  {
                    'x': 'Rice',
                    'y': 20,
                  },
                  {
                    'x': 'Corn',
                    'y': 20,
                  },
                  {
                    'x': 'Fishery',
                    'y': 20,
                  },
                  {
                    'x': 'High Value Crops',
                    'y': 10,
                  },
                  {
                    'x': 'Organic',
                    'y': 10,
                  },
                  {
                    'x': 'Livestock',
                    'y': 20,
                  },
                ],
              ),
            ),
          ),

          const SizedBox(
            width: 16,
          ),

          Expanded(
            flex: 4,
            child: CommonCard(
              child: const ClimateInfoWidget(),
            ),
          ),

          // Expanded(
          //   flex: 4,
          //   child: CommonCard(
          //     child: const MapChartWidget(),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _analyticsMobile(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 350,
          child: CommonCard(
            child: CircularhartWidget(
              title: 'Visitors Analytics',
              palette: const [
                GlobalColors.warn,
                GlobalColors.secondary,
                GlobalColors.primary,
                GlobalColors.success,
                GlobalColors.danger,
                GlobalColors.dark
              ],
              chartData: const [
                {
                  'x': 'Rice',
                  'y': 20,
                },
                {
                  'x': 'Corn',
                  'y': 20,
                },
                {
                  'x': 'Fishery',
                  'y': 20,
                },
                {
                  'x': 'High Value Crops',
                  'y': 10,
                },
                {
                  'x': 'Organic',
                  'y': 10,
                },
                {
                  'x': 'Livestock',
                  'y': 20,
                },
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        // SizedBox(
        //   height: 350,
        //   child: CommonCard(
        //     child: const MapChartWidget(),
        //   ),
        // ),

        SizedBox(
          height: 350,
          child: CommonCard(
            child: const ClimateInfoWidget(),
          ),
        ),
      ],
    );
  }
}
