import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';

class ReportPreview extends StatefulWidget {
  final List<Map<String, dynamic>> reportData;
  final String reportType;
  final String outputFormat;
  final Set<String> selectedColumns;
  final bool isLoading;
  final DateTimeRange dateRange;
  final String? selectedCropType;
  final String? selectedFarmer;
  final Set<String> selectedBarangay;
  final Set<String> selectedSector;

  const ReportPreview({
    super.key,
    required this.reportData,
    required this.reportType,
    required this.outputFormat,
    required this.selectedColumns,
    required this.isLoading,
    required this.dateRange,
    required this.selectedCropType,
    required this.selectedFarmer,
    required this.selectedBarangay,
    required this.selectedSector,
  });

  @override
  State<ReportPreview> createState() => _ReportPreviewState();
}

class _ReportPreviewState extends State<ReportPreview> {
  final Set<int> _selectedRows = {};
  bool _selectAll = false;
  late _ReportAsyncDataSource _source;

  @override
  void initState() {
    super.initState();
    _source = _ReportAsyncDataSource(
      widget.reportData,
      widget.selectedColumns.toList(),
      _selectedRows,
      _handleRowSelection,
    );
  }

  @override
  void didUpdateWidget(ReportPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reportData != oldWidget.reportData ||
        widget.selectedColumns != oldWidget.selectedColumns) {
      _source = _ReportAsyncDataSource(
        widget.reportData,
        widget.selectedColumns.toList(),
        _selectedRows,
        _handleRowSelection,
      );
    }
  }

  void _handleRowSelection(int index, bool selected) {
    setState(() {
      if (selected) {
        _selectedRows.add(index);
      } else {
        _selectedRows.remove(index);
        _selectAll = false;
      }
    });
    // No need to rebuild the table - the DataTableSource will handle it
  }

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

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Theme.of(context).cardTheme.color,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: Theme.of(context).cardTheme.surfaceTintColor ??
                Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(2),
        ),
        shadows: [
          BoxShadow(
            color:
                Theme.of(context).cardTheme.shadowColor ?? Colors.transparent,
            blurRadius: 13,
            offset: const Offset(0, 8),
            spreadRadius: -3,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedRows.isNotEmpty) _buildSelectionActions(context),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildReportContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Text(
            '${_selectedRows.length} selected',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearSelection,
            tooltip: 'Clear selection',
          ),
          // Add more action buttons here as needed
        ],
      ),
    );
  }

  void _clearSelection() {
    setState(() {
      _selectedRows.clear();
      _selectAll = false;
    });
    _source.notifyListeners();
  }

  Widget _buildReportContent(BuildContext context) {
    return SizedBox(
      height: 600,
      child: _buildDataTable(context),
    );
  }

  Widget _buildDataTable(context) {
    if (widget.reportData.isEmpty || widget.selectedColumns.isEmpty) {
      return Center(
        child: Text(
          'No data to display in table',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      );
    }

    final visibleColumns = widget.selectedColumns.toList();

    return Theme(
      data: Theme.of(context).copyWith(
        cardTheme: CardTheme(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
              width: 1,
            ),
          ),
        ),
        dataTableTheme: DataTableThemeData(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
          ),
          headingRowColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              return Theme.of(context).colorScheme.surfaceContainerLow;
            },
          ),
          dataRowColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return Theme.of(context).colorScheme.primaryContainer;
              }
              return null;
            },
          ),
        ),
      ),
      child: AsyncPaginatedDataTable2(
        checkboxHorizontalMargin: 12,
        columnSpacing: 12,
        horizontalMargin: 12,
        minWidth: 600,
        rowsPerPage: 8,
        wrapInCard: false,
        smRatio: 0.5,
        lmRatio: 1.5,
        empty: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'No matching records found',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ),
        columns: [
          DataColumn2(
            label: Checkbox(
              value: _selectAll,
              onChanged: (value) {
                setState(() {
                  _selectAll = value ?? false;
                  if (_selectAll) {
                    _selectedRows.addAll(List.generate(
                        widget.reportData.length, (index) => index));
                  } else {
                    _selectedRows.clear();
                  }
                });
              },
            ),
            size: ColumnSize.S,
          ),
          ...visibleColumns.map(
            (column) => DataColumn2(
              label: Text(
                column,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              size: ColumnSize.L,
              onSort: (columnIndex, ascending) {
                // Sorting would be implemented in parent widget
              },
            ),
          ),
        ],
        source: _ReportAsyncDataSource(
          widget.reportData,
          visibleColumns,
          _selectedRows,
          (index, selected) {
            setState(() {
              if (selected) {
                _selectedRows.add(index);
              } else {
                _selectedRows.remove(index);
                _selectAll = false;
              }
            });
          },
        ),
      ),
    );
  }
}

class _ReportAsyncDataSource extends AsyncDataTableSource {
  final List<Map<String, dynamic>> data;
  final List<String> columns;
  final Set<int> selectedRows;
  final Function(int index, bool selected) onRowSelected;

  _ReportAsyncDataSource(
    this.data,
    this.columns,
    this.selectedRows,
    this.onRowSelected,
  );

  @override
  Future<AsyncRowsResponse> getRows(int startIndex, int count) async {
    if (data.isEmpty) {
      return AsyncRowsResponse(0, []);
    }

    final endIndex = startIndex + count;
    final actualEndIndex = endIndex > data.length ? data.length : endIndex;

    if (startIndex >= data.length) {
      return AsyncRowsResponse(data.length, []);
    }

    final rows = List<DataRow2>.generate(
      actualEndIndex - startIndex,
      (index) {
        final absoluteIndex = startIndex + index;
        return DataRow2(
          cells: [
            DataCell(
              Checkbox(
                value: selectedRows.contains(absoluteIndex),
                onChanged: (value) {
                  onRowSelected(absoluteIndex, value ?? false);
                  notifyListeners();
                },
              ),
            ),
            ...columns
                .map((column) => DataCell(
                      Text(data[absoluteIndex][column]?.toString() ?? 'N/A'),
                    ))
                .toList(),
          ],
        );
      },
    );

    return AsyncRowsResponse(data.length, rows);
  }

  @override
  bool get isRowCountApproximate => false;
}
