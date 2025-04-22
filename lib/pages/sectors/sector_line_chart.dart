import 'package:flareline/pages/sectors/components/annotation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as chart;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'components/sector_line_chart_widget.dart';
import './components/sector_data_model.dart';

class SectorLineChart extends StatefulWidget {
  const SectorLineChart({super.key});

  @override
  State<SectorLineChart> createState() => _SectorLineChartState();
}

class _SectorLineChartState extends State<SectorLineChart> {
  String selectedSector = 'Rice';
  int selectedFromYear = 2020;
  int selectedToYear = 2025;
  List<CartesianChartAnnotation> customAnnotations = [];
  final GlobalKey _chartKey = GlobalKey();

  Future<void> _selectYearRange(BuildContext context) async {
    final List<int>? picked = await showDialog<List<int>>(
      context: context,
      builder: (BuildContext context) {
        int tempFromYear = selectedFromYear;
        int tempToYear = selectedToYear;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Year Range'),
              content: SizedBox(
                height: 400,
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('From Year:'),
                    SizedBox(
                      height: 150,
                      child: YearPicker(
                        selectedDate: DateTime(tempFromYear),
                        firstDate: DateTime(2018),
                        lastDate: DateTime(2025),
                        onChanged: (DateTime dateTime) {
                          setState(() {
                            tempFromYear = dateTime.year;
                            if (tempFromYear > tempToYear) {
                              tempToYear = tempFromYear;
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('To Year:'),
                    SizedBox(
                      height: 150,
                      child: YearPicker(
                        selectedDate: DateTime(tempToYear),
                        firstDate: DateTime(tempFromYear),
                        lastDate: DateTime(2025),
                        onChanged: (DateTime dateTime) {
                          setState(() {
                            tempToYear = dateTime.year;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, [tempFromYear, tempToYear]);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );

    if (picked != null && picked.length == 2) {
      setState(() {
        selectedFromYear = picked[0];
        selectedToYear = picked[1];
      });
    }
  }

  void _handleChartTap(TapDownDetails details) {
    final renderBox =
        _chartKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = details.localPosition;
    final chartSize = renderBox.size;

    // Get the chart widget to access its properties
    final chartWidget = _chartKey.currentWidget as SectorLineChartWidget?;
    if (chartWidget == null) return;

    // Convert tap position to chart coordinates
    final xValue = _convertXToValue(offset.dx, chartSize.width, chartWidget);
    final yValue = _convertYToValue(offset.dy, chartSize.height, chartWidget);

    _showAnnotationDialog(xValue, yValue);
  }

  String _convertXToValue(
      double x, double width, SectorLineChartWidget chartWidget) {
    // If you want to use the simple version without chart state:
    final years = selectedToYear - selectedFromYear + 1;
    final yearIndex = (x / width * years).clamp(0, years - 1).floor();
    return (selectedFromYear + yearIndex).toString();

    // OR if you want to use the chart state version:
    // final chartState = _chartKey.currentState as chart.SfCartesianChartState?;
    // if (chartState == null) return selectedFromYear.toString();
    // final point = chartState.chartPointToLocal(Offset(x, 0));
    // final xValue = chartState.pointToXValue(point);
    // return xValue.round().toString();
  }

  double _convertYToValue(
      double y, double height, SectorLineChartWidget chartWidget) {
    // Simple version:
    double minValue = double.infinity;
    double maxValue = -double.infinity;

    for (final sector in _getFilteredData()) {
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

    // OR chart state version:
    // final chartState = _chartKey.currentState as chart.SfCartesianChartState?;
    // if (chartState == null) return 0;
    // final point = chartState.chartPointToLocal(Offset(0, y));
    // return chartState.pointToYValue(point);
  }

  Future<void> _showAnnotationDialog(String xValue, double yValue) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => SimpleAnnotationDialog(
        year: xValue,
        initialValue: yValue,
        initialText: '',
      ),
    );

    if (result != null && result['text'] != null) {
      setState(() {
        customAnnotations.add(
          CartesianChartAnnotation(
            widget: _buildAnnotationWidget(
              result['text'],
              customAnnotations.length,
              result['value'],
            ),
            x: xValue,
            y: result['value'],
            coordinateUnit: chart.CoordinateUnit.point,
            horizontalAlignment: chart.ChartAlignment.near,
            verticalAlignment: ChartAlignment.far,
          ),
        );
      });
    }
  }

  Widget _buildAnnotationWidget(String text, int index, double value) {
    // Add a key to make it easier to identify this widget
    final key = ValueKey('annotation_${index}_${value}');

    return GestureDetector(
      key: key,
      onTap: () => _editAnnotation(index),
      onLongPress: () => _deleteAnnotation(index),
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
            // Use a key for the Text widget too
            Text(text, key: ValueKey('annotation_text_$index')),
          ],
        ),
      ),
    );
  }

  Future<void> _editAnnotation(int index) async {
    print('Starting edit annotation at index $index');
    if (index < 0 || index >= customAnnotations.length) {
      print('Invalid index: $index');
      return;
    }

    final annotation = customAnnotations[index];
    print('Editing annotation at position: ${annotation.x}, ${annotation.y}');

    // Extract current text from the annotation widget
    String currentText = '';
    double currentValue = annotation.y;

    try {
      print('Attempting to extract annotation text...');

      // First try to get the widget
      final widget = annotation.widget;
      print('Widget type: ${widget.runtimeType}');

      if (widget is GestureDetector) {
        print('Widget is GestureDetector');
        final child = widget.child;
        print('Child type: ${child.runtimeType}');

        if (child is Container) {
          print('Child is Container');
          final containerChild = child.child;
          print('Container child type: ${containerChild.runtimeType}');

          if (containerChild is Row) {
            print('Container child is Row');
            for (var i = 0; i < containerChild.children.length; i++) {
              print(
                  'Row child $i type: ${containerChild.children[i].runtimeType}');
            }

            // Try to find the Text widget - it might be in different positions
            for (final child in containerChild.children) {
              if (child is Text) {
                currentText = child.data ?? '';
                print('Found Text widget with content: "$currentText"');
                break;
              }
              // Also check if text is inside other widgets like Padding
              if (child is Padding) {
                final paddedChild = child.child;
                if (paddedChild is Text) {
                  currentText = paddedChild.data ?? '';
                  print(
                      'Found Text widget inside Padding with content: "$currentText"');
                  break;
                }
              }
            }
          }
        }
      }
    } catch (e, stackTrace) {
      print('Error extracting annotation text: $e');
      print('Stack trace: $stackTrace');
    }

    print('Extracted text: "$currentText", value: $currentValue');

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
      print(
          'Received updated annotation: ${result['text']}, ${result['value']}');
      setState(() {
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
      });
    } else if (result != null && result['delete'] == true) {
      _deleteAnnotation(index);
    } else {
      print('Annotation edit was cancelled');
    }
  }

  void _deleteAnnotation(int index) {
    setState(() {
      customAnnotations.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scrollBreakpoint = 600.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final needsScrolling = screenWidth < scrollBreakpoint;
    final useVerticalHeader = screenWidth < 450;

    final filteredData = _getFilteredData();

    return CommonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (useVerticalHeader) ...[
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Agricultural Performance',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.center,
                    child: _buildSectorDropdown(),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.center,
                    child: _buildYearRangePickerButton(context),
                  ),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Agricultural Performance',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Row(
                        children: [
                          _buildSectorDropdown(),
                          const SizedBox(width: 12),
                          _buildYearRangePickerButton(context),
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          GestureDetector(
            onTapDown: _handleChartTap,
            child: SizedBox(
              height: 380,
              child: needsScrolling
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        width: scrollBreakpoint,
                        child: SectorLineChartWidget(
                          key: _chartKey,
                          title: '',
                          dropdownItems: [],
                          datas: filteredData,
                          annotations: customAnnotations,
                        ),
                      ),
                    )
                  : SectorLineChartWidget(
                      key: _chartKey,
                      title: '',
                      dropdownItems: [],
                      datas: filteredData,
                      annotations: customAnnotations,
                    ),
            ),
          ),
          if (customAnnotations.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Tap annotations to edit, long press to delete',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ),
        ],
      ),
    );
  }

  List<SectorData> _getFilteredData() {
    return (sectorData[selectedSector] ?? [])
        .map((sector) {
          final filteredSeriesData = sector.data.where((point) {
            final year = int.parse(point['x']);
            return year >= selectedFromYear && year <= selectedToYear;
          }).toList();

          return SectorData(
            name: sector.name,
            color: sector.color,
            data: filteredSeriesData,
            annotations: sector.annotations,
          );
        })
        .where((sector) => sector.data.isNotEmpty)
        .toList();
  }

  Widget _buildSectorDropdown() {
    return PopupMenuButton<String>(
      initialValue: selectedSector,
      onSelected: (String value) {
        setState(() {
          selectedSector = value;
        });
      },
      itemBuilder: (BuildContext context) {
        return ['Rice', 'Corn', 'Fishery', 'Livestock', 'Organic', 'HVC']
            .map((String item) {
          return PopupMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(selectedSector),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildYearRangePickerButton(BuildContext context) {
    return InkWell(
      onTap: () => _selectYearRange(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$selectedFromYear - $selectedToYear'),
            const SizedBox(width: 8),
            const Icon(Icons.calendar_today, size: 16),
          ],
        ),
      ),
    );
  }
}
