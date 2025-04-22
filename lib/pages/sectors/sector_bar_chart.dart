import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:provider/provider.dart';

class SectorBarChart extends StatefulWidget {
  const SectorBarChart({super.key});

  @override
  State<SectorBarChart> createState() => _SectorBarChartState();
}

class _SectorBarChartState extends State<SectorBarChart> {
  int selectedYear = DateTime.now().year;

  Future<void> _selectYear(BuildContext context) async {
    final int? picked = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        int tempYear = selectedYear;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Year'),
              content: SizedBox(
                height: 300,
                width: 300,
                child: YearPicker(
                  selectedDate: DateTime(tempYear),
                  firstDate: DateTime(2018),
                  lastDate: DateTime(2025),
                  onChanged: (DateTime dateTime) {
                    setState(() {
                      tempYear = dateTime.year;
                    });
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, tempYear);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedYear = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only enable scrolling for screens smaller than this breakpoint
    final scrollBreakpoint = 600.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final needsScrolling = screenWidth < scrollBreakpoint;

    // Determine if we should use vertical layout for the header
    final useVerticalHeader = screenWidth < 450;

    return CommonCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: useVerticalHeader
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Agricultural Performance',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.center,
                          child: _buildYearSelector(context),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Agricultural Performance',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _buildYearSelector(context),
                      ],
                    ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300, // Set an appropriate height
              child: ChangeNotifierProvider(
                create: (context) => _BarChartProvider(),
                builder: (ctx, child) => needsScrolling
                    ? SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          width: scrollBreakpoint,
                          child: _buildDefaultLineChart(ctx),
                        ),
                      )
                    : _buildDefaultLineChart(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearSelector(BuildContext context) {
    return InkWell(
      onTap: () => _selectYear(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(selectedYear.toString()),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultLineChart(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      enableSideBySideSeriesPlacement: true,
      title: const ChartTitle(text: ''),
      legend: const Legend(isVisible: true, position: LegendPosition.top),
      primaryXAxis: const CategoryAxis(
        majorGridLines: MajorGridLines(width: 0),
      ),
      primaryYAxis: const NumericAxis(
        axisLine: AxisLine(width: 0),
        labelFormat: '{value}',
        majorTickLines: MajorTickLines(size: 0),
        majorGridLines: MajorGridLines(width: 1),
        rangePadding: ChartRangePadding.additional,
      ),
      series: _getDefaultColumnSeries(context),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        header: '',
        canShowMarker: false,
        textStyle: TextStyle(color: isDark ? Colors.black : Colors.grey),
      ),
    );
  }

  List<ColumnSeries<_ChartData, String>> _getDefaultColumnSeries(
      BuildContext context) {
    List<_ChartData> chartData =
        context.watch<_BarChartProvider>().chartData ?? [];

    return <ColumnSeries<_ChartData, String>>[
      ColumnSeries<_ChartData, String>(
        dataSource: chartData,
        xValueMapper: (_ChartData sales, _) => sales.x,
        yValueMapper: (_ChartData sales, _) => sales.y,
        color: Color(0xFFFE8111),
        name: 'Yield (Metric Tons)',
        width: 0.3, // Adjust bar width (relative to available space)
        spacing: 0.1, // Adjust spacing between bars within the same category
        dataLabelSettings: const DataLabelSettings(
            isVisible: true, textStyle: TextStyle(fontSize: 10)),
      ),
      ColumnSeries<_ChartData, String>(
        dataSource: chartData,
        color: Color(0xFF12E3D7),
        name: 'Value (Million PHP)',
        width: 0.3, // Adjust bar width (relative to available space)
        spacing: 0.1, // Adjust spacing between bars within the same category
        xValueMapper: (_ChartData sales, _) => sales.x,
        yValueMapper: (_ChartData sales, _) => sales.y2,
        dataLabelSettings: const DataLabelSettings(
            isVisible: true, textStyle: TextStyle(fontSize: 10)),
      )
    ];
  }
}

class _ChartData {
  _ChartData(this.x, this.y, this.y2);

  final String x; // Year or Date
  final double y; // Yield (Metric Tons)
  final double y2; // Value (Million PHP)
}

class _BarChartProvider extends ChangeNotifier {
  List<_ChartData>? chartData = <_ChartData>[
    _ChartData('Rice', 18, 45),
    _ChartData('Corn', 22, 52),
    _ChartData('Organic', 19, 48),
    _ChartData('Livestock', 25, 62),
    _ChartData('Fishery', 28, 75),
    _ChartData('High Value Crops', 32, 85),
  ];

  void init() {}

  @override
  void dispose() {
    chartData?.clear();
    super.dispose();
  }
}
