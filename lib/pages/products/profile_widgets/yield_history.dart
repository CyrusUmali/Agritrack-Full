import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class YieldHistory extends StatefulWidget {
  final Map<String, dynamic> product;
  final bool isMobile;

  const YieldHistory({
    super.key,
    required this.product,
    this.isMobile = false,
  });

  @override
  State<YieldHistory> createState() => YieldHistoryState();
}

class YieldHistoryState extends State<YieldHistory> {
  String? _selectedYear;
  String? _startYear;
  String? _endYear;
  bool _showMonthlyView = false;

  @override
  void initState() {
    super.initState();
    _initializeSelections();
  }

  void _initializeSelections() {
    // Initialize years
    final yields = (widget.product['yields'] as List?)
        ?.whereType<Map<String, dynamic>>()
        .toList();
    if (yields != null && yields.isNotEmpty) {
      yields.sort((a, b) => (a['year'] ?? '').compareTo(b['year'] ?? ''));
      _selectedYear = yields.last['year']?.toString();
      _startYear = yields.first['year']?.toString();
      _endYear = yields.last['year']?.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final yields = (widget.product['yields'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .toList() ??
        [];

    return CommonCard(
      child: Padding(
        padding: EdgeInsets.all(widget.isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Yield History',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (yields.isEmpty)
              const Center(child: Text('No yield data recorded')),
            if (yields.isNotEmpty) ...[
              _buildViewToggle(),
              const SizedBox(height: 16),
              _buildDateRangeControls(),
              const SizedBox(height: 16),
              _buildChart(yields),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () => setState(() => _showMonthlyView = false),
              style: TextButton.styleFrom(
                foregroundColor: _showMonthlyView
                    ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                    : Theme.of(context).colorScheme.primary,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: Text('Yearly'),
            ),
            TextButton(
              onPressed: () => setState(() => _showMonthlyView = true),
              style: TextButton.styleFrom(
                foregroundColor: _showMonthlyView
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: Text('Monthly'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeControls() {
    final yields = (widget.product['yields'] as List?)
        ?.whereType<Map<String, dynamic>>()
        .toList();
    if (yields == null || yields.isEmpty) return SizedBox();

    final years =
        yields.map((y) => y['year']?.toString()).whereType<String>().toList();
    years.sort();

    if (_showMonthlyView) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Year: '),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: _selectedYear,
            items: years.map((year) {
              return DropdownMenuItem<String>(
                value: year,
                child: Text(year),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedYear = newValue;
                });
              }
            },
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('From: '),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: _startYear,
            items: years.map((year) {
              return DropdownMenuItem<String>(
                value: year,
                child: Text(year),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _startYear = newValue;
                  if (_endYear != null &&
                      _startYear!.compareTo(_endYear!) > 0) {
                    _endYear = _startYear;
                  }
                });
              }
            },
          ),
          const SizedBox(width: 16),
          Text('To: '),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: _endYear,
            items: years
                .where((year) => year.compareTo(_startYear ?? '') >= 0)
                .map((year) {
              return DropdownMenuItem<String>(
                value: year,
                child: Text(year),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _endYear = newValue;
                });
              }
            },
          ),
        ],
      );
    }
  }

  Widget _buildChart(List<Map<String, dynamic>> yields) {
    if (yields.isEmpty) {
      return const Center(child: Text('No yield data available'));
    }

    if (_showMonthlyView) {
      return _buildMonthlyChart(yields);
    } else {
      return _buildYearlyChart(yields);
    }
  }

  Widget _buildMonthlyChart(List<Map<String, dynamic>> yields) {
    final selectedYield = yields.firstWhere(
      (y) => y['year'] == _selectedYear,
      orElse: () => {'monthly': List.filled(12, 0), 'year': ''},
    );

    final monthlyData =
        selectedYield['monthly'] as List<dynamic>? ?? List.filled(12, 0);
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    final chartData = List.generate(12, (index) {
      return _ChartData(
        months[index],
        (monthlyData[index] as num?)?.toDouble() ?? 0,
        0, // We don't have value data in this example
      );
    });

    return SizedBox(
      height: 300,
      child: _buildBarChart(
        chartData,
        title: 'Monthly Yield for $_selectedYear (tons)',
      ),
    );
  }

  Widget _buildYearlyChart(List<Map<String, dynamic>> yields) {
    final filteredYields = yields.where((yieldData) {
      final year = yieldData['year']?.toString() ?? '';
      return (_startYear == null || year.compareTo(_startYear!) >= 0) &&
          (_endYear == null || year.compareTo(_endYear!) <= 0);
    }).toList();

    filteredYields.sort((a, b) => (a['year'] ?? '').compareTo(b['year'] ?? ''));

    final chartData = filteredYields.map((yieldData) {
      final year = yieldData['year']?.toString() ?? 'Unknown';
      final monthly = yieldData['monthly'] as List<dynamic>? ?? [];
      final totalYield = monthly.fold<double>(
          0, (sum, value) => sum + (value is num ? value.toDouble() : 0));

      return _ChartData(
        year,
        totalYield,
        0, // We don't have value data in this example
      );
    }).toList();

    return SizedBox(
      height: 300,
      child: _buildBarChart(
        chartData,
        title: 'Yearly Yield (${_startYear} - ${_endYear}) (tons)',
      ),
    );
  }

  Widget _buildBarChart(List<_ChartData> chartData, {String title = ''}) {
    final needsScrolling = widget.isMobile && chartData.length > 5;
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    final chart = SfCartesianChart(
      plotAreaBorderWidth: 0,
      title: ChartTitle(text: title),
      legend: Legend(isVisible: true, position: LegendPosition.top),
      primaryXAxis: CategoryAxis(
        majorGridLines: const MajorGridLines(width: 0),
        labelRotation: needsScrolling ? -45 : 0,
      ),
      primaryYAxis: NumericAxis(
        axisLine: const AxisLine(width: 0),
        labelFormat: '{value}',
        majorTickLines: const MajorTickLines(size: 0),
        majorGridLines: const MajorGridLines(width: 1),
        rangePadding: ChartRangePadding.additional,
      ),
      series: <ColumnSeries<_ChartData, String>>[
        ColumnSeries<_ChartData, String>(
          dataSource: chartData,
          xValueMapper: (_ChartData data, _) => data.x,
          yValueMapper: (_ChartData data, _) => data.y,
          color: const Color(0xFFFE8111), // Orange color
          name: 'Yield (tons)',
          width: 0.6,
          spacing: 0.2,
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            textStyle: TextStyle(fontSize: 10),
          ),
        )
      ],
      tooltipBehavior: TooltipBehavior(
        enable: true,
        header: '',
        canShowMarker: false,
        textStyle: TextStyle(color: isDark ? Colors.black : Colors.grey),
      ),
    );

    return needsScrolling
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              width: chartData.length * 80.0,
              child: chart,
            ),
          )
        : chart;
  }
}

class _ChartData {
  _ChartData(this.x, this.y, this.y2);

  final String x; // Month or Year
  final double y; // Yield value
  final double y2; // Not used in this implementation
}
