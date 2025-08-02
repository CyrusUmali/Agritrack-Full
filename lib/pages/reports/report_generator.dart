// report_generator.dart
import 'dart:math';

import 'package:flareline/services/report_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReportGenerator {
  static Future<List<Map<String, dynamic>>> generateReport({
    required BuildContext context, // Add this parameter
    required String reportType,
    DateTimeRange? dateRange,
    required String selectedBarangay,
    required String selectedSector,
    required String selectedView,
    required String selectedProduct,
    required String selectedAssoc,
    required String selectedFarm,
    required String selectedCount,
    required selectedFarmer, // Added for farmer-specific reports
  }) async {
    await Future.delayed(
        const Duration(seconds: 2)); // Simulate API delay    print(reportType);
    // print(dateRange);
    // print(selectedBarangay);
    // print(selectedSector);
    // print(selectedProduct);

    // print("Selected assoc" + selectedAssoc);

    // print("reportType:" + reportType);
    // print(selectedFarm);
    // print(selectedFarmer);

    // Generate different data based on report type
    switch (reportType) {
      case 'farmers':
        return _generateFarmersData(
          context: context,
          selectedBarangay:
              selectedBarangay.isNotEmpty ? selectedBarangay : null,
          selectedSector: selectedSector.isNotEmpty ? selectedSector : null,
          selectedAssoc: selectedAssoc.isNotEmpty ? selectedAssoc : null,
          selectedCount: selectedCount.isNotEmpty ? selectedCount : null,
        );
      case 'farmer':
        return await _generateFarmerYieldData(
          context: context,
          farmerId: selectedFarmer.isNotEmpty ? selectedFarmer : null,
          productId: selectedProduct.isNotEmpty ? selectedProduct : null,
          farmId: selectedFarm.isNotEmpty ? selectedFarm : null,
          startDate: dateRange?.start.toString(),
          endDate: dateRange?.end.toString(),
          viewBy: selectedView.isNotEmpty ? selectedView : null,
          selectedAssoc: selectedAssoc.isNotEmpty ? selectedAssoc : null,
          selectedCount: selectedCount.isNotEmpty ? selectedCount : null,
        );
      case 'products':
        return await _generateProductsData(
          context: context,
          dateRange: dateRange,
          selectedBarangay: selectedBarangay,
          selectedSector: selectedSector,
          selectedView: selectedView,
          selectedProduct: selectedProduct,
          selectedCount: selectedCount.isNotEmpty ? selectedCount : null,
        );

      case 'barangay':
        return await _generateBarangayData(
          context: context,
          dateRange: dateRange,
          selectedBarangay: selectedBarangay,
          selectedSector: selectedSector,
          selectedView: selectedView,
          selectedProduct: selectedProduct,
          selectedCount: selectedCount.isNotEmpty ? selectedCount : null,
        );

      case 'sectors':
        return await _generateSectorsData(
          context: context,
          dateRange: dateRange,
          selectedSector: selectedSector,
          selectedView: selectedView,
          selectedCount: selectedCount.isNotEmpty ? selectedCount : null,
        );

      // case 'sectors':
      //   return _generateSectorsData();

      default:
        return [];
    }
  }

  static Future<List<Map<String, dynamic>>> _generateSectorsData({
    required BuildContext context,
    DateTimeRange? dateRange,
    String? selectedSector,
    String? selectedView,
    String? selectedCount,
  }) async {
    final reportService = RepositoryProvider.of<ReportService>(context);

    return await reportService.fetchSectorYields(
        viewBy: selectedView,
        sectorId: selectedSector,
        startDate: dateRange?.start.toString(),
        endDate: dateRange?.end.toString(),
        count: selectedCount);
  }

  static Future<List<Map<String, dynamic>>> _generateBarangayData({
    required BuildContext context,
    DateTimeRange? dateRange,
    String? selectedBarangay,
    String? selectedSector,
    String? selectedView,
    String? selectedProduct,
    String? selectedCount,
  }) async {
    final reportService = RepositoryProvider.of<ReportService>(context);

    return await reportService.fetchBarangayYields(
        viewBy: selectedView,
        productId: selectedProduct,
        sectorId: selectedSector,
        barangay: selectedBarangay,
        startDate: dateRange?.start.toString(),
        endDate: dateRange?.end.toString(),
        count: selectedCount);
  }

  static Future<List<Map<String, dynamic>>> _generateProductsData({
    required BuildContext context,
    DateTimeRange? dateRange,
    String? selectedBarangay,
    String? selectedSector,
    String? selectedView,
    String? selectedProduct,
    String? selectedCount,
  }) async {
    final reportService = RepositoryProvider.of<ReportService>(context);

    return await reportService.fetchProductYields(
        viewBy: selectedView,
        productId: selectedProduct,
        sectorId: selectedSector,
        startDate: dateRange?.start.toString(),
        endDate: dateRange?.end.toString(),
        count: selectedCount);
  }

  static Future<List<Map<String, dynamic>>> _generateFarmerYieldData({
    required BuildContext context,
    String? farmerId,
    String? productId,
    String? farmId,
    String? selectedAssoc,
    String? startDate,
    String? endDate,
    String? viewBy,
    String? selectedCount,
  }) async {
    final reportService = RepositoryProvider.of<ReportService>(context);
    return await reportService.fetchYields(
        farmerId: farmerId,
        productId: productId,
        farmId: farmId,
        startDate: startDate,
        endDate: endDate,
        association: selectedAssoc,
        viewBy: viewBy,
        count: selectedCount);
  }

  static Future<List<Map<String, dynamic>>> _generateFarmersData({
    required BuildContext context,
    String? selectedAssoc,
    String? selectedBarangay,
    String? selectedSector,
    String? selectedCount,
  }) async {
    try {
      final reportService = RepositoryProvider.of<ReportService>(context);
      final farmers = await reportService.fetchFarmers(
          association: selectedAssoc,
          barangay: selectedBarangay,
          sector: selectedSector,
          count: selectedCount);

      return farmers;
    } catch (e) {
      print('Error fetching farmers: $e');
      return []; // Return empty list on error
    }
  }

  static String buildReportTitle(String reportType, DateTimeRange dateRange) {
    String title =
        '${reportType[0].toUpperCase()}${reportType.substring(1).replaceAll('_', ' ')} Report';
    title += ' from ${dateRange.start.toLocal().toString().split(' ')[0]}';
    title += ' to ${dateRange.end.toLocal().toString().split(' ')[0]}';
    return title;
  }
}
