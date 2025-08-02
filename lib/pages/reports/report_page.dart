import 'package:flareline/pages/toast/toast_helper.dart';
import 'package:flareline/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flareline/pages/layout.dart';
import 'package:provider/provider.dart';
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
    start: DateTime(1970), // Or any other "empty" marker date
    end: DateTime(1970),
  );

  String selectedBarangay = '';
  String selectedFarmer = '';
  String selectedView = '';
  String selectedCount = '';
  String selectedSector = '';
  String selectedProduct = '';
  String selectedAssoc = '';
  String selectedFarm = '';
  String reportType = 'farmer';
  String outputFormat = 'table';
  Set<String> selectedColumns = {};
  bool isLoading = false;
  List<Map<String, dynamic>> reportData = [];
  List<Map<String, dynamic>> filteredReportData = [];
  String searchQuery = '';
  // Add a key for the ReportPreview to force rebuild
  UniqueKey _previewKey = UniqueKey();

  Future<void> generateReport() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final _isFarmer = userProvider.isFarmer;
    final _farmerId = userProvider.farmer?.id;
    setState(() => isLoading = true);

    final data = await ReportGenerator.generateReport(
      context: context,
      reportType: reportType,
      dateRange: dateRange,
      selectedBarangay: selectedBarangay,
      selectedFarmer: _isFarmer ? _farmerId.toString() : selectedFarmer,
      selectedView: selectedView,
      selectedSector: selectedSector,
      selectedProduct: selectedProduct,
      selectedAssoc: selectedAssoc,
      selectedFarm: selectedFarm,
      selectedCount: selectedCount,
    );

    setState(() {
      reportData = data;
      filteredReportData = data;
      isLoading = false;
      // Reset the preview key to force rebuild
      _previewKey = UniqueKey();
      // Auto-select all columns if none are selected
      if (selectedColumns.isEmpty && data.isNotEmpty) {
        selectedColumns = data.first.keys.toSet();
      }
    });
  }

  void searchReports(String query) {
    setState(() {
      searchQuery = query;
      filteredReportData = query.isEmpty
          ? reportData
          : reportData.where((report) {
              return report.values.any((value) {
                return value
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase());
              });
            }).toList();
    });
  }

  void handleColumnsChanged(Set<String> newColumns) {
    setState(() => selectedColumns = newColumns);
  }

  void _handleItemsRemoved(List<int> indicesToRemove) {
    if (indicesToRemove.isEmpty) return;

    setState(() {
      // Create a new list to avoid mutating the current state directly
      final newFilteredData =
          List<Map<String, dynamic>>.from(filteredReportData);
      final newReportData = List<Map<String, dynamic>>.from(reportData);

      // Get the items to remove from filtered data
      final itemsToRemove = indicesToRemove
          .map((index) => newFilteredData[index])
          .where((item) => item != null)
          .toList();

      // Remove from both lists
      newFilteredData.removeWhere((item) => itemsToRemove.contains(item));
      newReportData.removeWhere((item) => itemsToRemove.contains(item));

      // Update state with new lists
      filteredReportData = newFilteredData;
      reportData = newReportData;

      // Force a rebuild of the preview
      _previewKey = UniqueKey();
    });

    ToastHelper.showSuccessToast(
        'Removed ${indicesToRemove.length} items', context);
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
          selectedBarangay: selectedBarangay,
          selectedView: selectedView,
          onViewChanged: (newValue) => setState(() => selectedView = newValue),
          selectedCount: selectedCount,
          onCountChanged: (newValue) =>
              setState(() => selectedCount = newValue),
          selectedFarmer: selectedFarmer,
          onFarmerChanged: (newValue) =>
              setState(() => selectedFarmer = newValue),
          onBarangayChanged: (newValue) =>
              setState(() => selectedBarangay = newValue),
          selectedSector: selectedSector,
          onSectorChanged: (newValue) =>
              setState(() => selectedSector = newValue),
          selectedProduct: selectedProduct,
          onProductChanged: (newValue) =>
              setState(() => selectedProduct = newValue),
          selectedAssoc: selectedAssoc,
          onAssocChanged: (newValue) =>
              setState(() => selectedAssoc = newValue),
          selectedFarm: selectedFarm,
          onFarmChanged: (newValue) => setState(() => selectedFarm = newValue),
          reportType: reportType,
          onReportTypeChanged: (newValue) {
            setState(() {
              reportType = newValue;
              // Reset all filter values
              dateRange = DateTimeRange(
                start: DateTime.now(),
                end: DateTime.now(),
              );
              selectedBarangay = '';
              selectedFarmer = '';
              selectedCount = '';
              selectedView = '';
              selectedSector = '';
              selectedProduct = '';

              selectedAssoc = '';

              selectedFarm = '';
              // Reset columns and data
              selectedColumns = {};
              reportData = [];
              filteredReportData = [];
              searchQuery = '';
              _previewKey = UniqueKey();
            });
          },
          outputFormat: outputFormat,
          onOutputFormatChanged: (newValue) =>
              setState(() => outputFormat = newValue),
          selectedColumns: selectedColumns,
          onColumnsChanged: handleColumnsChanged,
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
                      onChanged: searchReports,
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
                key: _previewKey, // Use the key to force rebuild
                reportData: filteredReportData,
                reportType: reportType,
                outputFormat: outputFormat,
                selectedColumns: selectedColumns,
                isLoading: isLoading,
                dateRange: dateRange,
                selectedBarangay: selectedBarangay,
                selectedSector: selectedSector,
                selectedAssoc: selectedAssoc,
                selectedProductType: selectedProduct,
                selectedFarmer: selectedFarmer,
                //  selectedCount: selectedCount,
                selectedView: selectedView,
                onDeleteSelected: _handleItemsRemoved,
              ),
            ),
          ),
          ReportExportOptions(
            reportType: reportType,
            reportData: filteredReportData,
            selectedColumns: selectedColumns,
            dateRange: dateRange,
            context: context,
          ),
        ],
      ],
    );
  }
}
