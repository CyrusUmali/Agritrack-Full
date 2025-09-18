import 'package:file_saver/file_saver.dart';
import 'package:flareline/core/models/yield_model.dart';
import 'package:flareline/pages/toast/toast_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';

class YieldExportUtils {
  static Future<void> exportYieldDataToExcel({
    required BuildContext context,
    required List<Yield> yields,
    required String polygonName,
    required String selectedProduct,
    required bool isMonthlyView,
    required int selectedYear,
    required Function(String) showLoadingDialog,
    required Function() closeLoadingDialog,
  }) async {
    if (yields.isEmpty) {
      ToastHelper.showErrorToast('No data to export', context);
      return;
    }

    try {
      showLoadingDialog('Generating Excel file...');

      final excel = Excel.createExcel();
      final sheet = excel['Yield Report - $polygonName'];

      // Remove default sheet
      excel.delete('Sheet1');

      // Define styles
      final titleStyle = CellStyle(
        bold: true,
        fontFamily: getFontFamily(FontFamily.Arial),
        fontSize: 16,
        fontColorHex: ExcelColor.fromHexString('#3f51b5'),
      );

      final subtitleStyle = CellStyle(
        bold: true,
        fontFamily: getFontFamily(FontFamily.Arial),
        fontSize: 11,
        fontColorHex: ExcelColor.fromHexString('#333333'),
      );

      final headerStyle = CellStyle(
        bold: true,
        fontFamily: getFontFamily(FontFamily.Arial),
        fontSize: 10,
        fontColorHex: ExcelColor.white,
        backgroundColorHex: ExcelColor.fromHexString('#3f51b5'),
        horizontalAlign: HorizontalAlign.Center,
      );

      final dataStyle = CellStyle(
        fontFamily: getFontFamily(FontFamily.Arial),
        fontSize: 9,
        fontColorHex: ExcelColor.fromHexString('#333333'),
      );

      // Create report header
      int currentRow = 0;

      // Main title
      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
        ..value = TextCellValue('Yield Report - $polygonName')
        ..cellStyle = titleStyle;
      currentRow++;

      // Product and time period
      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
        ..value = TextCellValue('Product: $selectedProduct')
        ..cellStyle = subtitleStyle;
      currentRow++;

      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
        ..value = TextCellValue(
            'Period: ${isMonthlyView ? 'Monthly' : 'Yearly'} ${isMonthlyView ? selectedYear.toString() : ''}')
        ..cellStyle = subtitleStyle;
      currentRow++;

      // Generation date
      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
        ..value = TextCellValue(
            'Generated: ${DateFormat('MMM d, yyyy HH:mm').format(DateTime.now())}')
        ..cellStyle = subtitleStyle;
      currentRow += 2;

      // Prepare data based on view type
      final Map<String, Map<String, double>> data;
      final List<String> headers;

      if (isMonthlyView) {
        data = _prepareMonthlyData(yields, selectedProduct, selectedYear);
        headers = ['Month', 'Volume (kg)', 'Area Harvested (ha)'];
      } else {
        data = _prepareYearlyData(yields, selectedProduct);
        headers = ['Year', 'Volume (kg)', 'Area Harvested (ha)'];
      }

      // Add column headers
      for (int col = 0; col < headers.length; col++) {
        final cell = sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: col, rowIndex: currentRow));
        cell.value = TextCellValue(headers[col]);
        cell.cellStyle = headerStyle;
      }
      currentRow++;

      // Add data rows
      data.forEach((period, values) {
        sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
          ..value = TextCellValue(period)
          ..cellStyle = dataStyle;

        sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow))
          ..value = DoubleCellValue(values['volume'] ?? 0)
          ..cellStyle = CellStyle(
            fontFamily: getFontFamily(FontFamily.Arial),
            fontSize: 9,
            fontColorHex: ExcelColor.fromHexString('#333333'),
            horizontalAlign: HorizontalAlign.Right,
          );

        sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: currentRow))
          ..value = DoubleCellValue(values['areaHarvested'] ?? 0)
          ..cellStyle = CellStyle(
            fontFamily: getFontFamily(FontFamily.Arial),
            fontSize: 9,
            fontColorHex: ExcelColor.fromHexString('#333333'),
            horizontalAlign: HorizontalAlign.Right,
          );

        currentRow++;
      });

      // Auto-size columns
      _autoSizeColumns(sheet, headers);

      excel.setDefaultSheet(sheet.sheetName);
      final bytes = excel.save();
      closeLoadingDialog();

      if (bytes == null) {
        throw Exception('Failed to generate Excel file');
      }

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filename = 'yield_report_${polygonName}_$timestamp.xlsx'
          .replaceAll(' ', '_')
          .toLowerCase();

      await FileSaver.instance.saveFile(
        name: filename,
        bytes: Uint8List.fromList(bytes),
        ext: 'xlsx',
        mimeType: MimeType.microsoftExcel,
      );

      ToastHelper.showSuccessToast('Excel file exported successfully', context);
    } catch (e) {
      closeLoadingDialog();
      ToastHelper.showErrorToast(
          'Error exporting Excel: ${e.toString()}', context);
      debugPrint('Excel Export Error: $e');
    }
  }

  static Map<String, Map<String, double>> _prepareMonthlyData(
      List<Yield> yields, String product, int year) {
    final monthlyData = <String, Map<String, double>>{};
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    // Initialize all months
    for (final month in monthNames) {
      monthlyData[month] = {'volume': 0.0, 'areaHarvested': 0.0};
    }

    final relevantYields = yields.where((yield) {
      final yieldYear = yield.harvestDate?.year ?? DateTime.now().year;
      return yield.productName == product && yieldYear == year;
    });

    for (final yield in relevantYields) {
      final month = yield.harvestDate?.month ?? 1;
      final monthName = monthNames[month - 1];

      monthlyData[monthName]!['volume'] =
          (monthlyData[monthName]!['volume'] ?? 0) + (yield.volume ?? 0);

      if (yield.sectorId != 4) {
        // Exclude livestock
        monthlyData[monthName]!['areaHarvested'] =
            (monthlyData[monthName]!['areaHarvested'] ?? 0) +
                (yield.areaHarvested ?? 0);
      }
    }

    return monthlyData;
  }

  static Map<String, Map<String, double>> _prepareYearlyData(
      List<Yield> yields, String product) {
    final yearlyData = <String, Map<String, double>>{};
    final yearGroups = <int, List<Yield>>{};

    for (final yield in yields.where((y) => y.productName == product)) {
      final year = yield.harvestDate?.year ?? DateTime.now().year;
      yearGroups.putIfAbsent(year, () => []).add(yield);
    }

    for (final entry in yearGroups.entries) {
      final totalVolume = entry.value
          .fold<double>(0, (sum, yield) => sum + (yield.volume ?? 0));
      final totalAreaHarvested = entry.value
          .where((yield) => yield.sectorId != 4)
          .fold<double>(0, (sum, yield) => sum + (yield.areaHarvested ?? 0));

      yearlyData[entry.key.toString()] = {
        'volume': totalVolume,
        'areaHarvested': totalAreaHarvested,
      };
    }

    return yearlyData;
  }

  static void _autoSizeColumns(Sheet sheet, List<String> headers) {
    for (int colIndex = 0; colIndex < headers.length; colIndex++) {
      double maxWidth = headers[colIndex].length * 1.2;
      maxWidth = maxWidth.clamp(8, 35);

      try {
        sheet.setColumnWidth(colIndex, maxWidth);
      } catch (e) {
        debugPrint('Could not set column width: $e');
      }
    }
  }
}
