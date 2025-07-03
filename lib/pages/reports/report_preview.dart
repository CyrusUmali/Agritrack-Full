import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/tables/table_widget.dart';
import 'package:flareline_uikit/entity/table_data_entity.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'package:collection/collection.dart';

class ReportPreview extends StatefulWidget {
  final List<Map<String, dynamic>> reportData;
  final String reportType;
  final String outputFormat;
  final Set<String> selectedColumns;
  final bool isLoading;
  final DateTimeRange dateRange;
  final String? selectedProductType;
  final String? selectedFarmer;
  final String? selectedView;
  final String selectedBarangay;
  final String selectedSector;

  const ReportPreview({
    super.key,
    required this.reportData,
    required this.reportType,
    required this.outputFormat,
    required this.selectedColumns,
    required this.isLoading,
    required this.dateRange,
    required this.selectedProductType,
    required this.selectedFarmer,
    required this.selectedView,
    required this.selectedBarangay,
    required this.selectedSector,
  });

  @override
  State<ReportPreview> createState() => _ReportPreviewState();
}

class _ReportPreviewState extends State<ReportPreview> {
  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      );
    }

    if (widget.reportData.isEmpty) {
      return Center(
        child: Text(
          'No data available. Generate a report first.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildReportContent(context),
        ),
      ],
    );
  }

  Widget _buildReportContent(BuildContext context) {
    return SizedBox(
      height: 600,
      child: ReportDataTable(
        reportData: widget.reportData,
        selectedColumns: widget.selectedColumns.toList(),
      ),
    );
  }
}

class ReportDataTable extends StatefulWidget {
  final List<Map<String, dynamic>> reportData;
  final List<String> selectedColumns;

  const ReportDataTable({
    required this.reportData,
    required this.selectedColumns,
    Key? key,
  }) : super(key: key);

  @override
  State<ReportDataTable> createState() => _ReportDataTableState();
}

class _ReportDataTableState extends State<ReportDataTable> {
  String? _sortColumn;
  bool _sortAscending = true;

  List<Map<String, dynamic>> get _sortedData {
    if (_sortColumn == null) return widget.reportData;

    final sorted = List<Map<String, dynamic>>.from(widget.reportData);
    sorted.sort((a, b) {
      final aValue = a[_sortColumn]?.toString() ?? '';
      final bValue = b[_sortColumn]?.toString() ?? '';

      return _sortAscending
          ? aValue.compareTo(bValue)
          : bValue.compareTo(aValue);
    });
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      desktop: (context) => _buildDesktopTable(),
      mobile: (context) => _buildMobileTable(context),
      tablet: (context) => _buildMobileTable(context),
    );
  }

  Widget _buildDesktopTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: SizedBox(
              width: constraints.maxWidth > 1200 ? 1200 : constraints.maxWidth,
              child: _ReportTableWidget(
                key: ValueKey(
                    widget.selectedColumns.join(',')), // Force rebuild with key
                reportData: _sortedData,
                selectedColumns: widget.selectedColumns,
                sortColumn: _sortColumn,
                sortAscending: _sortAscending,
                onSort: _onSort,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileTable(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 800,
        child: _ReportTableWidget(
          key: ValueKey(
              widget.selectedColumns.join(',')), // Force rebuild with key
          reportData: _sortedData,
          selectedColumns: widget.selectedColumns,
          sortColumn: _sortColumn,
          sortAscending: _sortAscending,
          onSort: _onSort,
        ),
      ),
    );
  }

  void _onSort(String columnName) {
    setState(() {
      if (_sortColumn == columnName) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = columnName;
        _sortAscending = true;
      }
    });
  }
}

class _ReportTableWidget extends TableWidget<ReportTableViewModel> {
  final List<Map<String, dynamic>> reportData;
  final List<String> selectedColumns;
  final String? sortColumn;
  final bool sortAscending;
  final Function(String) onSort;

  _ReportTableWidget({
    required this.reportData,
    required this.selectedColumns,
    required this.sortColumn,
    required this.sortAscending,
    required this.onSort,
    Key? key,
  }) : super(key: key);

  @override
  ReportTableViewModel viewModelBuilder(BuildContext context) {
    return ReportTableViewModel(
      context,
      reportData,
      selectedColumns,
    );
  }

  @override
  bool get reloadOnUpdate => true;

  @override
  Widget build(BuildContext context) {
    print('selectedColumns');
    print(selectedColumns);
    return super.build(context);
  }

  // Override this to ensure the widget rebuilds when properties change
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _ReportTableWidget &&
        other.reportData == reportData &&
        const ListEquality().equals(other.selectedColumns, selectedColumns) &&
        other.sortColumn == sortColumn &&
        other.sortAscending == sortAscending;
  }

  @override
  int get hashCode {
    return Object.hash(
      reportData,
      const ListEquality().hash(selectedColumns),
      sortColumn,
      sortAscending,
    );
  }

  @override
  Widget headerBuilder(
      BuildContext context, String headerName, ReportTableViewModel viewModel) {
    return InkWell(
      onTap: () => onSort(headerName),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              headerName,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            sortColumn == headerName
                ? (sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
                : Icons.unfold_more,
            size: 16,
            color: sortColumn == headerName
                ? Theme.of(context).primaryColor
                : Colors.grey,
          ),
        ],
      ),
    );
  }

  @override
  Widget actionWidgetsBuilder(
    BuildContext context,
    TableDataRowsTableDataRows columnData,
    ReportTableViewModel viewModel,
  ) {
    return const SizedBox.shrink();
  }
}

class ReportTableViewModel extends BaseTableProvider {
  final List<Map<String, dynamic>> reportData;
  final List<String> selectedColumns;

  ReportTableViewModel(
    super.context,
    this.reportData,
    this.selectedColumns,
  );

  @override
  Future loadData(BuildContext context) async {
    final headers = [...selectedColumns];

    List<List<TableDataRowsTableDataRows>> rows = [];

    for (var i = 0; i < reportData.length; i++) {
      final rowData = reportData[i];
      List<TableDataRowsTableDataRows> row = [];

      for (var column in selectedColumns) {
        var cell = TableDataRowsTableDataRows()
          ..text = rowData[column]?.toString() ?? 'N/A'
          ..dataType = CellDataType.TEXT.type
          ..columnName = column
          ..id = i.toString();
        row.add(cell);
      }

      rows.add(row);
    }

    TableDataEntity tableData = TableDataEntity()
      ..headers = headers
      ..rows = rows;

    tableDataEntity = tableData;
  }
}
