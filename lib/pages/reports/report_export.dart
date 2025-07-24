import 'package:file_saver/file_saver.dart';
import 'package:flareline/pages/toast/toast_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:printing/printing.dart';
import 'dart:typed_data';

class ReportExportOptions extends StatelessWidget {
  final String reportType;
  final List<Map<String, dynamic>> reportData;
  final Set<String> selectedColumns;
  final DateTimeRange dateRange;
  final BuildContext context;

  const ReportExportOptions({
    super.key,
    required this.reportType,
    required this.reportData,
    required this.selectedColumns,
    required this.dateRange,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FilledButton.tonalIcon(
              onPressed: () => _exportToPDF(),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Export PDF'),
            ),
            const SizedBox(width: 8),
            FilledButton.tonalIcon(
              onPressed: () => _exportToExcel(),
              icon: const Icon(Icons.grid_on),
              label: const Text('Export Excel'),
            ),
            const SizedBox(width: 8),
            FilledButton.tonalIcon(
              onPressed: () => _printReport(),
              icon: const Icon(Icons.print),
              label: const Text('Print'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportToPDF() async {
    if (reportData.isEmpty) {
      ToastHelper.showErrorToast(
        'No data to export',
        context,
      );
      return;
    }

    try {
      _showLoadingDialog('Generating PDF...');

      // Create PDF document
      final pdf = pw.Document(
        title: '${reportType.capitalize()} Report',
      );

      // Add a page with the report content
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            // Prepare table data
            final headers = selectedColumns.toList();
            final data = reportData.map((row) {
              return headers.map((column) {
                final value = row[column];
                if (value == null) return '';
                if (value is List) return value.join(', ');
                if (value is DateTime)
                  return DateFormat('yyyy-MM-dd').format(value);
                return value.toString();
              }).toList();
            }).toList();

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Report header
                pw.Header(
                  level: 0,
                  child: pw.Text(
                    '${reportType.capitalize()} Report',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 10),
                // Date range information
                pw.Row(
                  children: [
                    pw.Text(
                      'Date Range: ',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      '${DateFormat('MMM d, yyyy').format(dateRange.start)} - '
                      '${DateFormat('MMM d, yyyy').format(dateRange.end)}',
                    ),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Generated on: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.SizedBox(height: 20),

                // Table with report data
                pw.Expanded(
                  child: pw.TableHelper.fromTextArray(
                    context: context,
                    headers: headers,
                    data: data,
                    headerDecoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#3f51b5'),
                    ),
                    headerStyle: pw.TextStyle(
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                    cellStyle: const pw.TextStyle(fontSize: 9),
                    cellPadding: const pw.EdgeInsets.all(4),
                    border: pw.TableBorder.all(
                      color: PdfColors.grey300,
                      width: 0.5,
                    ),
                    headerAlignment: pw.Alignment.centerLeft,
                    cellAlignment: pw.Alignment.centerLeft,
                    cellHeight: 20,
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Save and export the PDF
      final bytes = await pdf.save();
      _closeLoadingDialog();

      // Create filename
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filename = '${reportType}_report_$timestamp.pdf';

      // Save file using file_saver (works on both web and mobile)
      await FileSaver.instance.saveFile(
        name: filename,
        bytes: bytes,
        ext: 'pdf',
        mimeType: MimeType.pdf,
      );

      ToastHelper.showSuccessToast(
        'PDF exported successfully',
        context,
      );
    } catch (e) {
      _closeLoadingDialog();

      ToastHelper.showErrorToast(
          'Error exporting PDF: ${e.toString()}', context);

      debugPrint('PDF Export Error: $e');
    }
  }

  Future<void> _exportToExcel() async {
    if (reportData.isEmpty) {
      ToastHelper.showErrorToast(
        'No data to export',
        context,
      );
      return;
    }

    try {
      _showLoadingDialog('Generating Excel file...');

      // Create Excel instance and sheet
      final excel = Excel.createExcel();
      final sheet = excel['Report'];

      // Define header style
      final headerStyle = CellStyle(
        bold: true,
        fontFamily: getFontFamily(FontFamily.Arial),
      );

      // Add header row
      final headers = selectedColumns.toList();
      final headerRow = headers.map((h) => TextCellValue(h)).toList();
      sheet.appendRow(headerRow);

      // Style each header cell
      for (var i = 0; i < headers.length; i++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
            .cellStyle = headerStyle;
      }

      // Add data rows
      for (int rowIndex = 0; rowIndex < reportData.length; rowIndex++) {
        final row = reportData[rowIndex];
        final dataRow = selectedColumns.map((col) {
          final value = row[col];
          if (value == null) return TextCellValue('');
          if (value is List) return TextCellValue(value.join(', '));
          if (value is DateTime) {
            return TextCellValue(DateFormat('yyyy-MM-dd').format(value));
          }
          return TextCellValue(value.toString());
        }).toList();
        sheet.appendRow(dataRow);
      }

      // Set sheet as default
      excel.setDefaultSheet(sheet.sheetName);

      // Save Excel file
      final bytes = excel.save();
      _closeLoadingDialog();

      if (bytes == null) {
        throw Exception('Failed to generate Excel file');
      }

      // Create filename
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filename = '${reportType}_report_$timestamp.xlsx';

      // Save file using file_saver (works on both web and mobile)
      await FileSaver.instance.saveFile(
        name: filename,
        bytes: Uint8List.fromList(bytes),
        ext: 'xlsx',
        mimeType: MimeType.microsoftExcel,
      );

      ToastHelper.showSuccessToast(
        'Excel file exported successfully',
        context,
      );
    } catch (e) {
      _closeLoadingDialog();

      ToastHelper.showErrorToast(
        'Error exporting Excel: ${e.toString()}',
        context,
      );
      debugPrint('Excel Export Error: $e');
    }
  }

  Future<void> _printReport() async {
    if (reportData.isEmpty) {
      ToastHelper.showErrorToast('No data to print', context);

      return;
    }

    try {
      _showLoadingDialog('Preparing print...');

      // Create PDF document for printing
      final pdf = pw.Document(
        title: '${reportType.capitalize()} Report',
      );

      // Add a page with the report content
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            // Prepare table data
            final headers = selectedColumns.toList();
            final data = reportData.map((row) {
              return headers.map((column) {
                final value = row[column];
                if (value == null) return '';
                if (value is List) return value.join(', ');
                if (value is DateTime)
                  return DateFormat('yyyy-MM-dd').format(value);
                return value.toString();
              }).toList();
            }).toList();

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Report header
                pw.Header(
                  level: 0,
                  child: pw.Text(
                    '${reportType.capitalize()} Report',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 10),
                // Date range information
                pw.Row(
                  children: [
                    pw.Text(
                      'Date Range: ',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      '${DateFormat('MMM d, yyyy').format(dateRange.start)} - '
                      '${DateFormat('MMM d, yyyy').format(dateRange.end)}',
                    ),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Generated on: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.SizedBox(height: 20),

                // Table with report data
                pw.Expanded(
                  child: pw.TableHelper.fromTextArray(
                    context: context,
                    headers: headers,
                    data: data,
                    headerDecoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#3f51b5'),
                    ),
                    headerStyle: pw.TextStyle(
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                    cellStyle: const pw.TextStyle(fontSize: 9),
                    cellPadding: const pw.EdgeInsets.all(4),
                    border: pw.TableBorder.all(
                      color: PdfColors.grey300,
                      width: 0.5,
                    ),
                    headerAlignment: pw.Alignment.centerLeft,
                    cellAlignment: pw.Alignment.centerLeft,
                    cellHeight: 20,
                  ),
                ),
              ],
            );
          },
        ),
      );

      _closeLoadingDialog();

      // Print the PDF
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );

      ToastHelper.showSuccessToast('Print dialog opened', context);
    } catch (e) {
      _closeLoadingDialog();

      ToastHelper.showErrorToast(
        'Error printing report: ${e.toString()}',
        context,
      );

      debugPrint('Print Error: $e');
    }
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  void _closeLoadingDialog() {
    Navigator.of(context).pop();
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
