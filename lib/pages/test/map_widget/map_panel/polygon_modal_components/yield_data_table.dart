import 'dart:math';

import 'package:flareline/pages/test/map_widget/polygon_manager.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../pin_style.dart';

class YieldDataTable extends StatefulWidget {
  final PolygonData polygon;

  const YieldDataTable({super.key, required this.polygon});

  @override
  State<YieldDataTable> createState() => _YieldDataTableState();
}

class _YieldDataTableState extends State<YieldDataTable> {
  late String _selectedProduct;
  bool _showMonthlyData = false;
  String _selectedYear = '2024';
  late Map<String, String> _productImages;
  late Map<String, Map<String, double>> _yieldData;
  late Map<String, Map<String, Map<String, double>>> _monthlyData;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void didUpdateWidget(covariant YieldDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.polygon.pinStyle != widget.polygon.pinStyle) {
      _initializeData();
    }
  }

  void _initializeData() {
    final products = _getFarmProducts(widget.polygon.pinStyle);
    _selectedProduct = products.first;
    _productImages = _getProductImages(products);
    _yieldData = _generateYieldData(products);
    _monthlyData = _generateMonthlyData(products);
  }

  List<String> _getFarmProducts(PinStyle pinStyle) {
    switch (pinStyle) {
      case PinStyle.fishery:
        return ["Tilapia", "Bangus", "Hipon"];
      case PinStyle.rice:
        return ["Rice"];
      case PinStyle.corn:
        return ["Corn"];
      case PinStyle.organic:
        return ["Carrot"];
      case PinStyle.highvaluecrop:
        return ["Cucumber", "Tomato"];
      case PinStyle.livestock:
        return ["Carabao", "Cow", "Horse"];
      default:
        return ["Mixed Crops", "Vegetables", "Fruits"];
    }
  }

  Map<String, String> _getProductImages(List<String> products) {
    final imageMap = {
      "Cow":
          "https://tse1.mm.bing.net/th/id/OIP.rYY066FUrcasLXCSjpu7nAHaFj?rs=1&pid=ImgDetMain",
      "Carabao":
          "https://tse3.mm.bing.net/th/id/OIP.oiSUKijwLvV_6VhKEHTCzAAAAA?rs=1&pid=ImgDetMain",
      "Horse":
          "https://cms.bbcearth.com/sites/default/files/factfiles/2024-07/horse1.jpg?imwidth=1008",
      "Rice":
          "https://tse2.mm.bing.net/th/id/OIP.8t3f-Mku5Gv2sm3mPXUvSgHaE7?rs=1&pid=ImgDetMain",
      "Corn": "https://www.drupal.org/files/issues/Corn.jpg",
      "Tomato":
          "https://tse2.mm.bing.net/th/id/OIP.BDihZZH52qoMZXSR-PCLBQHaHa?rs=1&pid=ImgDetMain",
      "Carrot":
          "https://assets-shop.voltz-maraichage.com/photos/var/r3/caro-miamif1.jpg",
      "Cucumber":
          "https://chefsmandala.com/wp-content/uploads/2018/03/Cucumber.jpg",
      "Tilapia":
          "https://tse2.mm.bing.net/th/id/OIP.NvFLxnMJXfjOsnwbpbfZzwHaE8?rs=1&pid=ImgDetMain",
      "Hipon":
          "https://tse3.mm.bing.net/th/id/OIP.tcGziAgKYkEULjonK2K9BAHaFj?rs=1&pid=ImgDetMain",
      "Bangus":
          "https://farmtodoorstep.co/wp-content/uploads/2021/09/bangus-alcantara.jpeg",
    };

    return Map.fromEntries(
      products.map((product) => MapEntry(product, imageMap[product] ?? '')),
    );
  }

  Map<String, Map<String, double>> _generateYieldData(List<String> products) {
    final random = Random();
    final data = <String, Map<String, double>>{};

    for (final product in products) {
      final productData = <String, double>{};
      for (var year = 2018; year <= 2024; year++) {
        if (year != 2021 && year != 2022) {
          // Skip some years for realism
          productData[year.toString()] =
              (random.nextDouble() * 1000 + 500).roundToDouble();
        }
      }
      data[product] = productData;
    }

    return data;
  }

  Map<String, Map<String, Map<String, double>>> _generateMonthlyData(
      List<String> products) {
    final random = Random();
    final data = <String, Map<String, Map<String, double>>>{};

    for (var year = 2023; year <= 2024; year++) {
      final yearData = <String, Map<String, double>>{};
      for (final product in products) {
        final productData = <String, double>{};
        for (var month = 1; month <= 6; month++) {
          // Only first half year for demo
          final monthName = _getMonthName(month);
          productData[monthName] =
              (random.nextDouble() * 200 + 50).roundToDouble();
        }
        yearData[product] = productData;
      }
      data[year.toString()] = yearData;
    }

    return data;
  }

  String _getMonthName(int month) {
    return [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ][month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final years = _yieldData.values
        .expand((product) => product.keys)
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Yield",
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                widget.polygon.pinStyle.toString().split('.').last,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Product selection cards
          SizedBox(
            height: 140,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _yieldData.keys.map((product) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      setState(() {
                        _selectedProduct = product;
                      });
                    },
                    child: Container(
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: _selectedProduct == product
                            ? colorScheme.primaryContainer
                            : colorScheme.surfaceContainerLow,
                        border: _selectedProduct == product
                            ? Border.all(color: colorScheme.primary, width: 2)
                            : null,
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _selectedProduct == product
                                  ? colorScheme.primary
                                  : colorScheme.secondaryContainer,
                              image: DecorationImage(
                                image: NetworkImage(_productImages[product]!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product,
                            style: textTheme.labelLarge?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          // Time period toggle and year selector
          Row(
            children: [
              Expanded(
                child: SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: false,
                      label: Text('Yearly'),
                      icon: Icon(Icons.calendar_today),
                    ),
                    ButtonSegment(
                      value: true,
                      label: Text('Monthly'),
                      icon: Icon(Icons.calendar_view_month),
                    ),
                  ],
                  selected: {_showMonthlyData},
                  onSelectionChanged: (Set<bool> newSelection) {
                    setState(() {
                      _showMonthlyData = newSelection.first;
                    });
                  },
                ),
              ),
              if (_showMonthlyData) ...[
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedYear,
                  items: _monthlyData.keys.map((String year) {
                    return DropdownMenuItem<String>(
                      value: year,
                      child: Text(year),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedYear = newValue!;
                    });
                  },
                ),
              ],
            ],
          ),

          const SizedBox(height: 16),

          // Data table
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: constraints.maxWidth,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _showMonthlyData
                          ? _buildMonthlyDataTable(theme)
                          : _buildYearlyDataTable(theme),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearlyDataTable(ThemeData theme) {
    final textTheme = theme.textTheme;
    final years = _yieldData[_selectedProduct]!.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return DataTable(
      columns: [
        DataColumn(
          label: Text('Year',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              )),
          numeric: false,
        ),
        DataColumn(
          label: Text('Yield (kg)',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              )),
          numeric: true,
        ),
        DataColumn(
          label: Text('Growth %',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              )),
          numeric: true,
        ),
      ],
      rows: years.map((year) {
        final currentValue = _yieldData[_selectedProduct]![year]!;
        final previousYear = (int.tryParse(year) ?? 0) - 1;
        final previousValue =
            _yieldData[_selectedProduct]![previousYear.toString()];
        final growth = previousValue != null
            ? ((currentValue - previousValue) / previousValue * 100)
            : null;

        return DataRow(
          cells: [
            DataCell(Text(year, style: textTheme.bodyMedium)),
            DataCell(
              Text(currentValue.toStringAsFixed(0),
                  style: textTheme.bodyMedium),
            ),
            DataCell(
              Text(
                growth?.toStringAsFixed(1) ?? 'N/A',
                style: textTheme.bodyMedium?.copyWith(
                  color: growth != null
                      ? growth >= 0
                          ? Colors.green
                          : Colors.red
                      : null,
                ),
              ),
            ),
          ],
        );
      }).toList(),
      headingRowHeight: 48,
      dataRowHeight: 48,
      dividerThickness: 1,
      horizontalMargin: 16,
      columnSpacing: 24,
    );
  }

  Widget _buildMonthlyDataTable(ThemeData theme) {
    final textTheme = theme.textTheme;
    final monthlyDataForProduct =
        _monthlyData[_selectedYear]?[_selectedProduct];
    final months = monthlyDataForProduct?.keys.toList() ?? [];

    return DataTable(
      columns: [
        DataColumn(
          label: Text('Month',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              )),
          numeric: false,
        ),
        DataColumn(
          label: Text('Yield (kg)',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              )),
          numeric: true,
        ),
      ],
      rows: months.map((month) {
        final value = monthlyDataForProduct![month]!;
        return DataRow(
          cells: [
            DataCell(Text(month, style: textTheme.bodyMedium)),
            DataCell(
              Text(value.toStringAsFixed(0), style: textTheme.bodyMedium),
            ),
          ],
        );
      }).toList(),
      headingRowHeight: 48,
      dataRowHeight: 48,
      dividerThickness: 1,
      horizontalMargin: 16,
      columnSpacing: 24,
    );
  }
}
