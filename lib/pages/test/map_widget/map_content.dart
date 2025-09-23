import 'package:flareline/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_dragmarker/flutter_map_dragmarker.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flareline/services/lanugage_extension.dart';
import 'package:provider/provider.dart';
import 'map_layers.dart';
import 'polygon_manager.dart';

class MapContent extends StatelessWidget {
  final MapController mapController;
  final String selectedMap;
  final double zoomLevel;
  final BarangayManager barangayManager;
  final LakeManager lakeManager;
  final PolygonManager polygonManager;
  final ValueNotifier<LatLng?> previewPointNotifier;
  final Function setState;
  final List<String>? barangayFilter;
  final List<String> lakeFilter;
  final Map<String, bool> farmTypeFilters;
  final List<String> productFilters;
  final AnimatedMapController animatedMapController;
  final Function(List<String>)? onBarangayFilterChanged;
  final Function(List<String>)? onLakeFilterChanged;
  final bool showExceedingAreaOnly;

  const MapContent({
    Key? key,
    required this.mapController,
    required this.selectedMap,
    required this.zoomLevel,
    required this.polygonManager,
    required this.barangayManager,
    required this.lakeManager,
    required this.previewPointNotifier,
    required this.setState,
    this.barangayFilter,
    required this.lakeFilter,
    required this.farmTypeFilters,
    required this.productFilters,
    required this.animatedMapController,
    this.onBarangayFilterChanged,
    this.onLakeFilterChanged,
    required this.showExceedingAreaOnly,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.92,
      width: MediaQuery.of(context).size.width,
      child: ValueListenableBuilder<int>(
        valueListenable: polygonManager.editorUpdateNotifier,
        builder: (context, updateCount, child) {
          // Use the filtered polygons from the manager
          // final filteredPolygons =
          //     polygonManager.getFilteredPolygons(farmTypeFilters);

          // To this:
          final filteredPolygons = polygonManager.getFilteredPolygons(
            farmTypeFilters,
            showExceedingAreaOnly: showExceedingAreaOnly,
          );

          final filteredPinStyles =
              filteredPolygons.map((p) => p.pinStyle).toList();
          final filteredColors = filteredPolygons.map((p) => p.color).toList();

          // Get filtered barangays based on filter
          final filteredBarangays = polygonManager.selectedBarangays.isNotEmpty
              ? barangayManager.barangays
                  .where((barangay) =>
                      polygonManager.selectedBarangays.contains(barangay.name))
                  .toList()
              : barangayManager.barangays;

          // Get filtered lakes based on filter
          final filteredLakes = polygonManager.selectedLakes.isNotEmpty
              ? lakeManager.lakes
                  .where((lake) =>
                      polygonManager.selectedLakes.contains(lake.name))
                  .toList()
              : lakeManager.lakes;

          final userProvider =
              Provider.of<UserProvider>(context, listen: false);
          final _isFarmer = userProvider.isFarmer;

          return FlutterMap(
            mapController: mapController,
            options: _buildMapOptions(context),
            children: [
              // Base tile layer
              TileLayer(
                tileProvider: CancellableNetworkTileProvider(),
                urlTemplate: MapLayersHelper.availableLayers[selectedMap]!,
              ),

              // Lake polygons layer (only shown when explicitly filtered)
              if (polygonManager.selectedLakes.isNotEmpty)
                MapLayersHelper.createLakeLayer(lakeManager.lakes
                    .where((lake) =>
                        polygonManager.selectedLakes.contains(lake.name))
                    .toList()),

              // Lake center markers layer
              MapLayersHelper.createLakeCenterFallbackLayer(
                lakeManager.lakes,
                (lake) {
                  // Zoom to the lake
                  animatedMapController.animatedFitCamera(
                    cameraFit: CameraFit.coordinates(
                      coordinates: lake.vertices,
                      padding: const EdgeInsets.all(30),
                    ),
                    curve: Curves.easeInOut,
                  );

                  // Show lake info card
                  polygonManager.showLakenInfo(
                      context, lake, polygonManager.polygons);

                  // Apply filter for this lake
                  if (onLakeFilterChanged != null) {
                    setState(() {
                      if (polygonManager.selectedLakes.contains(lake.name)) {
                        onLakeFilterChanged!([]);
                      } else {
                        onLakeFilterChanged!([lake.name]);
                      }
                    });
                  }
                },
                circleColor: const Color.fromARGB(255, 59, 107, 145),
                iconColor: Colors.white,
                size: 30.0,
                filteredLakes: polygonManager.selectedLakes,
              ),

              // Polyline layer
              ValueListenableBuilder<LatLng?>(
                valueListenable: previewPointNotifier,
                builder: (context, previewPoint, child) {
                  return MapLayersHelper.createPolylineLayer(
                    filteredPolygons
                        .map((polygon) => polygon.vertices)
                        .toList(),
                    polygonManager.currentPolygon,
                    previewPoint,
                    polygonManager.isDrawing,
                  );
                },
              ),

              // Barangay polygons layer (only shown when explicitly filtered)
              if (polygonManager.selectedBarangays.isNotEmpty)
                MapLayersHelper.createBarangayLayer(barangayManager.barangays
                    .where((barangay) => polygonManager.selectedBarangays
                        .contains(barangay.name))
                    .toList()),

              MapLayersHelper.createBarangayCenterFallbackLayer(
                barangayManager.barangays,
                (barangay) {
                  // Zoom to the barangay
                  animatedMapController.animatedFitCamera(
                    cameraFit: CameraFit.coordinates(
                      coordinates: barangay.vertices,
                      padding: const EdgeInsets.all(30),
                    ),
                    curve: Curves.easeInOut,
                  );

                  // Show barangay info card
                  polygonManager.showBarangayInfo(
                      context, barangay, polygonManager.polygons);

                  // Apply filter for this barangay
                  if (onBarangayFilterChanged != null) {
                    setState(() {
                      if (polygonManager.selectedBarangays
                          .contains(barangay.name)) {
                        onBarangayFilterChanged!([]);
                      } else {
                        onBarangayFilterChanged!([barangay.name]);
                      }
                    });
                  }
                },
                circleColor: const Color.fromARGB(255, 74, 72, 72),
                iconColor: Colors.white,
                size: 30.0,
                filteredBarangays: polygonManager.selectedBarangays,
              ),

              // Polygon layer
              MapLayersHelper.createPolygonLayer(
                filteredPolygons.map((polygon) => polygon.vertices).toList(),
                polygonManager.currentPolygon,
                filteredColors,
                defaultColor: Colors.blue,
                selectedPolygonIndex:
                    polygonManager.selectedPolygonIndex != null
                        ? filteredPolygons.indexWhere((p) =>
                            polygonManager.polygons.indexOf(p) ==
                            polygonManager.selectedPolygonIndex)
                        : null,
              ),

              // Polygon markers layer
              MapLayersHelper.createMarkerLayer(
                filteredPolygons.map((polygon) => polygon.vertices).toList(),
                polygonManager.currentPolygon,
                polygonManager.selectedPolygonIndex != null
                    ? filteredPolygons.indexWhere((p) =>
                        polygonManager.polygons.indexOf(p) ==
                        polygonManager.selectedPolygonIndex)
                    : null,
                polygonManager.isEditing,
                (filteredIndex, vertexIndex) {
                  if (polygonManager.isEditing) {
                    setState(() {
                      final polygon = filteredPolygons[filteredIndex];
                      final originalIndex =
                          polygonManager.polygons.indexOf(polygon);
                      polygonManager.selectPolygon(originalIndex);
                      if (polygonManager.selectedPolygon != null) {
                        polygonManager.initializePolyEditor(
                            polygonManager.selectedPolygon!);
                      }
                    });
                  }
                },
                (i) {
                  if (i == 0 && polygonManager.currentPolygon.length > 2) {
                    setState(() {
                      polygonManager.completeCurrentPolygon(context);
                    });
                  }
                },
                filteredPinStyles,
                polygonManager,
                context,
                _isFarmer,
              ),

              // Drag markers for polygon editing - wrapped in ValueListenableBuilder
              if (polygonManager.isEditing &&
                  polygonManager.selectedPolygon != null)
                ValueListenableBuilder<int>(
                  valueListenable: polygonManager.editorUpdateNotifier,
                  builder: (context, updateCount, child) {
                    return DragMarkers(
                      markers: polygonManager.polyEditor?.edit() ?? [],
                    );
                  },
                ),

              // Drawing helper text
              ValueListenableBuilder<LatLng?>(
                valueListenable: previewPointNotifier,
                builder: (context, previewPoint, child) {
                  if (polygonManager.isDrawing &&
                      polygonManager.currentPolygon.length > 2) {
                    return IgnorePointer(
                      ignoring: true,
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            context.translate(
                                "Click the first point to close shape and save it"),
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          );
        },
      ),
    );
  }

  MapOptions _buildMapOptions(BuildContext context) {
    return MapOptions(
      center: LatLng(14.077557, 121.328938),
      zoom: zoomLevel,
      minZoom: 12,
      maxBounds: LatLngBounds(
        LatLng(13.877557, 121.128938), // South-West (widened)
        LatLng(14.277557, 121.528938), // North-East (widened)
      ),
      onTap: (_, LatLng point) {
        setState(() {
          if (polygonManager.isDrawing) {
            polygonManager.handleDrawingTap(point);
          } else if (polygonManager.isEditing) {
            polygonManager.handleSelectionTap(point, context);
          } else {
            polygonManager.handleSelectionTap(point, context);
          }
        });
      },
    );
  }
}
