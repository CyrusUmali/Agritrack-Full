import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flareline_uikit/components/charts/line_chart.dart';

class SectorLineChart extends StatefulWidget {
  const SectorLineChart({super.key});

  @override
  State<SectorLineChart> createState() => _SectorLineChartState();
}

class _SectorLineChartState extends State<SectorLineChart> {
  String selectedSector = 'Rice';

  // Data structure for different sectors
  final Map<String, List<Map<String, dynamic>>> sectorData = {
    'Rice': [
      {
        'name': 'Jasmine Rice',
        'color': const Color(0xFFFE8111),
        'data': [
          {'x': '2018', 'y': 15},
          {'x': '2019', 'y': 18},
          {'x': '2020', 'y': 16},
          {'x': '2021', 'y': 20},
          {'x': '2022', 'y': 22},
          {'x': '2023', 'y': 25},
          {'x': '2024', 'y': 28},
        ]
      },
      {
        'name': 'Basmati Rice',
        'color': const Color(0xFF01B7F9),
        'data': [
          {'x': '2018', 'y': 12},
          {'x': '2019', 'y': 14},
          {'x': '2020', 'y': 13},
          {'x': '2021', 'y': 16},
          {'x': '2022', 'y': 18},
          {'x': '2023', 'y': 20},
          {'x': '2024', 'y': 22},
        ]
      },
      {
        'name': 'Brown Rice',
        'color': const Color(0xFFA4D96C),
        'data': [
          {'x': '2018', 'y': 8},
          {'x': '2019', 'y': 10},
          {'x': '2020', 'y': 9},
          {'x': '2021', 'y': 12},
          {'x': '2022', 'y': 14},
          {'x': '2023', 'y': 16},
          {'x': '2024', 'y': 18},
        ]
      },
    ],
    'Corn': [
      {
        'name': 'Sweet Corn',
        'color': const Color(0xFFFE8111),
        'data': [
          {'x': '2018', 'y': 20},
          {'x': '2019', 'y': 22},
          {'x': '2020', 'y': 18},
          {'x': '2021', 'y': 25},
          {'x': '2022', 'y': 28},
          {'x': '2023', 'y': 30},
          {'x': '2024', 'y': 32},
        ]
      },
      {
        'name': 'Field Corn',
        'color': const Color(0xFF01B7F9),
        'data': [
          {'x': '2018', 'y': 25},
          {'x': '2019', 'y': 28},
          {'x': '2020', 'y': 22},
          {'x': '2021', 'y': 30},
          {'x': '2022', 'y': 35},
          {'x': '2023', 'y': 38},
          {'x': '2024', 'y': 40},
        ]
      },
    ],
    'Fishery': [
      {
        'name': 'Tilapia',
        'color': const Color(0xFFFE8111),
        'data': [
          {'x': '2018', 'y': 50},
          {'x': '2019', 'y': 55},
          {'x': '2020', 'y': 48},
          {'x': '2021', 'y': 60},
          {'x': '2022', 'y': 65},
          {'x': '2023', 'y': 70},
          {'x': '2024', 'y': 75},
        ]
      },
      {
        'name': 'Bangus',
        'color': const Color(0xFF01B7F9),
        'data': [
          {'x': '2018', 'y': 40},
          {'x': '2019', 'y': 45},
          {'x': '2020', 'y': 38},
          {'x': '2021', 'y': 50},
          {'x': '2022', 'y': 55},
          {'x': '2023', 'y': 60},
          {'x': '2024', 'y': 65},
        ]
      },
      {
        'name': 'Shrimp',
        'color': const Color(0xFFA4D96C),
        'data': [
          {'x': '2018', 'y': 30},
          {'x': '2019', 'y': 35},
          {'x': '2020', 'y': 28},
          {'x': '2021', 'y': 40},
          {'x': '2022', 'y': 45},
          {'x': '2023', 'y': 50},
          {'x': '2024', 'y': 55},
        ]
      },
    ],
    'Livestock': [
      {
        'name': 'Poultry',
        'color': const Color(0xFFFE8111),
        'data': [
          {'x': '2018', 'y': 120},
          {'x': '2019', 'y': 130},
          {'x': '2020', 'y': 115},
          {'x': '2021', 'y': 140},
          {'x': '2022', 'y': 150},
          {'x': '2023', 'y': 160},
          {'x': '2024', 'y': 170},
        ]
      },
      {
        'name': 'Swine',
        'color': const Color(0xFF01B7F9),
        'data': [
          {'x': '2018', 'y': 80},
          {'x': '2019', 'y': 90},
          {'x': '2020', 'y': 75},
          {'x': '2021', 'y': 95},
          {'x': '2022', 'y': 105},
          {'x': '2023', 'y': 115},
          {'x': '2024', 'y': 125},
        ]
      },
      {
        'name': 'Cattle',
        'color': const Color(0xFFA4D96C),
        'data': [
          {'x': '2018', 'y': 50},
          {'x': '2019', 'y': 55},
          {'x': '2020', 'y': 48},
          {'x': '2021', 'y': 60},
          {'x': '2022', 'y': 65},
          {'x': '2023', 'y': 70},
          {'x': '2024', 'y': 75},
        ]
      },
    ],
    'Organic': [
      {
        'name': 'Organic Rice',
        'color': const Color(0xFFFE8111),
        'data': [
          {'x': '2018', 'y': 10},
          {'x': '2019', 'y': 12},
          {'x': '2020', 'y': 11},
          {'x': '2021', 'y': 14},
          {'x': '2022', 'y': 16},
          {'x': '2023', 'y': 18},
          {'x': '2024', 'y': 20},
        ]
      },
      {
        'name': 'Organic Vegetables',
        'color': const Color(0xFF01B7F9),
        'data': [
          {'x': '2018', 'y': 15},
          {'x': '2019', 'y': 18},
          {'x': '2020', 'y': 16},
          {'x': '2021', 'y': 20},
          {'x': '2022', 'y': 22},
          {'x': '2023', 'y': 25},
          {'x': '2024', 'y': 28},
        ]
      },
    ],
    'HVC': [
      {
        'name': 'Mango',
        'color': const Color(0xFFFE8111),
        'data': [
          {'x': '2018', 'y': 25},
          {'x': '2019', 'y': 28},
          {'x': '2020', 'y': 22},
          {'x': '2021', 'y': 30},
          {'x': '2022', 'y': 35},
          {'x': '2023', 'y': 40},
          {'x': '2024', 'y': 45},
        ]
      },
      {
        'name': 'Banana',
        'color': const Color(0xFF01B7F9),
        'data': [
          {'x': '2018', 'y': 30},
          {'x': '2019', 'y': 35},
          {'x': '2020', 'y': 28},
          {'x': '2021', 'y': 40},
          {'x': '2022', 'y': 45},
          {'x': '2023', 'y': 50},
          {'x': '2024', 'y': 55},
        ]
      },
      {
        'name': 'Coffee',
        'color': const Color(0xFFA4D96C),
        'data': [
          {'x': '2018', 'y': 15},
          {'x': '2019', 'y': 18},
          {'x': '2020', 'y': 16},
          {'x': '2021', 'y': 20},
          {'x': '2022', 'y': 22},
          {'x': '2023', 'y': 25},
          {'x': '2024', 'y': 28},
        ]
      },
    ],
  };

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
            height: 300, // Adjust this based on your UI
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
      initialValue: selectedSector,
      onSelected: (String value) {
        setState(() {
          selectedSector = value;
        });
      },
      itemBuilder: (BuildContext context) {
        return ['Rice', 'Corn', 'Fishery', 'Livestock', 'Organic', 'HVC']
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
            Text(selectedSector),
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
      datas: sectorData[selectedSector] ?? [],
    );
  }
}
