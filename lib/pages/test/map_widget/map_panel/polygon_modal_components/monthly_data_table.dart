import 'package:flareline/core/models/yield_model.dart';
import 'package:flutter/material.dart';

class MonthlyDataTable extends StatelessWidget {
  final String product;
  final int year;
  final Map<String, double> monthlyData;

  const MonthlyDataTable({
    super.key,
    required this.product,
    required this.year,
    required this.monthlyData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (monthlyData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.bar_chart,
                  size: 48, color: theme.primaryColor.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text(
                'No monthly records available for $year',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.primaryColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Ensure all months are shown even if they have 0 values
    final allMonths = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    final sortedData = Map.fromEntries(
        allMonths.map((month) => MapEntry(month, monthlyData[month] ?? 0.0)));

    return DataTable(
      headingRowColor:
          MaterialStateProperty.all(theme.primaryColor.withOpacity(0.1)),
      dataRowMaxHeight: 60,
      columns: [
        DataColumn(
          label: Row(
            children: [
              Icon(Icons.calendar_month, size: 16, color: theme.primaryColor),
              const SizedBox(width: 8),
              const Text('Month',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        DataColumn(
          label: Row(
            children: [
              Icon(Icons.scale, size: 16, color: theme.primaryColor),
              const SizedBox(width: 8),
              Text('$product Yield (kg)',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          numeric: true,
        ),
      ],
      rows: sortedData.entries.map((entry) {
        return DataRow(
          cells: [
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  entry.key,
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
                        entry.value.toStringAsFixed(0),
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
