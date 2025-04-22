import 'package:flareline/pages/reports/chart_data_provider.dart';
import 'package:flareline/pages/reports/report_charts.dart';
import 'package:flutter/material.dart';
import 'package:flareline/pages/layout.dart';
import 'package:flareline/core/theme/global_colors.dart';
import 'package:flareline/flutter_gen/app_localizations.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'report_filter_panel.dart';
import 'report_preview.dart';
import 'report_export.dart';
import 'report_generator.dart';

class ReportsPage extends LayoutWidget {
  const ReportsPage({super.key});

  @override
  String breakTabTitle(BuildContext context) {
    return "Reports";
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return const ReportContent();
  }
}

class ReportContent extends StatefulWidget {
  const ReportContent({super.key});

  @override
  State<ReportContent> createState() => _ReportContentState();
}

class _ReportContentState extends State<ReportContent> {
  // Filter state
  DateTimeRange dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );
  Set<String> selectedBarangay = {};
  Set<String> selectedSector = {};
  Set<String> selectedCrop = {};
  Set<String> selectedFarm = {};
  String reportType = 'farmers';
  String outputFormat = 'table';
  Set<String> selectedColumns = {};
  bool isLoading = false;
  List<Map<String, dynamic>> reportData = [];
  List<Map<String, dynamic>> filteredReportData = []; // For search results
  String searchQuery = ''; // Search query state

  Future<void> generateReport() async {
    setState(() => isLoading = true);

    final data = await ReportGenerator.generateReport(
      reportType: reportType,
      dateRange: dateRange,
      selectedBarangays: selectedBarangay,
      selectedSectors: selectedSector,
      selectedCrops: selectedCrop,
      selectedFarms: selectedFarm,
    );

    // Auto-select all columns if none are selected
    if (selectedColumns.isEmpty && data.isNotEmpty) {
      selectedColumns = data.first.keys.toSet();
    }

    setState(() {
      reportData = data;
      filteredReportData = data; // Initialize filtered data with all data
      isLoading = false;
    });
  }

  // Search function
  void searchReports(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredReportData = reportData;
      } else {
        filteredReportData = reportData.where((report) {
          // Search in all fields of the report
          return report.values.any((value) {
            return value.toString().toLowerCase().contains(query.toLowerCase());
          });
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final availableHeight = screenHeight * 0.7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReportFilterPanel(
          dateRange: dateRange,
          onDateRangeChanged: (newRange) =>
              setState(() => dateRange = newRange),
          selectedBarangays: selectedBarangay,
          onBarangaysChanged: (newValue) =>
              setState(() => selectedBarangay = newValue),
          selectedSectors: selectedSector,
          onSectorsChanged: (newValue) =>
              setState(() => selectedSector = newValue),
          selectedCrops: selectedCrop,
          onCropsChanged: (newValue) => setState(() => selectedCrop = newValue),
          selectedFarms: selectedFarm,
          onFarmsChanged: (newValue) => setState(() => selectedFarm = newValue),
          reportType: reportType,
          onReportTypeChanged: (newValue) {
            setState(() {
              reportType = newValue;
              selectedColumns = {}; // Reset selected columns
              reportData = [];
              filteredReportData = [];
              searchQuery = '';
            });
          },
          outputFormat: outputFormat,
          onOutputFormatChanged: (newValue) =>
              setState(() => outputFormat = newValue),
          selectedColumns: selectedColumns,
          onColumnsChanged: (newColumns) =>
              setState(() => selectedColumns = newColumns),
          onGeneratePressed: generateReport,
          isLoading: isLoading,
        ),
        const SizedBox(height: 16),
        if (reportData.isNotEmpty && !isLoading) ...[
          SizedBox(
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          ReportGenerator.buildReportTitle(
                              reportType, dateRange),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          'Generated on ${DateTime.now().toLocal().toString().split('.')[0]}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: searchReports, // Connect search function
                    ),
                    if (searchQuery.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Search results: ${filteredReportData.length} of ${reportData.length}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.clear, size: 16),
                            label: const Text('Clear Search'),
                            onPressed: () => searchReports(''),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: availableHeight,
            child: SingleChildScrollView(
              child: ReportPreview(
                reportData: filteredReportData, // Use filtered data
                reportType: reportType,
                outputFormat: outputFormat,
                selectedColumns: selectedColumns,
                isLoading: isLoading,
                dateRange: dateRange,
                selectedBarangay: selectedBarangay,
                selectedSector: selectedSector,
                selectedCropType: '',
                selectedFarmer: '',
              ),
            ),
          ),
          ReportExportOptions(
            reportType: reportType,
            reportData: filteredReportData, // Use filtered data for export
            selectedColumns: selectedColumns,
            dateRange: dateRange,
            context: context,
          ),
        ],
      ],
    );
  }

  void _exportReport(String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exporting to $format...')),
    );
  }
}
