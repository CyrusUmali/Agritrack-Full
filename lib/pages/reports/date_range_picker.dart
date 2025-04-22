import 'package:flutter/material.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:intl/intl.dart';

class DateRangePickerWidget extends StatelessWidget {
  final DateTimeRange dateRange;
  final ValueChanged<DateTimeRange> onDateRangeChanged;

  const DateRangePickerWidget({
    super.key,
    required this.dateRange,
    required this.onDateRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Main date range button - flexible width on mobile, fixed on desktop
            if (isDesktop)
              SizedBox(
                width: 150,
                height: 30,
                child: _buildDateRangeButton(context, isDesktop),
              )
            else
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: _buildDateRangeButton(context, isDesktop),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateRangeButton(BuildContext context, bool isDesktop) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Chip-like roundness
        ),
        backgroundColor: Colors.grey[200], // Light grey background
        foregroundColor:
            const Color.fromARGB(255, 32, 31, 31), // Black text and icon
        textStyle: const TextStyle(fontSize: 14),
      ),
      onPressed: () async => await _showDatePicker(context, isDesktop),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              'Date Range',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.calendar_today,
            size: 16,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context, bool isDesktop) async {
    if (isDesktop) {
      await _showDesktopDatePicker(context);
    } else {
      final newRange = await showDateRangePicker(
        context: context,
        initialDateRange: dateRange,
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
      );
      if (newRange != null) {
        onDateRangeChanged(newRange);
      }
    }
  }

  Future<void> _showDesktopDatePicker(BuildContext context) async {
    List<DateTime?> selectedDates = [dateRange.start, dateRange.end];

    final config = CalendarDatePicker2Config(
      calendarType: CalendarDatePicker2Type.range,
      selectedDayHighlightColor: Theme.of(context).primaryColor,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      controlsHeight: 50,
      controlsTextStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    );

    final results = await showDialog<List<DateTime?>>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 600,
            maxHeight: 550,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select Date Range',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: CalendarDatePicker2(
                    config: config,
                    value: selectedDates,
                    onValueChanged: (dates) {
                      if (dates.length == 2) {
                        selectedDates = dates;
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(selectedDates),
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (results != null &&
        results.length == 2 &&
        results[0] != null &&
        results[1] != null) {
      onDateRangeChanged(DateTimeRange(
        start: results[0]!,
        end: results[1]!,
      ));
    }
  }
}
