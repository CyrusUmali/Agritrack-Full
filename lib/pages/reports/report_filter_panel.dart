import 'package:flareline/pages/assoc/assoc_bloc/assocs_bloc.dart';
import 'package:flareline/pages/farmers/farmer/farmer_bloc.dart';
import 'package:flareline/pages/farms/farm_bloc/farm_bloc.dart';
import 'package:flareline/pages/products/product/product_bloc.dart';
import 'package:flareline/pages/reports/filter_configs/filter_combo-box.dart';
import 'package:flareline/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'date_range_picker.dart';
import 'filters/segmented_filter.dart';
import 'filters/column_selector.dart';
import 'filter_configs/filter_options.dart';

class ReportFilterPanel extends StatelessWidget {
  final DateTimeRange dateRange;
  final ValueChanged<DateTimeRange> onDateRangeChanged;
  final String selectedBarangay;
  final String selectedFarmer;

  final String selectedCount;
  final ValueChanged<String> onCountChanged;
  final String selectedView;

  final ValueChanged<String> onViewChanged;
  final ValueChanged<String> onFarmerChanged;
  final ValueChanged<String> onBarangayChanged;
  final String selectedSector;
  final ValueChanged<String> onSectorChanged;
  final String selectedProduct;
  final ValueChanged<String> onProductChanged;

  final String selectedAssoc;
  final ValueChanged<String> onAssocChanged;

  final String selectedFarm;
  final ValueChanged<String> onFarmChanged;
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
    required this.selectedBarangay,
    required this.selectedFarmer,
    required this.selectedView,
    required this.selectedCount,
    required this.onCountChanged,
    required this.onViewChanged,
    required this.onBarangayChanged,
    required this.onFarmerChanged,
    required this.selectedSector,
    required this.onSectorChanged,
    required this.selectedAssoc,
    required this.onAssocChanged,
    required this.selectedProduct,
    required this.onProductChanged,
    required this.selectedFarm,
    required this.onFarmChanged,
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
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final _isFarmer = userProvider.isFarmer;
    final _farmerId = userProvider.farmer?.id;

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
                      options: FilterOptions.getFilteredReportTypes(_isFarmer),
                      selected: reportType,
                      onChanged: onReportTypeChanged,
                    ),
                    const SizedBox(height: 16),
                    // This will force a rebuild when reportType changes
                    _FiltersSection(
                      reportType: reportType,
                      dateRange: dateRange,
                      onDateRangeChanged: onDateRangeChanged,
                      selectedBarangay: selectedBarangay,
                      selectedFarmer: selectedFarmer,
                      selectedView: selectedView,
                      onCountChanged: onCountChanged,
                      selectedCount: selectedCount,
                      selectedSector: selectedSector,
                      selectedProduct: selectedProduct,
                      onProductChanged: onProductChanged,
                      selectedAssoc: selectedAssoc,
                      onAssocChanged: onAssocChanged,
                      selectedFarm: selectedFarm,
                      onBarangayChanged: onBarangayChanged,
                      onFarmerChanged: onFarmerChanged,
                      onSectorChanged: onSectorChanged,
                      onFarmChanged: onFarmChanged,
                      onViewChanged: onViewChanged,
                      isDesktop: isDesktop,
                      isTablet: isTablet,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
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
                  width: isDesktop ? 201 : double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).cardTheme.color ?? Colors.white,
                      foregroundColor:
                          Theme.of(context).textTheme.bodyMedium?.color,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: Colors.grey[300]!,
                          width: 1.0,
                        ),
                      ),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                    onPressed: isLoading ? null : onGeneratePressed,
                    child: isLoading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          )
                        : Text(
                            'Generate Report',
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class _FiltersSection extends StatelessWidget {
  final String reportType;
  final DateTimeRange dateRange;
  final ValueChanged<DateTimeRange> onDateRangeChanged;
  final String selectedBarangay;
  final String selectedFarmer;
  final String selectedView;
  final String selectedCount;
  final ValueChanged<String> onCountChanged;
  final String selectedSector;

  final String selectedProduct;
  final ValueChanged<String> onProductChanged;

  final String selectedAssoc;
  final ValueChanged<String> onAssocChanged;

  final String selectedFarm;
  final ValueChanged<String> onBarangayChanged;
  final ValueChanged<String> onFarmerChanged;
  final ValueChanged<String> onSectorChanged;

  final ValueChanged<String> onFarmChanged;
  final ValueChanged<String> onViewChanged;
  final bool isDesktop;
  final bool isTablet;

  const _FiltersSection({
    required this.reportType,
    required this.dateRange,
    required this.onDateRangeChanged,
    required this.selectedBarangay,
    required this.selectedFarmer,
    required this.selectedView,
    required this.selectedCount,
    required this.onCountChanged,
    required this.selectedSector,
    required this.selectedProduct,
    required this.onProductChanged,
    required this.selectedAssoc,
    required this.onAssocChanged,
    required this.selectedFarm,
    required this.onBarangayChanged,
    required this.onFarmerChanged,
    required this.onSectorChanged,
    required this.onFarmChanged,
    required this.onViewChanged,
    required this.isDesktop,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    if (reportType == 'products' ||
        reportType == 'sectors' ||
        reportType == 'farmer' ||
        reportType == 'comparison') {
      return isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DateRangePickerWidget(
                  dateRange: dateRange,
                  onDateRangeChanged: onDateRangeChanged,
                ),
                const SizedBox(width: 32),
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
            );
    } else {
      return isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_buildDesktopFilters(context)],
            )
          : isTablet
              ? _buildTabletFilters(context)
              : _buildMobileFilters(context);
    }
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
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final _isFarmer = userProvider.isFarmer;

    final _farmerId = userProvider.farmer?.id;

    switch (reportType) {
      case 'farmers':
        return [
          buildComboBox(
            hint: 'Barangay',
            options: FilterOptions.barangays,
            selectedValue: selectedBarangay,
            onSelected: onBarangayChanged,
            width: isDesktop ? 130 : double.infinity,
          ),
          buildComboBox(
            hint: 'Sector',
            options: FilterOptions.sectors,
            selectedValue: selectedSector,
            onSelected: onSectorChanged,
            width: isDesktop ? 130 : double.infinity,
          ),
          BlocBuilder<AssocsBloc, AssocsState>(
            builder: (context, state) {
              return buildComboBox(
                hint: 'Association',
                options: FilterOptions.getAssocs(context),
                selectedValue: selectedAssoc,
                onSelected: onAssocChanged,
                width: isDesktop ? 130 : double.infinity,
              );
            },
          ),
          buildComboBox(
            hint: 'Count',
            options: FilterOptions.Count,
            selectedValue: selectedCount,
            onSelected: onCountChanged,
            width: isDesktop ? 130 : double.infinity,
          ),
        ];
      case 'farmer':
        return [
          if (!_isFarmer)
            BlocBuilder<FarmerBloc, FarmerState>(
              builder: (context, state) {
                return buildComboBox(
                  hint: 'Farmer',
                  options: FilterOptions.getFarmers(context),
                  selectedValue: selectedFarmer,
                  onSelected: onFarmerChanged,
                  width: isDesktop ? 130 : double.infinity,
                );
              },
            ),
          BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              return buildComboBox(
                hint: 'Product',
                options: FilterOptions.getProducts(context),
                selectedValue: selectedProduct,
                onSelected: onProductChanged,
                width: isDesktop ? 130 : double.infinity,
              );
            },
          ),
          BlocBuilder<FarmBloc, FarmState>(
            builder: (context, state) {
              return buildComboBox(
                hint: 'Farm',
                options: FilterOptions.getFarms(context, _farmerId),
                selectedValue: selectedFarm,
                onSelected: onFarmChanged,
                width: isDesktop ? 130 : double.infinity,
              );
            },
          ),
          if (!_isFarmer)
            BlocBuilder<AssocsBloc, AssocsState>(
              builder: (context, state) {
                return buildComboBox(
                  hint: 'Association',
                  options: FilterOptions.getAssocs(context),
                  selectedValue: selectedAssoc,
                  onSelected: onAssocChanged,
                  width: isDesktop ? 130 : double.infinity,
                );
              },
            ),
          buildComboBox(
            hint: 'View By',
            options: FilterOptions.viewBy,
            selectedValue: selectedView,
            onSelected: onViewChanged,
            width: isDesktop ? 130 : double.infinity,
          ),
          buildComboBox(
            hint: 'Count',
            options: FilterOptions.Count,
            selectedValue: selectedCount,
            onSelected: onCountChanged,
            width: isDesktop ? 130 : double.infinity,
          ),
        ];
      case 'products':
        return [
          BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              return buildComboBox(
                hint: 'Product',
                options: FilterOptions.getProducts(context),
                selectedValue: selectedProduct,
                onSelected: onProductChanged,
                width: isDesktop ? 130 : double.infinity,
              );
            },
          ),
          buildComboBox(
            hint: 'View By',
            options: FilterOptions.viewBy,
            selectedValue: selectedView,
            onSelected: onViewChanged,
            width: isDesktop ? 130 : double.infinity,
          ),
          if (!_isFarmer)
            buildComboBox(
              hint: 'Barangay',
              options: FilterOptions.barangays,
              selectedValue: selectedBarangay,
              onSelected: onBarangayChanged,
              width: isDesktop ? 130 : double.infinity,
            ),
          if (!_isFarmer)
            buildComboBox(
              hint: 'Sector',
              options: FilterOptions.sectors,
              selectedValue: selectedSector,
              onSelected: onSectorChanged,
              width: isDesktop ? 130 : double.infinity,
            ),
          buildComboBox(
            hint: 'Count',
            options: FilterOptions.Count,
            selectedValue: selectedCount,
            onSelected: onCountChanged,
            width: isDesktop ? 130 : double.infinity,
          ),
        ];

      case 'barangay':
        return [
          buildComboBox(
            hint: 'Barangay',
            options: FilterOptions.barangays,
            selectedValue: selectedBarangay,
            onSelected: onBarangayChanged,
            width: isDesktop ? 130 : double.infinity,
          ),
          BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              return buildComboBox(
                hint: 'Product',
                options: FilterOptions.getProducts(context),
                selectedValue: selectedProduct,
                onSelected: onProductChanged,
                width: isDesktop ? 130 : double.infinity,
              );
            },
          ),
          buildComboBox(
            hint: 'View By',
            options: FilterOptions.viewBy,
            selectedValue: selectedView,
            onSelected: onViewChanged,
            width: isDesktop ? 130 : double.infinity,
          ),
          buildComboBox(
            hint: 'Sector',
            options: FilterOptions.sectors,
            selectedValue: selectedSector,
            onSelected: onSectorChanged,
            width: isDesktop ? 130 : double.infinity,
          ),
          buildComboBox(
            hint: 'Count',
            options: FilterOptions.Count,
            selectedValue: selectedCount,
            onSelected: onCountChanged,
            width: isDesktop ? 130 : double.infinity,
          ),
        ];

      case 'sectors':
        return [
          buildComboBox(
            hint: 'Sector',
            options: FilterOptions.sectors,
            selectedValue: selectedSector,
            onSelected: onSectorChanged,
            width: isDesktop ? 130 : double.infinity,
          ),
          buildComboBox(
            hint: 'View By',
            options: FilterOptions.viewBy,
            selectedValue: selectedView,
            onSelected: onViewChanged,
            width: isDesktop ? 130 : double.infinity,
          ),
          buildComboBox(
            hint: 'Count',
            options: FilterOptions.Count,
            selectedValue: selectedCount,
            onSelected: onCountChanged,
            width: isDesktop ? 130 : double.infinity,
          ),
        ];
      default:
        return [];
    }
  }
}
