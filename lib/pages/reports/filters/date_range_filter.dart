import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangeFilter extends StatelessWidget {
  final DateTimeRange dateRange;
  final ValueChanged<DateTimeRange> onDateRangeChanged;

  const DateRangeFilter({
    super.key,
    required this.dateRange,
    required this.onDateRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Date Rangess',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () async {
              final newDateRange = await showDateRangePicker(
                context: context,
                initialDateRange: dateRange,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (newDateRange != null) {
                onDateRangeChanged(newDateRange);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(dateFormat.format(dateRange.start)),
                  const Text('to'),
                  Text(dateFormat.format(dateRange.end)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
