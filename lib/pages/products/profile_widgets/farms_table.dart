import 'package:flareline/core/models/farms_model.dart';
import 'package:flareline/pages/farms/farm_profile.dart';
import 'package:flareline/pages/products/profile_widgets/export_farms.dart';
import 'package:flareline/providers/user_provider.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Make sure to import Provider

enum FarmSortType {
  name,
  location,
  area,
  volume,
  yieldPerHectare,
}

class FarmsTable extends StatefulWidget {
  final List<Farm> farms;

  const FarmsTable({super.key, required this.farms});

  @override
  State<FarmsTable> createState() => _FarmsTableState();
}

class _FarmsTableState extends State<FarmsTable> {
  FarmSortType _sortType = FarmSortType.name;
  bool _sortAscending = true;
  List<Farm> _sortedFarms = [];

  @override
  void initState() {
    print('here this widget');
    print(widget.farms[0]);

    super.initState();
    _sortedFarms = List.from(widget.farms);
    _sortFarms(null);
  }

  @override
  void didUpdateWidget(FarmsTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.farms != widget.farms) {
      _sortedFarms = List.from(widget.farms);
      _sortFarms(null);
    }
  }

  void _sortFarms(isFarmer) {
    _sortedFarms.sort((a, b) {
      int comparison = 0;

      switch (_sortType) {
        case FarmSortType.name:
          comparison = (a.name ?? '').compareTo(b.name ?? '');
          break;
        case FarmSortType.location:
          comparison = (a.barangay ?? '').compareTo(b.barangay ?? '');
          break;
        case FarmSortType.area:
          final aArea = a.hectare ?? 0;
          final bArea = b.hectare ?? 0;
          comparison = aArea.compareTo(bArea);
          break;
        case FarmSortType.volume:
          // If user is farmer, don't sort by volume
          if (isFarmer) {
            comparison = 0;
          } else {
            final aVolume = a.volume ?? 0;
            final bVolume = b.volume ?? 0;
            comparison = aVolume.compareTo(bVolume);
          }
          break;
        case FarmSortType.yieldPerHectare:
          // If user is farmer, don't sort by yield
          if (isFarmer) {
            comparison = 0;
          } else {
            final aYield = _calculateYieldPerHectare(a);
            final bYield = _calculateYieldPerHectare(b);
            comparison = aYield.compareTo(bYield);
          }
          break;
      }

      return _sortAscending ? comparison : -comparison;
    });
  }

  double _calculateYieldPerHectare(Farm farm) {
    final volume = farm.volume ?? 0;
    final area = farm.hectare ?? 0;
    if (area == 0) return 0.0;
    return (volume / 1000) / area;
  }

  void _onSort(FarmSortType sortType, isFarmer) {
    // Don't allow sorting by volume or yield if user is farmer
    if (isFarmer &&
        (sortType == FarmSortType.volume ||
            sortType == FarmSortType.yieldPerHectare)) {
      return;
    }

    setState(() {
      if (_sortType == sortType) {
        _sortAscending = !_sortAscending;
      } else {
        _sortType = sortType;
        _sortAscending = true;
      }
      _sortFarms(isFarmer);
    });
  }

  Widget _buildSortHeader(String title, FarmSortType sortType, isFarmer,
      {double? width}) {
    final isSelected = _sortType == sortType;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Don't make volume and yield headers interactive for farmers
    final isDisabledForFarmer = isFarmer &&
        (sortType == FarmSortType.volume ||
            sortType == FarmSortType.yieldPerHectare);

    return InkWell(
      onTap: isDisabledForFarmer ? null : () => _onSort(sortType, isFarmer),
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isDisabledForFarmer
                      ? colorScheme.onSurface.withOpacity(0.4)
                      : (isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface.withOpacity(0.8)),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            if (isSelected && !isDisabledForFarmer)
              Icon(
                _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 16,
                color: colorScheme.primary,
              )
            else if (!isDisabledForFarmer)
              Icon(
                Icons.sort,
                size: 16,
                color: colorScheme.outline.withOpacity(0.6),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortControls(isFarmer) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color!.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sort by:',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSortChip('Name', FarmSortType.name, isFarmer),
              _buildSortChip('Location', FarmSortType.location, isFarmer),
              _buildSortChip('Farm Size', FarmSortType.area, isFarmer),
              if (!isFarmer) ...[
                _buildSortChip('Total Volume', FarmSortType.volume, isFarmer),
                _buildSortChip(
                    'Yield/Ha', FarmSortType.yieldPerHectare, isFarmer),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, FarmSortType sortType, isFarmer) {
    final isSelected = _sortType == sortType;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () => _onSort(sortType, isFarmer),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : Theme.of(context).brightness == Brightness.dark
                  ? const Color.fromARGB(255, 74, 76, 80)
                  : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : colorScheme.onSurface,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              Icon(
                _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 14,
                color: Colors.white,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatVolume(int? volume) {
    if (volume == null || volume == 0) return 'N/A';
    if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)} t';
    }
    return '$volume kg';
  }

  String _formatYieldPerHectare(Farm farm) {
    final yieldValue = _calculateYieldPerHectare(farm);
    if (yieldValue == 0) return 'N/A';
    return '${yieldValue.toStringAsFixed(2)} t/ha';
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isFarmer = userProvider.isFarmer;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CommonCard(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Farms Growing This Product (${widget.farms.length})',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                if (widget.farms.isNotEmpty) ...[
                  FarmsExportButtonWidget(farms: widget.farms),
                  const SizedBox(width: 12),
                ],
              ],
            ),
            const SizedBox(height: 16),
            if (widget.farms.isEmpty)
              Text(
                'No farms data available',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              )
            else ...[
              _buildSortControls(isFarmer),
              LayoutBuilder(
                builder: (context, constraints) {
                  // Adjust column widths based on whether user is farmer
                  double baseColumnWidth =
                      constraints.maxWidth / (isFarmer ? 4 : 6);
                  double nameColumnWidth = baseColumnWidth * 2;
                  double locationColumnWidth = baseColumnWidth * 2;
                  double numberColumnWidth = baseColumnWidth * 1.4;
                  double actionColumnWidth = baseColumnWidth * 0.6;

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 16,
                      horizontalMargin: 12,
                      headingRowColor: MaterialStateProperty.all(
                        colorScheme.surfaceVariant.withOpacity(0.2),
                      ),
                      dataRowColor: MaterialStateProperty.resolveWith(
                        (states) {
                          if (states.contains(MaterialState.hovered)) {
                            return colorScheme.surfaceVariant.withOpacity(0.1);
                          }
                          if (states.contains(MaterialState.selected)) {
                            return colorScheme.primary.withOpacity(0.1);
                          }
                          return null;
                        },
                      ),
                      columns: [
                        DataColumn(
                          label: _buildSortHeader(
                              'Farm Name', FarmSortType.name, isFarmer,
                              width: nameColumnWidth),
                        ),
                        DataColumn(
                          label: _buildSortHeader(
                              'Location', FarmSortType.location, isFarmer,
                              width: locationColumnWidth),
                        ),
                        DataColumn(
                          label: _buildSortHeader(
                              'Area (ha)', FarmSortType.area, isFarmer,
                              width: numberColumnWidth),
                          numeric: true,
                        ),
                        // Only show volume and yield columns if user is not a farmer
                        if (!isFarmer) ...[
                          DataColumn(
                            label: _buildSortHeader(
                                'Volume', FarmSortType.volume, isFarmer,
                                width: numberColumnWidth),
                            numeric: true,
                          ),
                          DataColumn(
                            label: _buildSortHeader('Yield/Ha',
                                FarmSortType.yieldPerHectare, isFarmer,
                                width: numberColumnWidth),
                            numeric: true,
                          ),
                        ],
                        DataColumn(
                          label: SizedBox(
                            width: numberColumnWidth,
                            child: Text(
                              'Status',
                              style: TextStyle(
                                color: colorScheme.onSurface.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: actionColumnWidth,
                            child: Text(
                              'Actions',
                              style: TextStyle(
                                color: colorScheme.onSurface.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                      rows: _sortedFarms.map((farm) {
                        return DataRow(
                          cells: [
                            DataCell(
                              SizedBox(
                                width: nameColumnWidth,
                                child: Text(
                                  farm.name ?? 'Unknown',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: locationColumnWidth,
                                child: Text(
                                  farm.barangay ?? 'Unknown location',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: numberColumnWidth,
                                child: Text(
                                  farm.hectare?.toStringAsFixed(1) ?? 'N/A',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                            // Only show volume and yield cells if user is not a farmer
                            if (!isFarmer) ...[
                              DataCell(
                                SizedBox(
                                  width: numberColumnWidth,
                                  child: Text(
                                    _formatVolume(farm.volume),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: numberColumnWidth,
                                  child: Text(
                                    _formatYieldPerHectare(farm),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            DataCell(
                              SizedBox(
                                width: numberColumnWidth,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor('active'),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Active',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: _getStatusTextColor('active'),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: actionColumnWidth,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.arrow_forward,
                                    color: colorScheme.primary,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            FarmProfile(farmId: farm.id ?? 0),
                                      ),
                                    );
                                  },
                                  tooltip: 'View farm details',
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getSortTypeLabel(FarmSortType sortType) {
    switch (sortType) {
      case FarmSortType.name:
        return 'Name';
      case FarmSortType.location:
        return 'Location';
      case FarmSortType.area:
        return 'Farm Size';
      case FarmSortType.volume:
        return 'Volume';
      case FarmSortType.yieldPerHectare:
        return 'Yield per Hectare';
    }
  }

  Color _getStatusColor(String? status) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (status == null) return colorScheme.surfaceVariant;

    switch (status.toLowerCase()) {
      case 'active':
        return colorScheme.primaryContainer.withOpacity(0.3);
      case 'inactive':
        return colorScheme.errorContainer.withOpacity(0.3);
      default:
        return colorScheme.surfaceVariant;
    }
  }

  Color _getStatusTextColor(String? status) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (status == null) return colorScheme.onSurfaceVariant;

    switch (status.toLowerCase()) {
      case 'active':
        return colorScheme.onPrimaryContainer;
      case 'inactive':
        return colorScheme.onErrorContainer;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }
}
