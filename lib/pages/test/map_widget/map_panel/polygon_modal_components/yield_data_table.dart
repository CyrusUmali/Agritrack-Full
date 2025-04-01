import 'package:flutter/material.dart';

class YieldDataTable {
  static Widget build({
    required String selectedYear,
    required ThemeData theme,
  }) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final Map<String, Map<String, double>> yieldData = {
      "Tilapia": {
        "2018": 1000,
        "2019": 1200,
        "2020": 1100,
        "2023": 1150,
        DateTime.now().year.toString(): 1250,
      },
      "Bangus": {
        "2018": 800,
        "2019": 900,
        "2020": 850,
        "2023": 880,
        DateTime.now().year.toString(): 920,
      },
      "Shrimp": {
        "2018": 500,
        "2019": 600,
        "2020": 550,
        "2023": 580,
        DateTime.now().year.toString(): 620,
      },
    };

    final years = yieldData.values
        .expand((product) => product.keys)
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Yield Data",
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButton<String>(
                  value: selectedYear,
                  items: years.map((year) {
                    return DropdownMenuItem<String>(
                      value: year,
                      child: Text(year, style: textTheme.bodyMedium),
                    );
                  }).toList(),
                  onChanged: null, // You'll need to connect this
                  style: textTheme.bodyMedium,
                  dropdownColor: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  underline: Container(),
                  icon:
                      Icon(Icons.arrow_drop_down, color: colorScheme.onSurface),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: colorScheme.outlineVariant, width: 1),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(
                    label: Text('Product',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                  ...years
                      .map((year) => DataColumn(
                            label: Text(year,
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                )),
                          ))
                      .toList(),
                ],
                rows: yieldData.entries.map((entry) {
                  final product = entry.key;
                  final yields = entry.value;
                  return DataRow(
                    cells: [
                      DataCell(Text(product, style: textTheme.bodyMedium)),
                      ...years
                          .map((year) => DataCell(
                                Text(yields[year]?.toStringAsFixed(2) ?? '-',
                                    style: textTheme.bodyMedium),
                              ))
                          .toList(),
                    ],
                  );
                }).toList(),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                headingRowHeight: 48,
                dataRowHeight: 48,
                dividerThickness: 1,
                horizontalMargin: 16,
                columnSpacing: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
