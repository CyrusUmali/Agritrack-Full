import 'package:flutter/material.dart';

class YieldHistory extends StatefulWidget {
  final List<dynamic> yearlyYield;
  final List<dynamic> monthlyYield;

  const YieldHistory({
    super.key,
    required this.yearlyYield,
    required this.monthlyYield,
  });

  @override
  State<YieldHistory> createState() => _YieldHistoryState();
}

class _YieldHistoryState extends State<YieldHistory> {
  // Dummy yearly yield data
  static final List<Map<String, dynamic>> dummyYearlyYield = [
    {'year': '2020', 'yield': 120},
    {'year': '2021', 'yield': 180},
    {'year': '2022', 'yield': 210},
    {'year': '2023', 'yield': 190},
    {'year': '2024', 'yield': 250},
  ];

  // Dummy monthly yield data for multiple years
  static final Map<String, List<Map<String, dynamic>>> dummyMonthlyYieldByYear =
      {
    '2020': [
      {'month': 'Jan', 'yield': 10},
      {'month': 'Feb', 'yield': 12},
      {'month': 'Mar', 'yield': 15},
      {'month': 'Apr', 'yield': 18},
      {'month': 'May', 'yield': 20},
      {'month': 'Jun', 'yield': 22},
      {'month': 'Jul', 'yield': 25},
      {'month': 'Aug', 'yield': 23},
      {'month': 'Sep', 'yield': 20},
      {'month': 'Oct', 'yield': 18},
      {'month': 'Nov', 'yield': 15},
      {'month': 'Dec', 'yield': 12},
    ],
    '2021': [
      {'month': 'Jan', 'yield': 12},
      {'month': 'Feb', 'yield': 15},
      {'month': 'Mar', 'yield': 18},
      {'month': 'Apr', 'yield': 20},
      {'month': 'May', 'yield': 25},
      {'month': 'Jun', 'yield': 28},
      {'month': 'Jul', 'yield': 30},
      {'month': 'Aug', 'yield': 28},
      {'month': 'Sep', 'yield': 25},
      {'month': 'Oct', 'yield': 22},
      {'month': 'Nov', 'yield': 18},
      {'month': 'Dec', 'yield': 15},
    ],
    '2022': [
      {'month': 'Jan', 'yield': 15},
      {'month': 'Feb', 'yield': 18},
      {'month': 'Mar', 'yield': 20},
      {'month': 'Apr', 'yield': 22},
      {'month': 'May', 'yield': 25},
      {'month': 'Jun', 'yield': 30},
      {'month': 'Jul', 'yield': 35},
      {'month': 'Aug', 'yield': 32},
      {'month': 'Sep', 'yield': 28},
      {'month': 'Oct', 'yield': 25},
      {'month': 'Nov', 'yield': 20},
      {'month': 'Dec', 'yield': 18},
    ],
    '2023': [
      {'month': 'Jan', 'yield': 18},
      {'month': 'Feb', 'yield': 20},
      {'month': 'Mar', 'yield': 22},
      {'month': 'Apr', 'yield': 25},
      {'month': 'May', 'yield': 28},
      {'month': 'Jun', 'yield': 32},
      {'month': 'Jul', 'yield': 35},
      {'month': 'Aug', 'yield': 33},
      {'month': 'Sep', 'yield': 30},
      {'month': 'Oct', 'yield': 28},
      {'month': 'Nov', 'yield': 25},
      {'month': 'Dec', 'yield': 22},
    ],
    '2024': [
      {'month': 'Jan', 'yield': 15},
      {'month': 'Feb', 'yield': 18},
      {'month': 'Mar', 'yield': 22},
      {'month': 'Apr', 'yield': 25},
      {'month': 'May', 'yield': 30},
      {'month': 'Jun', 'yield': 35},
      {'month': 'Jul', 'yield': 40},
      {'month': 'Aug', 'yield': 38},
      {'month': 'Sep', 'yield': 32},
      {'month': 'Oct', 'yield': 28},
      {'month': 'Nov', 'yield': 20},
      {'month': 'Dec', 'yield': 15},
    ],
  };

  String? _selectedYear;

  @override
  void initState() {
    super.initState();
    // Set the default selected year to the most recent year available
    final years = dummyMonthlyYieldByYear.keys.toList()..sort();
    _selectedYear = years.last;
  }

  @override
  Widget build(BuildContext context) {
    // Use the provided data if available, otherwise use dummy data
    final effectiveYearlyYield =
        widget.yearlyYield.isNotEmpty ? widget.yearlyYield : dummyYearlyYield;
    final effectiveMonthlyYield = widget.monthlyYield.isNotEmpty
        ? widget.monthlyYield
        : dummyMonthlyYieldByYear[_selectedYear] ?? [];

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Yield History',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            _buildYearlyYield(context, effectiveYearlyYield),
            const SizedBox(height: 24),
            _buildMonthlyYield(context, effectiveMonthlyYield),
          ],
        ),
      ),
    );
  }

  Widget _buildYearlyYield(BuildContext context, List<dynamic> yieldData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Yearly Yield',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: yieldData.length,
            itemBuilder: (context, index) {
              final data = yieldData[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    Text(data['year']?.toString() ?? 'Year'),
                    const SizedBox(height: 4),
                    Container(
                      width: 40,
                      height:
                          150 * (data['yield'] ?? 0) / _getMaxYield(yieldData),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('${data['yield']?.toString() ?? '0'} tons'),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyYield(BuildContext context, List<dynamic> yieldData) {
    // Get available years for dropdown
    final availableYears = dummyMonthlyYieldByYear.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Monthly Yield',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            DropdownButton<String>(
              value: _selectedYear,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedYear = newValue;
                });
              },
              items:
                  availableYears.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              underline: Container(
                height: 1,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: yieldData.length,
            itemBuilder: (context, index) {
              final data = yieldData[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Column(
                  children: [
                    Text(data['month']?.toString() ?? 'Month'),
                    const SizedBox(height: 4),
                    Container(
                      width: 30,
                      height:
                          150 * (data['yield'] ?? 0) / _getMaxYield(yieldData),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('${data['yield']?.toString() ?? '0'} tons'),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  double _getMaxYield(List<dynamic> yieldData) {
    if (yieldData.isEmpty) return 1;

    double max = 0;
    for (var data in yieldData) {
      final value = (data['yield'] as num?)?.toDouble() ?? 0;
      if (value > max) max = value;
    }
    return max == 0 ? 1 : max;
  }
}
