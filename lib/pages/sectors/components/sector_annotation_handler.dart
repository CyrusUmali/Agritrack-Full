import 'package:flareline/pages/sectors/components/annotation_dialog.dart';
import 'package:flareline/pages/sectors/components/sector_data_model.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as chart;
import 'package:syncfusion_flutter_charts/charts.dart';

class SectorAnnotationHandler {
  final List<CartesianChartAnnotation> customAnnotations = [];
  final GlobalKey _chartKey;
  final Function(int) onEditAnnotation;
  final Function(int) onDeleteAnnotation;

  SectorAnnotationHandler({
    required GlobalKey chartKey,
    required this.onEditAnnotation,
    required this.onDeleteAnnotation,
  }) : _chartKey = chartKey;

  void handleChartTap(TapDownDetails details, BuildContext context,
      int selectedFromYear, int selectedToYear, List<SectorData> filteredData) {
    final renderBox =
        _chartKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = details.localPosition;
    final chartSize = renderBox.size;

    // Convert tap position to chart coordinates
    final xValue = _convertXToValue(
        offset.dx, chartSize.width, selectedFromYear, selectedToYear);
    final yValue = _convertYToValue(offset.dy, chartSize.height, filteredData);

    _showAnnotationDialog(context, xValue, yValue);
  }

  String _convertXToValue(
      double x, double width, int selectedFromYear, int selectedToYear) {
    final years = selectedToYear - selectedFromYear + 1;
    final yearIndex = (x / width * years).clamp(0, years - 1).floor();
    return (selectedFromYear + yearIndex).toString();
  }

  double _convertYToValue(
      double y, double height, List<SectorData> filteredData) {
    double minValue = double.infinity;
    double maxValue = -double.infinity;

    for (final sector in filteredData) {
      for (final point in sector.data) {
        final value = point['y'].toDouble();
        if (value < minValue) minValue = value;
        if (value > maxValue) maxValue = value;
      }
    }

    final range = maxValue - minValue;
    minValue = (minValue - range * 0.1).clamp(0, double.infinity);
    maxValue = maxValue + range * 0.1;

    final normalizedY = 1 - (y / height);
    return minValue + normalizedY * (maxValue - minValue);
  }

  Future<void> _showAnnotationDialog(
      BuildContext context, String xValue, double yValue) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => SimpleAnnotationDialog(
        year: xValue,
        initialValue: yValue,
        initialText: '',
      ),
    );

    if (result != null && result['text'] != null) {
      addAnnotation(
        xValue: xValue,
        yValue: result['value'],
        text: result['text'],
      );
    }
  }

  void addAnnotation({
    required String xValue,
    required double yValue,
    required String text,
  }) {
    customAnnotations.add(
      CartesianChartAnnotation(
        widget: _buildAnnotationWidget(
          text,
          customAnnotations.length,
          yValue,
        ),
        x: xValue,
        y: yValue,
        coordinateUnit: chart.CoordinateUnit.point,
        horizontalAlignment: chart.ChartAlignment.near,
        verticalAlignment: ChartAlignment.far,
      ),
    );
  }

  Widget _buildAnnotationWidget(String text, int index, double value) {
    final key = ValueKey('annotation_${index}_${value}');

    return GestureDetector(
      key: key,
      onTap: () => onEditAnnotation(index),
      onLongPress: () => onDeleteAnnotation(index),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.red),
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
            const Icon(Icons.label, size: 14, color: Colors.red),
            const SizedBox(width: 4),
            Text(text, key: ValueKey('annotation_text_$index')),
          ],
        ),
      ),
    );
  }

  Future<void> editAnnotation(BuildContext context, int index) async {
    if (index < 0 || index >= customAnnotations.length) {
      return;
    }

    final annotation = customAnnotations[index];
    String currentText = '';
    double currentValue = annotation.y;

    try {
      final widget = annotation.widget;
      if (widget is GestureDetector) {
        final child = widget.child;
        if (child is Container) {
          final containerChild = child.child;
          if (containerChild is Row) {
            for (final child in containerChild.children) {
              if (child is Text) {
                currentText = child.data ?? '';
                break;
              }
              if (child is Padding) {
                final paddedChild = child.child;
                if (paddedChild is Text) {
                  currentText = paddedChild.data ?? '';
                  break;
                }
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error extracting annotation text: $e');
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => SimpleAnnotationDialog(
        year: annotation.x,
        initialValue: currentValue,
        initialText: currentText,
        isEditing: true,
      ),
    );

    if (result != null && result['text'] != null) {
      customAnnotations[index] = CartesianChartAnnotation(
        widget: _buildAnnotationWidget(
          result['text'],
          index,
          result['value'],
        ),
        x: annotation.x,
        y: result['value'],
        coordinateUnit: annotation.coordinateUnit,
        horizontalAlignment: annotation.horizontalAlignment,
        verticalAlignment: annotation.verticalAlignment,
      );
    } else if (result != null && result['delete'] == true) {
      onDeleteAnnotation(index);
    }
  }

  void deleteAnnotation(int index) {
    customAnnotations.removeAt(index);
  }
}
