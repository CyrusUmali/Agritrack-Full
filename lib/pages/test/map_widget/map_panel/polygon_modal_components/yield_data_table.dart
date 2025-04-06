import 'package:flutter/material.dart';

class YieldDataTable extends StatefulWidget {
  const YieldDataTable({super.key});

  @override
  State<YieldDataTable> createState() => _YieldDataTableState();
}

class _YieldDataTableState extends State<YieldDataTable> {
  String _selectedProduct = 'Tilapia';
  bool _showMonthlyData = false;
  String _selectedYear = '2024'; // Default selected year for monthly data

  final Map<String, IconData> _productIcons = {
    'Tilapia': Icons.water,
    'Bangus': Icons.set_meal,
    'Shrimp': Icons.catching_pokemon,
  };

  final Map<String, Map<String, double>> _yieldData = {
    "Tilapia": {
      "2018": 1000,
      "2019": 1200,
      "2020": 1100,
      "2023": 1150,
      "2024": 1250,
    },
    "Bangus": {
      "2018": 800,
      "2019": 900,
      "2020": 850,
      "2023": 880,
      "2024": 920,
    },
    "Shrimp": {
      "2018": 500,
      "2019": 600,
      "2020": 550,
      "2023": 580,
      "2024": 620,
    },
  };

  final Map<String, Map<String, Map<String, double>>> _monthlyData = {
    "2023": {
      "Tilapia": {
        "Jan": 110,
        "Feb": 120,
        "Mar": 115,
        "Apr": 130,
        "May": 140,
        "Jun": 135,
      },
      "Bangus": {
        "Jan": 80,
        "Feb": 85,
        "Mar": 75,
        "Apr": 90,
        "May": 100,
        "Jun": 95,
      },
      "Shrimp": {
        "Jan": 50,
        "Feb": 55,
        "Mar": 45,
        "Apr": 60,
        "May": 70,
        "Jun": 65,
      },
    },
    "2024": {
      "Tilapia": {
        "Jan": 120,
        "Feb": 130,
        "Mar": 125,
        "Apr": 140,
        "May": 150,
        "Jun": 145,
      },
      "Bangus": {
        "Jan": 90,
        "Feb": 95,
        "Mar": 85,
        "Apr": 100,
        "May": 110,
        "Jun": 105,
      },
      "Shrimp": {
        "Jan": 60,
        "Feb": 65,
        "Mar": 55,
        "Apr": 70,
        "May": 80,
        "Jun": 75,
      },
    },
  };

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
            ],
          ),
          const SizedBox(height: 16),

          // Product selection cards
          SizedBox(
            height: 120,
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
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _selectedProduct == product
                                  ? colorScheme.primary
                                  : colorScheme.secondaryContainer,
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Icon(
                              _productIcons[product],
                              color: _selectedProduct == product
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSecondaryContainer,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product,
                            style: textTheme.labelLarge?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
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
