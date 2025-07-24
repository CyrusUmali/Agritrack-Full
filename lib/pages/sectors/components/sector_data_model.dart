import 'package:flareline/core/models/yield_model.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class SectorData {
  final String name;
  final Color color;
  final List<Map<String, dynamic>> data;
  final Map<String, String>? annotations;

  SectorData({
    required this.name,
    required this.color,
    required this.data,
    this.annotations,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'color': color,
      'data': data,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'color': color.value.toRadixString(16),
      'data': data,
      'annotations': annotations,
    };
  }

  @override
  String toString() {
    return 'SectorData(name: $name, color: $color, data: $data, annotations: $annotations)';
  }
}

// Predefined color palette
const List<Color> predefinedColors = [
  Colors.blue,
  Colors.red,
  Colors.green,
  Colors.yellow,
  Colors.purple,
  Colors.orange,
  Colors.teal,
  Colors.pink,
  Colors.indigo,
  Colors.cyan,
  Colors.amber,
  Colors.lime,
  Colors.brown,
  Colors.grey,
  Colors.blueGrey,
];

Map<String, List<SectorData>> sectorData = {
  // We'll build this dynamically from yieldData
};

// Helper function to generate distinct colors
Color generateDistinctColor(Random random,
    {int saturation = 85, int lightness = 60}) {
  return HSLColor.fromAHSL(
    1.0,
    random.nextDouble() * 360, // Random hue
    saturation / 100,
    lightness / 100,
  ).toColor();
}

Map<String, List<SectorData>> buildSectorDataFromYields(List<Yield> yields) {
  final sectorMap = <String, List<SectorData>>{};
  final random = Random(42); // Seed for consistent colors
  int colorIndex = 0; // Index for predefined colors

  // First group by sector
  final yieldsBySector = <String, List<Yield>>{};
  for (final yield in yields) {
    final sector = yield.sector ?? 'Unknown';
    yieldsBySector.putIfAbsent(sector, () => []).add(yield);
  }

  // Then for each sector, group by product and create SectorData objects
  yieldsBySector.forEach((sector, sectorYields) {
    final productsMap =
        <String, Map<String, double>>{}; // product -> year -> total volume
    final productColors = <String, Color>{};

    // Group yields by product and aggregate by year
    for (final yield in sectorYields) {
      final productName = yield.productName ?? 'Unknown';
      final year = yield.harvestDate?.year.toString() ?? '2023';
      final volume = yield.volume ?? 0;

      // Initialize product map if not exists
      if (!productsMap.containsKey(productName)) {
        productsMap[productName] = {};

        // Assign color - first try predefined, then generate
        if (colorIndex < predefinedColors.length) {
          productColors[productName] = predefinedColors[colorIndex];
          colorIndex++;
        } else {
          productColors[productName] = generateDistinctColor(random);
        }
      }

      // Aggregate volumes by year
      productsMap[productName]!.update(
        year,
        (value) => value + volume,
        ifAbsent: () => volume,
      );
    }

    // Create SectorData objects for each product
    final sectorDataList = productsMap.entries.map((entry) {
      // Convert the year-volume map to data points
      final dataPoints = entry.value.entries.map((yearVolume) {
        return {
          'x': yearVolume.key,
          'y': yearVolume.value,
        };
      }).toList();

      // Sort by year in ascending order
      dataPoints.sort((a, b) {
        final aYear = int.tryParse(a['x']?.toString() ?? '0') ?? 0;
        final bYear = int.tryParse(b['x']?.toString() ?? '0') ?? 0;
        return aYear.compareTo(bYear);
      });

      return SectorData(
        name: entry.key,
        color: productColors[entry.key]!,
        data: dataPoints,
      );
    }).toList();

    sectorMap[sector] = sectorDataList;
  });

  return sectorMap;
}



// final Map<String, List<SectorData>> sectorData = {
//   'Rice': [
//     SectorData(
//         name: 'Rice',
//         color: const Color.fromARGB(255, 85, 255, 6),
//         data: [
//           {'x': '2018', 'y': 1500},
//           {'x': '2019', 'y': 1800},
//           {'x': '2020', 'y': 1600},
//           {'x': '2021', 'y': 2000},
//           {'x': '2022', 'y': 2200},
//           {'x': '2023', 'y': 2500},
//           {'x': '2024', 'y': 2800},
//         ]),
//   ],
//   'Corn': [
//     SectorData(
//       name: 'Corn',
//       color: const Color.fromARGB(255, 2, 255, 234),
//       data: [
//         {'x': '2018', 'y': 2000},
//         {'x': '2019', 'y': 2200},
//         {'x': '2020', 'y': 1800},
//         {'x': '2021', 'y': 2500},
//         {'x': '2022', 'y': 2800},
//         {'x': '2023', 'y': 3000},
//         {'x': '2024', 'y': 3200},
//         {'x': '2025', 'y': 3500},
//       ],
//     ),
//   ],
//   'Fishery': [
//     SectorData(
//       name: 'Tilapia',
//       color: const Color.fromARGB(255, 255, 1, 221),
//       data: [
//         {'x': '2010', 'y': 3000},
//         {'x': '2011', 'y': 3200},
//         {'x': '2012', 'y': 3500},
//         {'x': '2013', 'y': 3700},
//         {'x': '2014', 'y': 3900},
//         {'x': '2015', 'y': 2200},
//         {'x': '2016', 'y': 1500},
//         {'x': '2017', 'y': 2700},
//         {'x': '2018', 'y': 1000},
//         {'x': '2019', 'y': 500},
//         {'x': '2020', 'y': 1800},
//         {'x': '2021', 'y': 2000},
//         {'x': '2022', 'y': 2500},
//         {'x': '2023', 'y': 2000},
//         {'x': '2024', 'y': 2500},
//       ],
//     ),
//     SectorData(
//       name: 'Karpa',
//       color: const Color.fromARGB(255, 17, 60, 254),
//       data: [
//         {'x': '2010', 'y': 1000},
//         {'x': '2011', 'y': 1050},
//         {'x': '2012', 'y': 1100},
//         {'x': '2013', 'y': 1150},
//         {'x': '2014', 'y': 1200},
//         {'x': '2015', 'y': 1250},
//         {'x': '2016', 'y': 1300},
//         {'x': '2017', 'y': 1350},
//         {'x': '2018', 'y': 1400},
//         {'x': '2019', 'y': 1450},
//         {'x': '2020', 'y': 1500},
//         {'x': '2021', 'y': 1550},
//         {'x': '2022', 'y': 1600},
//         {'x': '2023', 'y': 1650},
//         {'x': '2024', 'y': 1700},
//       ],
//     ),
//     SectorData(
//       name: 'Bangus',
//       color: const Color.fromARGB(255, 54, 227, 20),
//       data: [
//         {'x': '2010', 'y': 1000},
//         {'x': '2011', 'y': 1100},
//         {'x': '2012', 'y': 1200},
//         {'x': '2013', 'y': 1300},
//         {'x': '2014', 'y': 1400},
//         {'x': '2015', 'y': 1500},
//         {'x': '2016', 'y': 1600},
//         {'x': '2017', 'y': 1700},
//         {'x': '2018', 'y': 1800},
//         {'x': '2019', 'y': 900},
//         {'x': '2020', 'y': 1600},
//         {'x': '2021', 'y': 1100},
//         {'x': '2022', 'y': 1200},
//         {'x': '2023', 'y': 1300},
//         {'x': '2024', 'y': 1400},
//       ],
//     ),
//     SectorData(
//       name: 'Pangasius',
//       color: const Color.fromARGB(255, 232, 9, 150),
//       data: [
//         {'x': '2010', 'y': 900},
//         {'x': '2011', 'y': 950},
//         {'x': '2012', 'y': 1000},
//         {'x': '2013', 'y': 1050},
//         {'x': '2014', 'y': 1100},
//         {'x': '2015', 'y': 1150},
//         {'x': '2016', 'y': 1200},
//         {'x': '2017', 'y': 1250},
//         {'x': '2018', 'y': 1300},
//         {'x': '2019', 'y': 1350},
//         {'x': '2020', 'y': 1400},
//         {'x': '2021', 'y': 1450},
//         {'x': '2022', 'y': 1500},
//         {'x': '2023', 'y': 1550},
//         {'x': '2024', 'y': 1600},
//       ],
//     ),
//     SectorData(
//       name: 'Hammerhead',
//       color: const Color.fromARGB(255, 239, 66, 18),
//       data: [
//         {'x': '2010', 'y': 100},
//         {'x': '2011', 'y': 110},
//         {'x': '2012', 'y': 120},
//         {'x': '2013', 'y': 130},
//         {'x': '2014', 'y': 140},
//         {'x': '2015', 'y': 150},
//         {'x': '2016', 'y': 160},
//         {'x': '2017', 'y': 170},
//         {'x': '2018', 'y': 180},
//         {'x': '2019', 'y': 190},
//         {'x': '2020', 'y': 200},
//         {'x': '2021', 'y': 210},
//         {'x': '2022', 'y': 220},
//         {'x': '2023', 'y': 230},
//         {'x': '2024', 'y': 240},
//       ],
//     ),
//   ],
//   'Livestock': [
//     SectorData(
//       name: 'cow',
//       color: const Color.fromARGB(255, 247, 255, 1),
//       data: [
//         {'x': '2018', 'y': 2200},
//         {'x': '2019', 'y': 2400},
//         {'x': '2020', 'y': 2100},
//         {'x': '2021', 'y': 2500},
//         {'x': '2022', 'y': 2700},
//         {'x': '2023', 'y': 2800},
//         {'x': '2024', 'y': 2900},
//         {'x': '2025', 'y': 2300},
//       ],
//     ),
//     SectorData(
//       name: 'carabao',
//       color: const Color(0xFFA5A5A5),
//       data: [
//         {'x': '2018', 'y': 1500},
//         {'x': '2019', 'y': 1600},
//         {'x': '2020', 'y': 1400},
//         {'x': '2021', 'y': 1700},
//         {'x': '2022', 'y': 1800},
//         {'x': '2023', 'y': 1900},
//         {'x': '2024', 'y': 2000},
//         {'x': '2025', 'y': 1550},
//       ],
//     ),
//     SectorData(
//       name: 'horse',
//       color: const Color(0xFF8B4513),
//       data: [
//         {'x': '2018', 'y': 1200},
//         {'x': '2019', 'y': 1300},
//         {'x': '2020', 'y': 1150},
//         {'x': '2021', 'y': 1400},
//         {'x': '2022', 'y': 1500},
//         {'x': '2023', 'y': 1600},
//         {'x': '2024', 'y': 1700},
//         {'x': '2025', 'y': 1250},
//       ],
//     ),
//     SectorData(
//       name: 'goat',
//       color: const Color(0xFFD2B48C),
//       data: [
//         {'x': '2018', 'y': 1800},
//         {'x': '2019', 'y': 1900},
//         {'x': '2020', 'y': 1700},
//         {'x': '2021', 'y': 2000},
//         {'x': '2022', 'y': 2100},
//         {'x': '2023', 'y': 2200},
//         {'x': '2024', 'y': 2300},
//         {'x': '2025', 'y': 1850},
//       ],
//     ),
//     SectorData(
//       name: 'sheep',
//       color: const Color(0xFFF5F5DC),
//       data: [
//         {'x': '2018', 'y': 1000},
//         {'x': '2019', 'y': 1100},
//         {'x': '2020', 'y': 950},
//         {'x': '2021', 'y': 1200},
//         {'x': '2022', 'y': 1300},
//         {'x': '2023', 'y': 1400},
//         {'x': '2024', 'y': 1500},
//         {'x': '2025', 'y': 1050},
//       ],
//     ),
//     SectorData(
//       name: 'chicken',
//       color: const Color(0xFFFFD700),
//       data: [
//         {'x': '2018', 'y': 2800},
//         {'x': '2019', 'y': 2900},
//         {'x': '2020', 'y': 2700},
//         {'x': '2021', 'y': 3000},
//         {'x': '2022', 'y': 3100},
//         {'x': '2023', 'y': 3200},
//         {'x': '2024', 'y': 3300},
//         {'x': '2025', 'y': 2850},
//       ],
//     ),
//     SectorData(
//       name: 'pig',
//       color: const Color(0xFFE6BCB5),
//       data: [
//         {'x': '2018', 'y': 2500},
//         {'x': '2019', 'y': 2600},
//         {'x': '2020', 'y': 2400},
//         {'x': '2021', 'y': 2700},
//         {'x': '2022', 'y': 2800},
//         {'x': '2023', 'y': 2900},
//         {'x': '2024', 'y': 3000},
//         {'x': '2025', 'y': 2550},
//       ],
//     ),
//     SectorData(
//       name: 'boar',
//       color: const Color(0xFF8B0000),
//       data: [
//         {'x': '2018', 'y': 800},
//         {'x': '2019', 'y': 900},
//         {'x': '2020', 'y': 750},
//         {'x': '2021', 'y': 1000},
//         {'x': '2022', 'y': 1100},
//         {'x': '2023', 'y': 1200},
//         {'x': '2024', 'y': 1300},
//         {'x': '2025', 'y': 850},
//       ],
//     ),
//   ],
//   'Organic': [
//     SectorData(
//       name: 'Organic Vegetables',
//       color: const Color.fromARGB(255, 78, 51, 109),
//       data: [
//         {'x': '2018', 'y': 1500},
//         {'x': '2019', 'y': 1800},
//         {'x': '2020', 'y': 1600},
//         {'x': '2021', 'y': 2000},
//         {'x': '2022', 'y': 2200},
//         {'x': '2023', 'y': 2500},
//         {'x': '2024', 'y': 2800},
//         {'x': '2025', 'y': 2500},
//       ],
//     ),
//   ],
//   'HVC': [
//     SectorData(
//       name: 'Mango',
//       color: const Color(0xFFFE8111),
//       data: [
//         {'x': '2018', 'y': 1500},
//         {'x': '2019', 'y': 1800},
//         {'x': '2020', 'y': 1200},
//         {'x': '2021', 'y': 2000},
//         {'x': '2022', 'y': 2500},
//         {'x': '2023', 'y': 2800},
//         {'x': '2024', 'y': 2900},
//         {'x': '2025', 'y': 2540},
//       ],
//     ),
//     SectorData(
//       name: 'ampalaya',
//       color: const Color(0xFF4CAF50),
//       data: [
//         {'x': '2018', 'y': 800},
//         {'x': '2019', 'y': 1000},
//         {'x': '2020', 'y': 700},
//         {'x': '2021', 'y': 1200},
//         {'x': '2022', 'y': 1500},
//         {'x': '2023', 'y': 1800},
//         {'x': '2024', 'y': 2000},
//         {'x': '2025', 'y': 900},
//       ],
//     ),
//     SectorData(
//       name: 'eggplant',
//       color: const Color(0xFF9C27B0),
//       data: [
//         {'x': '2018', 'y': 1200},
//         {'x': '2019', 'y': 1500},
//         {'x': '2020', 'y': 1000},
//         {'x': '2021', 'y': 1800},
//         {'x': '2022', 'y': 2200},
//         {'x': '2023', 'y': 2500},
//         {'x': '2024', 'y': 2700},
//         {'x': '2025', 'y': 1300},
//       ],
//     ),
//     SectorData(
//       name: 'okra',
//       color: const Color(0xFF2196F3),
//       data: [
//         {'x': '2018', 'y': 600},
//         {'x': '2019', 'y': 800},
//         {'x': '2020', 'y': 500},
//         {'x': '2021', 'y': 1000},
//         {'x': '2022', 'y': 1200},
//         {'x': '2023', 'y': 1500},
//         {'x': '2024', 'y': 1800},
//         {'x': '2025', 'y': 700},
//       ],
//     ),
//     SectorData(
//       name: 'squash',
//       color: const Color(0xFFFFC107),
//       data: [
//         {'x': '2018', 'y': 1000},
//         {'x': '2019', 'y': 1300},
//         {'x': '2020', 'y': 800},
//         {'x': '2021', 'y': 1500},
//         {'x': '2022', 'y': 1800},
//         {'x': '2023', 'y': 2100},
//         {'x': '2024', 'y': 2400},
//         {'x': '2025', 'y': 1100},
//       ],
//     ),
//     SectorData(
//       name: 'sitao',
//       color: const Color(0xFF795548),
//       data: [
//         {'x': '2018', 'y': 500},
//         {'x': '2019', 'y': 700},
//         {'x': '2020', 'y': 400},
//         {'x': '2021', 'y': 900},
//         {'x': '2022', 'y': 1100},
//         {'x': '2023', 'y': 1300},
//         {'x': '2024', 'y': 1500},
//         {'x': '2025', 'y': 600},
//       ],
//     ),
//     SectorData(
//       name: 'tomato',
//       color: const Color(0xFFF44336),
//       data: [
//         {'x': '2018', 'y': 1800},
//         {'x': '2019', 'y': 2100},
//         {'x': '2020', 'y': 1500},
//         {'x': '2021', 'y': 2400},
//         {'x': '2022', 'y': 2700},
//         {'x': '2023', 'y': 2900},
//         {'x': '2024', 'y': 3000},
//         {'x': '2025', 'y': 1900},
//       ],
//     ),
//     SectorData(
//       name: 'patola',
//       color: const Color(0xFF8BC34A),
//       data: [
//         {'x': '2018', 'y': 400},
//         {'x': '2019', 'y': 600},
//         {'x': '2020', 'y': 300},
//         {'x': '2021', 'y': 800},
//         {'x': '2022', 'y': 1000},
//         {'x': '2023', 'y': 1200},
//         {'x': '2024', 'y': 1400},
//         {'x': '2025', 'y': 500},
//       ],
//     ),
//     SectorData(
//       name: 'upo',
//       color: const Color(0xFF607D8B),
//       data: [
//         {'x': '2018', 'y': 300},
//         {'x': '2019', 'y': 500},
//         {'x': '2020', 'y': 200},
//         {'x': '2021', 'y': 700},
//         {'x': '2022', 'y': 900},
//         {'x': '2023', 'y': 1100},
//         {'x': '2024', 'y': 1300},
//         {'x': '2025', 'y': 400},
//       ],
//     ),
//     SectorData(
//       name: 'cucumber',
//       color: const Color(0xFF009688),
//       data: [
//         {'x': '2018', 'y': 700},
//         {'x': '2019', 'y': 900},
//         {'x': '2020', 'y': 600},
//         {'x': '2021', 'y': 1100},
//         {'x': '2022', 'y': 1300},
//         {'x': '2023', 'y': 1600},
//         {'x': '2024', 'y': 1900},
//         {'x': '2025', 'y': 800},
//       ],
//     ),
//   ],
// };