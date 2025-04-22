// report_generator.dart
import 'package:flutter/material.dart';

class ReportGenerator {
  static Future<List<Map<String, dynamic>>> generateReport({
    required String reportType,
    DateTimeRange? dateRange,
    required Set<String> selectedBarangays,
    required Set<String> selectedSectors,
    required Set<String> selectedCrops,
    required Set<String> selectedFarms,
  }) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate API delay

    // Generate different data based on report type
    switch (reportType) {
      case 'farmers':
        return _generateFarmersData();
      case 'farms':
        return _generateFarmsData();
      case 'crops':
        return _generateCropsData();
      case 'barangay':
        return _generateBarangayData();
      case 'sectors':
        return _generateSectorsData();
      default:
        return [];
    }
  }

  static List<Map<String, dynamic>> _generateFarmersData() {
    final barangays = ['Brgy. 1', 'Brgy. 2', 'Brgy. 3', 'Brgy. 4'];
    final sectors = [
      'Fisherfolk',
      'Farmers',
      'Livestock',
      'Agri-Entrepreneurs'
    ];
    final farms = ['Farm A', 'Farm B', 'Farm C', 'Farm D'];
    final products = ['Rice', 'Corn', 'Vegetables', 'Fish', 'Poultry'];

    return List.generate(15, (index) {
      final barangay = barangays[index % barangays.length];
      final sector = sectors[index % sectors.length];

      return {
        'Name': 'Farmer ${String.fromCharCode(65 + index)}',
        'Contact': '09${index + 10}${index + 20}${index + 30}${index + 40}',
        'Barangay': barangay,
        'Sector': sector,
        'Farms': [farms[index % farms.length]],
        'Products': [products[index % products.length]],
        'Membership': ['Coop A', 'Coop B', 'None'][index % 3],
        'Status': ['Active', 'Inactive'][index % 2]
      };
    });
  }

  static List<Map<String, dynamic>> _generateFarmsData() {
    final barangays = ['Brgy. 1', 'Brgy. 2', 'Brgy. 3', 'Brgy. 4'];
    final farmTypes = ['Crop Farm', 'Fish Farm', 'Livestock Farm', 'Mixed'];
    final owners = ['Farmer A', 'Farmer B', 'Farmer C', 'Farmer D'];

    return List.generate(10, (index) {
      return {
        'Farm Name': 'Farm ${String.fromCharCode(65 + index)}',
        'Owner': owners[index % owners.length],
        'Barangay': barangays[index % barangays.length],
        'Farm Type': farmTypes[index % farmTypes.length],
        'Area (ha)': (5 + (index % 10)).toString(),
        'Primary Crop': ['Rice', 'Corn', 'Vegetables', 'Fish'][index % 4],
        'Status': ['Active', 'Inactive'][index % 2],
        'Establishment Year': (2010 + index % 10).toString(),
      };
    });
  }

  static List<Map<String, dynamic>> _generateCropsData() {
    final crops = ['Rice', 'Corn', 'Vegetables', 'Fruits', 'Root Crops'];
    final farms = ['Farm A', 'Farm B', 'Farm C', 'Farm D'];
    final barangays = ['Brgy. 1', 'Brgy. 2', 'Brgy. 3', 'Brgy. 4'];
    final farmers = ['Farmer A', 'Farmer B', 'Farmer C', 'Farmer D'];

    return List.generate(20, (index) {
      final plantingDate =
          DateTime.now().subtract(Duration(days: 120 + index * 5));
      final harvestDate = plantingDate.add(Duration(days: 90 + index % 30));
      final yield = 1000 + (index % 10) * 200;
      final price = [20, 25, 30, 35, 40][index % 5].toDouble();

      return {
        'Crop': crops[index % crops.length],
        'Variety':
            '${crops[index % crops.length].substring(0, 3)}-${index % 10 + 1}',
        'Planting Date': plantingDate.toString(),
        'Harvest Date': harvestDate.toString(),
        'Yield (kg/ha)': yield.toString(),
        'Farm': farms[index % farms.length],
        'Barangay': barangays[index % barangays.length],
        'Farmer': farmers[index % farmers.length],
      };
    });
  }

  static List<Map<String, dynamic>> _generateBarangayData() {
    final barangays = ['Brgy. 1', 'Brgy. 2', 'Brgy. 3', 'Brgy. 4'];
    final sectors = [
      'Fisherfolk',
      'Farmers',
      'Livestock',
      'Agri-Entrepreneurs'
    ];

    return barangays.map((barangay) {
      final index = barangays.indexOf(barangay);
      return {
        'Barangay': barangay,
        'Total Farmers': (50 + index * 20).toString(),
        'Total Farms': (10 + index * 5).toString(),
        'Primary Sector': sectors[index % sectors.length],
        'Main Crops': ['Rice', 'Corn', 'Vegetables'][index % 3],
        'Average Yield': (1000 + index * 200).toString(),
      };
    }).toList();
  }

  static List<Map<String, dynamic>> _generateSectorsData() {
    final sectors = [
      'Fisherfolk',
      'Farmers',
      'Livestock',
      'Agri-Entrepreneurs'
    ];
    final barangays = ['Brgy. 1', 'Brgy. 2', 'Brgy. 3', 'Brgy. 4'];

    return sectors.map((sector) {
      final index = sectors.indexOf(sector);
      return {
        'Sector': sector,
        'Number of Members': (30 + index * 15).toString(),
        'Total Production': (1000 + index * 500).toString(),
      };
    }).toList();
  }

  static String buildReportTitle(String reportType, DateTimeRange dateRange) {
    String title =
        '${reportType[0].toUpperCase()}${reportType.substring(1)} Report';
    title += ' from ${dateRange.start.toLocal().toString().split(' ')[0]}';
    title += ' to ${dateRange.end.toLocal().toString().split(' ')[0]}';
    return title;
  }
}
