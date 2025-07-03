import 'package:flutter/material.dart';

class YearlyDataTable extends StatelessWidget {
  final Map<String, double> yearlyData;
  final String product;

  const YearlyDataTable({
    super.key,
    required this.yearlyData,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (yearlyData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.bar_chart,
                  size: 48, color: theme.primaryColor.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text(
                'No yearly records available for $product',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.primaryColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final years = yearlyData.keys.toList()..sort((a, b) => b.compareTo(a));

    return DataTable(
      headingRowColor:
          MaterialStateProperty.all(theme.primaryColor.withOpacity(0.1)),
      dataRowMaxHeight: 60,
      columns: [
        DataColumn(
          label: Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: theme.primaryColor),
              const SizedBox(width: 8),
              const Text('Year', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        DataColumn(
          label: Row(
            children: [
              Icon(Icons.trending_up, size: 16, color: theme.primaryColor),
              const SizedBox(width: 8),
              Text('$product Yield (kg)',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          numeric: true,
        ),
      ],
      rows: years.map((year) {
        final value = yearlyData[year];
        return DataRow(
          cells: [
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  year,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        value?.toStringAsFixed(0) ?? 'N/A',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
