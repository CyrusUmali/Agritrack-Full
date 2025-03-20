// year_filter_dropdown.dart
import 'package:flutter/material.dart';

class YearFilterDropdown extends StatelessWidget {
  final int selectedYear;
  final ValueChanged<int?> onYearChanged;

  const YearFilterDropdown({
    super.key,
    required this.selectedYear,
    required this.onYearChanged,
  });

  @override
  Widget build(BuildContext context) {
    // List of years for the dropdown
    final List<int> years =
        List.generate(10, (index) => DateTime.now().year - index);

    return Align(
      alignment: Alignment.centerRight, // Align the entire widget to the right
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize
              .min, // Make the Row take up only as much space as needed
          children: [
            const Icon(Icons.calendar_today,
                size: 20, color: Color.fromARGB(255, 8, 8, 8)),
            const SizedBox(width: 8),
            const Text(
              '',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            DropdownButton<int>(
              value: selectedYear,
              onChanged: onYearChanged,
              dropdownColor: Colors.white,
              icon: const Icon(Icons.arrow_drop_down,
                  color: Color.fromARGB(255, 0, 0, 0)),
              underline: const SizedBox(), // Remove the default underline
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
              items: years.map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(
                    value.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
