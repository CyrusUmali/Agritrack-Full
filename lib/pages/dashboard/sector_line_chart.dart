import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flareline_uikit/components/charts/line_chart.dart';

class SectorLineChart extends StatelessWidget {
  const SectorLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    // Only enable scrolling for screens smaller than this breakpoint
    final scrollBreakpoint = 600.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final needsScrolling = screenWidth < scrollBreakpoint;

    // Determine if we should use vertical layout for the header
    final useVerticalHeader = screenWidth < 450;

    return CommonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: useVerticalHeader
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Agricultural Performance',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.center,
                        child: _buildSectorDropdown(),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Agricultural Performance',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _buildSectorDropdown(),
                    ],
                  ),
          ),
          SizedBox(
            height: 165, // Adjust this based on your UI
            child: needsScrolling
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      width: scrollBreakpoint,
                      child: _buildLineChart(),
                    ),
                  )
                : _buildLineChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectorDropdown() {
    return PopupMenuButton<String>(
      initialValue: 'Rice',
      onSelected: (String value) {
        // Handle sector selection
      },
      itemBuilder: (BuildContext context) {
        return ['Rice', 'Corn', 'Coconut', 'Sugarcane', 'Banana', 'Livestock']
            .map((String item) {
          return PopupMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Rice'),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart() {
    return LineChartWidget(
      title: '',
      dropdownItems: [],
      datas: const [
        {
          'name': 'Yield (Metric Tons)',
          'color': Color(0xFFFE8111),
          'data': [
            {'x': '2018', 'y': 18},
            {'x': '2019', 'y': 22},
            {'x': '2020', 'y': 19},
            {'x': '2021', 'y': 25},
            {'x': '2022', 'y': 28},
            {'x': '2023', 'y': 32},
            {'x': '2024', 'y': 35},
          ]
        },
        {
          'name': 'Value (Million PHP)',
          'color': Color(0xFF01B7F9),
          'data': [
            {'x': '2018', 'y': 45},
            {'x': '2019', 'y': 52},
            {'x': '2020', 'y': 48},
            {'x': '2021', 'y': 62},
            {'x': '2022', 'y': 75},
            {'x': '2023', 'y': 85},
            {'x': '2024', 'y': 92},
          ]
        },
      ],
    );
  }
}
