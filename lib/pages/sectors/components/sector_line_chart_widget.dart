import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../components/sector_data_model.dart';

class SectorLineChartWidget extends StatelessWidget {
  final String title;
  final List<SectorData> datas;
  final List<String> dropdownItems;
  final List<CartesianChartAnnotation>? annotations;

  const SectorLineChartWidget({
    super.key,
    required this.title,
    required this.datas,
    required this.dropdownItems,
    this.annotations,
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
        position: LegendPosition.right, // or left
        orientation: LegendItemOrientation.vertical,
        overflowMode: LegendItemOverflowMode.scroll,
        itemPadding: 8,
        height: '300', // fixed height as a string (in pixels)
      ),
      primaryXAxis: CategoryAxis(
        labelStyle: const TextStyle(fontWeight: FontWeight.normal),
        majorGridLines: const MajorGridLines(width: 0),
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: 'Production (kg)'),
        labelFormat: '{value}',
        numberFormat: NumberFormat("#,###"),
        axisLine: const AxisLine(width: 0),
        majorTickLines: const MajorTickLines(color: Colors.transparent),
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
              widget: Container(
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
                    Text(annotationText),
                  ],
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
                '${data['x']}: ${NumberFormat("#,###").format(data['y'])} kg', // Changed to show kg
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
