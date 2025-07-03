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
    final dateFormat = DateFormat('MMM d, yyyy');
    final isRangeSelected = dateRange.start != dateRange.end;

    return SizedBox(
      height: 48,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Match the combo box
          ),
          side: BorderSide(color: Colors.grey[300]!), // Match border color
          backgroundColor: Colors.white, // White background like combo box
          foregroundColor: Colors.black, // Black text
          textStyle: const TextStyle(fontSize: 14), // Same font size
        ),
        onPressed: () async => await _showDatePicker(context, isDesktop),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                isRangeSelected
                    ? '${dateFormat.format(dateRange.start)} - ${dateFormat.format(dateRange.end)}'
                    : 'Date Range',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isRangeSelected ? Colors.black : Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isRangeSelected ? Icons.close : Icons.calendar_today,
              size: 20, // Match the combo box icon size
              color: Colors.grey[600],
            ),
          ],
        ),
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
        fontWeight: FontWeight.normal,
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
                    TextButton(
                      onPressed: () {
                        // Clear selection
                        Navigator.of(context).pop([null, null]);
                      },
                      child: const Text('Clear'),
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

    if (results != null) {
      if (results.length == 2 && results[0] != null && results[1] != null) {
        onDateRangeChanged(DateTimeRange(
          start: results[0]!,
          end: results[1]!,
        ));
      } else if (results.every((date) => date == null)) {
        // Clear the range if both dates are null
        final now = DateTime.now();
        onDateRangeChanged(DateTimeRange(start: now, end: now));
      }
    }
  }
}
