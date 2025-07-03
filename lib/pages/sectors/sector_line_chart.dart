import 'package:flareline/core/models/yield_model.dart';
import 'package:flareline/pages/sectors/components/sector_annotation_handler.dart';
import 'package:flareline/pages/yields/yield_bloc/yield_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'components/sector_line_chart_widget.dart';
import './components/sector_data_model.dart';
import 'dart:convert';

class SectorLineChart extends StatefulWidget {
  const SectorLineChart({super.key});

  @override
  State<SectorLineChart> createState() => _SectorLineChartState();
}

class _SectorLineChartState extends State<SectorLineChart> {
  String selectedSector = 'All';
  int selectedFromYear = 2020;
  int selectedToYear = 2025;
  List<Yield> yieldData = [];
  final GlobalKey _chartKey = GlobalKey();
  late SectorAnnotationHandler annotationHandler;

  @override
  void initState() {
    super.initState();
    annotationHandler = SectorAnnotationHandler(
      chartKey: _chartKey,
      onEditAnnotation: _editAnnotation,
      onDeleteAnnotation: _deleteAnnotation,
    );

    final yieldBloc = context.read<YieldBloc>();
    if (yieldBloc.state is YieldsLoaded) {
      yieldData = (yieldBloc.state as YieldsLoaded).yields;
      sectorData = buildSectorDataFromYields(yieldData);
      // _printYieldData();
    }

    yieldBloc.stream.listen((state) {
      if (state is YieldsLoaded) {
        setState(() {
          yieldData = state.yields;
          sectorData = buildSectorDataFromYields(yieldData);

          // Print the raw structure
          // print('=== RAW SECTOR DATA ===');
          // sectorData.forEach((sector, products) {
          //   print('$sector: [');
          //   for (var product in products) {
          //     print('  ${product.toString()},');
          //   }
          //   print(']');
          // });

          // Alternative JSON output (requires all elements to be encodable)
          try {
            final jsonData = {
              for (var entry in sectorData.entries)
                entry.key: entry.value.map((e) => e.toJson()).toList()
            };
            // print('\n=== JSON STRUCTURE ===');
            // print(jsonEncode(jsonData));
          } catch (e) {
            print('\nFailed to encode as JSON: $e');
          }
        });

        // _printYieldData();
      }
    });
  }

  void _printYieldData() {
    if (yieldData.isEmpty) {
      print('No yield data available');
      return;
    }

    print('\n===== YIELD DATA (${yieldData.length} records) =====');

    for (var i = 0; i < yieldData.length; i++) {
      final yield = yieldData[i];
      print('\nRecord #${i + 1}:');
      print('  ID: ${yield.id}');
      print('  Farmer: ${yield.farmerName} (ID: ${yield.farmerId})');
      print('  Product: ${yield.productName} (ID: ${yield.productId})');
      print('  Sector: ${yield.sector} (ID: ${yield.sectorId})');
      print('  Barangay: ${yield.barangay}');
      print('  Volume: ${yield.volume}');
      print('  Area (ha): ${yield.hectare}');
      print('  Status: ${yield.status}');
      print('  Created At: ${yield.createdAt}');
      print('  Farm ID: ${yield.farmId}');
      print('----------------------------------');
    }

    print('===== END OF YIELD DATA =====\n');
  }

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

  void _editAnnotation(int index) {
    annotationHandler.editAnnotation(context, index).then((_) {
      setState(() {});
    });
  }

  void _deleteAnnotation(int index) {
    setState(() {
      annotationHandler.deleteAnnotation(index);
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
            onTapDown: (details) => annotationHandler.handleChartTap(
              details,
              context,
              selectedFromYear,
              selectedToYear,
              filteredData,
            ),
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
                          annotations: annotationHandler.customAnnotations,
                          unit: selectedSector == 'Livestock' ? 'heads' : 'mt',
                        ),
                      ),
                    )
                  : SectorLineChartWidget(
                      key: _chartKey,
                      title: '',
                      dropdownItems: [],
                      datas: filteredData,
                      annotations: annotationHandler.customAnnotations,
                      unit: selectedSector == 'Livestock' ? 'heads' : 'mt',
                    ),
            ),
          ),
          if (annotationHandler.customAnnotations.isNotEmpty)
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
    if (selectedSector == 'All') {
      final Map<String, List<Map<String, dynamic>>> sectorGroupedData = {};
      final Map<String, Color> sectorColors = {};

      sectorData.forEach((sectorKey, sectorItems) {
        for (final item in sectorItems) {
          for (final point in item.data) {
            final year = point['x'];
            final value = point['y'].toDouble();

            final yearInt = int.parse(year);
            if (yearInt >= selectedFromYear && yearInt <= selectedToYear) {
              if (!sectorGroupedData.containsKey(sectorKey)) {
                sectorGroupedData[sectorKey] = [];
                sectorColors[sectorKey] = item.color;
              }

              final existingIndex = sectorGroupedData[sectorKey]!
                  .indexWhere((e) => e['x'] == year);

              if (existingIndex >= 0) {
                sectorGroupedData[sectorKey]![existingIndex]['y'] += value;
              } else {
                sectorGroupedData[sectorKey]!.add({
                  'x': year,
                  'y': value,
                });
              }
            }
          }
        }
      });

      return sectorGroupedData.entries
          .map((entry) {
            return SectorData(
              name: entry.key,
              color: sectorColors[entry.key] ?? Colors.grey,
              data: entry.value,
              annotations: null,
            );
          })
          .where((sector) => sector.data.isNotEmpty)
          .toList();
    } else {
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
        return ['All', 'Rice', 'Corn', 'Fishery', 'Livestock', 'Organic', 'HVC']
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
