import 'package:flutter/material.dart';
import '../filter_configs/column_options.dart';

class ColumnSelector extends StatelessWidget {
  final String reportType;
  final Set<String> selectedColumns;
  final ValueChanged<Set<String>> onColumnsChanged;

  const ColumnSelector({
    super.key,
    required this.reportType,
    required this.selectedColumns,
    required this.onColumnsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final columns = ColumnOptions.reportColumns[reportType] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Columns',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: columns.map((column) {
            return FilterChip(
              label: Text(column),
              selected: selectedColumns.contains(column),
              onSelected: (selected) {
                final newColumns = Set<String>.from(selectedColumns);
                if (selected) {
                  newColumns.add(column);
                } else {
                  newColumns.remove(column);
                }
                onColumnsChanged(newColumns);
              },
              selectedColor: Colors.blue[200], // Light blue when selected
              checkmarkColor: Colors.blue[800], // Dark blue checkmark
              backgroundColor: Colors.grey[200], // Light grey when not selected
              labelStyle: TextStyle(
                color: selectedColumns.contains(column)
                    ? Colors.blue[900] // Dark blue text when selected
                    : Colors.black, // Black text when not selected
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
