import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'dart:convert';

class MapChartWidget extends StatelessWidget {
  const MapChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return _maps(context);
  }

  Widget _maps(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Barangay Map',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.normal,
                ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: ChangeNotifierProvider(
                  create: (context) => _BarangayDataProvider(),
                  builder: (ctx, child) {
                    final provider = ctx.watch<_BarangayDataProvider>();

                    if (provider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (provider.data.isEmpty) {
                      return Center(
                        child: Text(
                          'No data available',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      );
                    }

                    final MapZoomPanBehavior zoomPanBehavior =
                        MapZoomPanBehavior(
                      enableDoubleTapZooming: true,
                      enableMouseWheelZooming: true,
                      enablePinching: true,
                      zoomLevel: 1,
                      minZoomLevel: 1,
                      maxZoomLevel: 15,
                      enablePanning: true,
                    );

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        // For smaller screens, stack vertically
                        if (constraints.maxWidth < 800) {
                          return Column(
                            children: [
                              Expanded(
                                flex: 3,
                                child: _buildMap(provider, zoomPanBehavior),
                              ),
                              const SizedBox(height: 16),
                              _buildBarangayList(provider, context),
                            ],
                          );
                        }
                        // For larger screens, use horizontal layout
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: _buildMap(provider, zoomPanBehavior),
                            ),
                            const SizedBox(width: 16),
                            _buildBarangayList(provider, context),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap(
      _BarangayDataProvider provider, MapZoomPanBehavior zoomPanBehavior) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SfMaps(
        layers: [
          MapShapeLayer(
            zoomPanBehavior: zoomPanBehavior,
            source: MapShapeSource.asset(
              'assets/barangay.json',
              shapeDataField: 'name',
              dataCount: provider.data.length,
              primaryValueMapper: (int index) => provider.data[index].name,
              dataLabelMapper: (int index) => provider.data[index].name,
              shapeColorValueMapper: (int index) => provider.data[index].color,
            ),
            showDataLabels: true,
            shapeTooltipBuilder: (BuildContext context, int index) {
              final barangay = provider.data[index];
              final colorLightness = barangay.color.computeLuminance();
              final textColor =
                  colorLightness > 0.5 ? Colors.black : Colors.white;

              return Container(
                width: 180, // Fixed width for consistency
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: barangay.color.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      barangay.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Add additional information here
                    Text(
                      'Population: 5,000', // Example data - replace with real data
                      style: TextStyle(
                        fontSize: 12,
                        color: textColor.withOpacity(0.9),
                      ),
                    ),
                    Text(
                      'Area: 2.5 km²', // Example data
                      style: TextStyle(
                        fontSize: 12,
                        color: textColor.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              );
            },
            tooltipSettings: const MapTooltipSettings(
              hideDelay: 0, // Hide immediately when mouse leaves
            ),
            strokeColor: Colors.white,
            strokeWidth: 0.8,
            dataLabelSettings: const MapDataLabelSettings(
              textStyle: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarangayList(
      _BarangayDataProvider provider, BuildContext context) {
    return Container(
      width: 200, // Fixed width for larger screens
      constraints: const BoxConstraints(maxWidth: 250), // Maximum width
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'Barangay List',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: provider.data.length,
                itemBuilder: (context, index) {
                  final barangay = provider.data[index];
                  return ListTile(
                    dense: true,
                    minLeadingWidth: 24,
                    leading: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: barangay.color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    title: Text(
                      barangay.name,
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      // Potential feature: Highlight/zoom to selected barangay
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BarangayModel {
  BarangayModel(this.name, this.color);

  final String name;
  final Color color;
}

class _BarangayDataProvider extends ChangeNotifier {
  List<BarangayModel> _data = [];
  bool _isLoading = true;

  List<BarangayModel> get data => _data;
  bool get isLoading => _isLoading;

  _BarangayDataProvider() {
    init();
  }

  Future<void> init() async {
    try {
      final barangayNames =
          await GeoJsonParser.getBarangayNamesFromAsset('assets/barangay.json');
      barangayNames.sort();

      _data = List.generate(
        barangayNames.length,
        (index) => BarangayModel(
          barangayNames[index],
          getColorForIndex(index, barangayNames.length),
        ),
      );
    } catch (e) {
      _data = [];
      debugPrint('Error loading barangay data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class GeoJsonParser {
  static Future<List<String>> getBarangayNamesFromAsset(
      String assetPath) async {
    final String data = await rootBundle.loadString(assetPath);
    final Map<String, dynamic> jsonResult = json.decode(data);

    List<String> barangayNames = [];

    if (jsonResult.containsKey('features')) {
      for (var feature in jsonResult['features']) {
        if (feature['properties'] != null &&
            feature['properties']['name'] != null) {
          barangayNames.add(feature['properties']['name'].toString());
        }
      }
    }

    return barangayNames;
  }
}

Color getColorForIndex(int index, int total) {
  final hue = (index * (360.0 / total)) % 360.0;
  return HSLColor.fromAHSL(1.0, hue, 0.7, 0.6).toColor();
}
