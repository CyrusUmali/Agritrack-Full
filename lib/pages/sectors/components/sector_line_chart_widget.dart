import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../components/sector_data_model.dart';

class SectorLineChartWidget extends StatelessWidget {
  final String title;
  final List<SectorData> datas;
  final List<String> dropdownItems;
  final List<CartesianChartAnnotation>? annotations;
  final String unit; // Add this line

  const SectorLineChartWidget({
    super.key,
    required this.title,
    required this.datas,
    required this.dropdownItems,
    this.annotations,
    this.unit = 'mt', // Default unit
  });

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      annotations: _getAllAnnotations(),
      plotAreaBorderWidth: 0,
      title: ChartTitle(
        text: title,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        alignment: ChartAlignment.near,
      ),
      legend: Legend(
        isVisible: true,
        position: LegendPosition.right,
        orientation: LegendItemOrientation.vertical,
        overflowMode: LegendItemOverflowMode.scroll,
        itemPadding: 8,
        height: '300',
      ),
      primaryXAxis: CategoryAxis(
        labelStyle: const TextStyle(fontWeight: FontWeight.normal),
        majorGridLines: const MajorGridLines(
            width: 1,
            color: Color.fromARGB(255, 230, 229, 229)), // Added grid lines
        majorTickLines: const MajorTickLines(width: 0), // Hide tick marks
        axisLine: const AxisLine(width: 1, color: Colors.black), // X-axis line
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: 'Production ($unit)'), // Use the unit here
        labelFormat: '{value}',
        numberFormat: NumberFormat("#,###"),
        axisLine: const AxisLine(width: 1, color: Colors.black), // Y-axis line
        majorGridLines: const MajorGridLines(
            width: 1,
            color: Color.fromARGB(255, 230, 229, 229)), // Added grid lines
        majorTickLines: const MajorTickLines(width: 0), // Hide tick marks
      ),
      series: _getLineSeries(),
      tooltipBehavior: _buildTooltipBehavior(),
    );
  }

  List<CartesianChartAnnotation> _getAllAnnotations() {
    final allAnnotations = <CartesianChartAnnotation>[];

    if (annotations != null) {
      allAnnotations.addAll(annotations!);
    }

    for (final sector in datas) {
      if (sector.annotations != null) {
        for (final entry in sector.annotations!.entries) {
          final xValue = entry.key;
          final annotationText = entry.value;

          final point = sector.data.firstWhere(
            (point) => point['x'] == xValue,
            orElse: () => {'x': xValue, 'y': 0},
          );

          allAnnotations.add(
            CartesianChartAnnotation(
              widget: SizedBox(
                width: 20, // Adjust to your needs
                child: Tooltip(
                  message: 'This is an annotation for ${sector.name}',
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: sector.color),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.label, size: 14, color: sector.color),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            annotationText,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              coordinateUnit: CoordinateUnit.point,
              x: xValue,
              y: point['y'],
              horizontalAlignment: ChartAlignment.near,
              verticalAlignment: ChartAlignment.far,
            ),
          );
        }
      }
    }

    return allAnnotations;
  }

  List<LineSeries<Map<String, dynamic>, String>> _getLineSeries() {
    return datas.map((sector) {
      return LineSeries<Map<String, dynamic>, String>(
        name: sector.name,
        color: sector.color,
        dataSource: sector.data,
        xValueMapper: (Map<String, dynamic> data, _) => data['x'] as String,
        yValueMapper: (Map<String, dynamic> data, _) => data['y'] as num,
        markerSettings: const MarkerSettings(isVisible: true),
      );
    }).toList();
  }

  TooltipBehavior _buildTooltipBehavior() {
    return TooltipBehavior(
      enable: true,
      header: '',
      canShowMarker: true,
      builder: (dynamic data, dynamic point, dynamic series, int pointIndex,
          int seriesIndex) {
        final note = series.dataSource[pointIndex]['note'];
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${data['x']}: ${NumberFormat("#,###").format(data['y'])} $unit', // Use unit here
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (note != null)
                Text(
                  note,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),
        );
      },
    );
  }
}
