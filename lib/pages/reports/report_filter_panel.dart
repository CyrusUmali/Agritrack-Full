import 'package:flareline/pages/reports/modal/filter_modal.dart';
import 'package:flutter/material.dart';
import 'package:flareline/core/theme/global_colors.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:intl/intl.dart';
import 'date_range_picker.dart';
import 'filters/segmented_filter.dart';
import 'filters/column_selector.dart';
import 'filter_configs/filter_options.dart';
import 'filter_configs/column_options.dart';
import 'package:flareline_uikit/components/modal/modal_dialog.dart';

class ReportFilterPanel extends StatelessWidget {
  final DateTimeRange dateRange;
  final ValueChanged<DateTimeRange> onDateRangeChanged;
  final Set<String> selectedBarangays;
  final ValueChanged<Set<String>> onBarangaysChanged;
  final Set<String> selectedSectors;
  final ValueChanged<Set<String>> onSectorsChanged;
  final Set<String> selectedCrops;
  final ValueChanged<Set<String>> onCropsChanged;
  final Set<String> selectedFarms;
  final ValueChanged<Set<String>> onFarmsChanged;
  final String reportType;
  final ValueChanged<String> onReportTypeChanged;
  final String outputFormat;
  final ValueChanged<String> onOutputFormatChanged;
  final Set<String> selectedColumns;
  final ValueChanged<Set<String>> onColumnsChanged;
  final VoidCallback onGeneratePressed;
  final bool isLoading;

  const ReportFilterPanel({
    super.key,
    required this.dateRange,
    required this.onDateRangeChanged,
    required this.selectedBarangays,
    required this.onBarangaysChanged,
    required this.selectedSectors,
    required this.onSectorsChanged,
    required this.selectedCrops,
    required this.onCropsChanged,
    required this.selectedFarms,
    required this.onFarmsChanged,
    required this.reportType,
    required this.onReportTypeChanged,
    required this.outputFormat,
    required this.onOutputFormatChanged,
    required this.selectedColumns,
    required this.onColumnsChanged,
    required this.onGeneratePressed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800;
        final isTablet = constraints.maxWidth > 600;

        return CommonCard(
          padding: EdgeInsets.all(isDesktop ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Report Filters',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1.0,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    SegmentedFilter(
                      label: 'Report Type',
                      options: FilterOptions.reportTypes,
                      selected: reportType,
                      onChanged: onReportTypeChanged,
                    ),
                    const SizedBox(height: 16),

                    // Date range picker and filters section
                    if (reportType == 'crops' ||
                        reportType == 'sectors' ||
                        reportType == 'comparison')
                      isDesktop
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DateRangePickerWidget(
                                  dateRange: dateRange,
                                  onDateRangeChanged: onDateRangeChanged,
                                ),
                                const SizedBox(width: 16),
                                _buildDesktopFilters(context),
                              ],
                            )
                          : Column(
                              children: [
                                DateRangePickerWidget(
                                  dateRange: dateRange,
                                  onDateRangeChanged: onDateRangeChanged,
                                ),
                                const SizedBox(height: 16),
                                isTablet
                                    ? _buildTabletFilters(context)
                                    : _buildMobileFilters(context),
                              ],
                            ),
                    if (!(reportType == 'crops' ||
                        reportType == 'sectors' ||
                        reportType == 'comparison'))
                      isDesktop
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [_buildDesktopFilters(context)],
                            )
                          : isTablet
                              ? _buildTabletFilters(context)
                              : _buildMobileFilters(context),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity, // Ensures full width
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1.0,
                    ),
                  ),
                ),
                child: ColumnSelector(
                  reportType: reportType,
                  selectedColumns: selectedColumns,
                  onColumnsChanged: onColumnsChanged,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: isDesktop ? 200 : double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onGeneratePressed,
                    child: isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Generate Report'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDesktopFilters(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: _buildDynamicFilters(context, true),
    );
  }

  Widget _buildTabletFilters(BuildContext context) {
    return Column(
      children: [
        for (var filter in _buildDynamicFilters(context, false))
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: SizedBox(width: double.infinity, child: filter),
          ),
      ],
    );
  }

  Widget _buildMobileFilters(BuildContext context) {
    return Column(
      children: [
        for (var filter in _buildDynamicFilters(context, false))
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: filter,
          ),
      ],
    );
  }

  List<Widget> _buildDynamicFilters(BuildContext context, bool isDesktop) {
    switch (reportType) {
      case 'farmers':
        return [
          _buildFilterButton(
            context: context,
            label: 'Barangay',
            selectedValues: selectedBarangays,
            items: FilterOptions.barangays,
            onChanged: onBarangaysChanged,
            isDesktop: isDesktop,
          ),
          _buildFilterButton(
            context: context,
            label: 'Sector',
            selectedValues: selectedSectors,
            items: FilterOptions.sectors,
            onChanged: onSectorsChanged,
            isDesktop: isDesktop,
          ),
        ];
      case 'crops':
        return [
          _buildFilterButton(
            context: context,
            label: 'Crop',
            selectedValues: selectedCrops,
            items: FilterOptions.crops,
            onChanged: onCropsChanged,
            isDesktop: isDesktop,
          ),
          _buildFilterButton(
            context: context,
            label: 'Farm',
            selectedValues: selectedFarms,
            items: FilterOptions.farms,
            onChanged: onFarmsChanged,
            isDesktop: isDesktop,
          ),
        ];
      case 'sectors':
        return [
          _buildFilterButton(
            context: context,
            label: 'Sector',
            selectedValues: selectedSectors,
            items: FilterOptions.sectors,
            onChanged: onSectorsChanged,
            isDesktop: isDesktop,
          ),
        ];

      default:
        return [];
    }
  }

  Widget _buildFilterButton({
    required BuildContext context,
    required String label,
    required Set<String> selectedValues,
    required List<String> items,
    required ValueChanged<Set<String>> onChanged,
    required bool isDesktop,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // More chip-like
        ),
        backgroundColor: selectedValues.isNotEmpty
            ? Colors.blue[200] // Light blue background when selected
            : Colors.grey[200], // Light grey background when not selected
        foregroundColor: selectedValues.isNotEmpty
            ? Colors.blue[900] // Dark blue text/icon when selected
            : Colors.black, // Black text/icon when not selected
        textStyle: theme.textTheme.bodyMedium?.copyWith(
          color: selectedValues.isNotEmpty ? Colors.blue[900] : Colors.black,
        ),
      ),
      onPressed: () => isDesktop
          ? showDesktopModal(
              context: context,
              title: 'Filter by $label',
              items: items,
              selectedItems: selectedValues,
              onSelected: onChanged,
              multiple: true,
            )
          : showMobileModal(
              context: context,
              title: 'Filter by $label',
              items: items,
              selectedItems: selectedValues,
              onSelected: onChanged,
              multiple: true,
            ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_drop_down,
            size: 20,
            color: selectedValues.isNotEmpty ? Colors.blue[900] : Colors.black,
          ),
        ],
      ),
    );
  }

  void showMultiSelectModal({
    required BuildContext context,
    required String title,
    required List<String> items,
    required Set<String> selectedItems,
    required ValueChanged<Set<String>> onSelectedItemsChanged,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const Divider(),
                Expanded(
                  child: ListView(
                    children: items.map((item) {
                      final isSelected = selectedItems.contains(item);
                      return CheckboxListTile(
                        title: Text(item),
                        value: isSelected,
                        onChanged: (selected) {
                          setState(() {
                            if (selected == true) {
                              selectedItems.add(item);
                            } else {
                              selectedItems.remove(item);
                            }
                          });
                          onSelectedItemsChanged(selectedItems);
                        },
                      );
                    }).toList(),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
