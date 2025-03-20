import 'dart:math';
import 'package:flareline/pages/test/map_widget/pin_style.dart';
import 'package:flareline/pages/test/map_widget/stored_polygons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';

import 'map_controls.dart';
import 'map_layers.dart';
import 'PolygonInfoPanel.dart';
import 'polygon_manager.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  String selectedMap = "OSM";
  double zoomLevel = 15.0;
  LatLng? previewPoint;
  PinStyle selectedPinStyle = PinStyle.rice; // Add PinStyle state variable

  final MapController mapController = MapController();
  late PolygonManager polygonManager;

  @override
  void initState() {
    super.initState();
    polygonManager = PolygonManager(mapController);
    // Load stored polygons
    List<PolygonData> polygonsToLoad =
        storedPolygons.map((map) => PolygonData.fromMap(map)).toList();
    polygonManager.loadPolygons(polygonsToLoad);
  }

  @override
  void dispose() {
    mapController.dispose(); // Dispose of the MapController
    previewPointNotifier.dispose(); // Dispose the ValueNotifier
    super.dispose();
  }

  final ValueNotifier<LatLng?> previewPointNotifier = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    print("Building MapWidget"); // Debugging statement

    return Stack(
      children: <Widget>[
        MouseRegion(
          onHover: (event) {
            if (polygonManager.isDrawing) {
              final RenderBox renderBox =
                  context.findRenderObject() as RenderBox;
              final Offset localPosition =
                  renderBox.globalToLocal(event.position);

              final Point<double> localPoint =
                  Point(localPosition.dx, localPosition.dy);
              final LatLng newPoint =
                  mapController.camera.pointToLatLng(localPoint);

              previewPointNotifier.value = newPoint; // Update the ValueNotifier
            }
          },
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.88,
            width: MediaQuery.of(context).size.width,
            child: FlutterMap(
              mapController: mapController,
              options: _buildMapOptions(),
              children: [
                // Base tile layer
                TileLayer(
                  tileProvider: CancellableNetworkTileProvider(),
                  urlTemplate: MapLayersHelper.availableLayers[selectedMap]!,
                  // subdomains: ['a', 'b', 'c'],
                ),

                // Use ValueListenableBuilder for the polyline layer
                ValueListenableBuilder<LatLng?>(
                  valueListenable: previewPointNotifier,
                  builder: (context, previewPoint, child) {
                    return MapLayersHelper.createPolylineLayer(
                      polygonManager.polygons
                          .map((polygon) => polygon.vertices)
                          .toList(), // Extract vertices from PolygonData
                      polygonManager.currentPolygon,
                      previewPoint,
                      polygonManager.isDrawing,
                    );
                  },
                ),

                // Use the helper methods from MapLayersHelper
                MapLayersHelper.createMarkerLayer(
                  polygonManager.polygons
                      .map((polygon) => polygon.vertices)
                      .toList(), // Extract vertices from PolygonData
                  polygonManager.currentPolygon,
                  polygonManager.selectedPolygonIndex,
                  polygonManager.isEditing,
                  (i, j) {
                    if (polygonManager.isEditing) {
                      setState(() {
                        polygonManager.selectPolygon(i);
                      });
                    }
                  },
                  (i) {
                    if (i == 0 && polygonManager.currentPolygon.length > 2) {
                      setState(() {
                        polygonManager.completeCurrentPolygon();
                      });
                    }
                  },
                  polygonManager.polygons
                      .map((polygon) => polygon
                          .pinStyle) // Extract PinStyles from PolygonData
                      .toList(), // Pass the list of PinStyles
                ),

                if (polygonManager.isEditing &&
                    polygonManager.selectedPolygonIndex != null)
                  MapLayersHelper.createDragMarkerLayer(
                    polygonManager.polygons
                        .map((polygon) => polygon.vertices)
                        .toList(), // Extract vertices from PolygonData
                    polygonManager.selectedPolygonIndex!,
                    (j) {
                      setState(() {
                        polygonManager.removeVertex(j);
                      });
                    },
                    (j, newPoint) {
                      setState(() {
                        polygonManager.updateVertex(j, newPoint);
                      });
                    },
                    (j, newPoint) {
                      setState(() {
                        polygonManager.addMidpoint(j, newPoint);
                      });
                    },
                  ),

                MapLayersHelper.createPolygonLayer(
                  polygonManager.polygons
                      .map((polygon) => polygon.vertices)
                      .toList(), // Extract vertices from PolygonData
                  polygonManager.currentPolygon,
                  polygonManager.polygons
                      .map((polygon) =>
                          polygon.color) // Extract colors from PolygonData
                      .toList(), // Pass the list of colors
                  defaultColor: Colors.blue, // Optional: Set a default color
                ),

                // Drawing helper text
                ValueListenableBuilder<LatLng?>(
                  valueListenable: previewPointNotifier,
                  builder: (context, previewPoint, child) {
                    if (polygonManager.isDrawing &&
                        polygonManager.currentPolygon.length > 2) {
                      return Positioned(
                        left: MediaQuery.of(context).size.width / 2 - 150,
                        top: MediaQuery.of(context).size.height / 2 - 50,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "Click the first point to close shape and save it",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      );
                    }
                    return const SizedBox
                        .shrink(); // Return an empty widget if the condition fails
                  },
                ),
              ],
            ),
          ),
        ),

        // Map controls
        Positioned(
          top: 10,
          right: 10,
          child: MapControls(
            zoomLevel: zoomLevel,
            isDrawing: polygonManager.isDrawing,
            isEditing: polygonManager.isEditing,
            mapLayers: MapLayersHelper.availableLayers,
            selectedMap: selectedMap,
            selectedPolygonIndex: polygonManager.selectedPolygonIndex,
            onZoomIn: () {
              print('Zoom In button pressed'); // Debugging statement
              setState(() {
                zoomLevel++;
                mapController.move(mapController.center, zoomLevel);
                polygonManager.logPolygons();
              });
            },
            onZoomOut: () {
              setState(() {
                zoomLevel--;
                mapController.move(mapController.center, zoomLevel);
              });
            },
            onToggleDrawing: () {
              setState(() {
                polygonManager.toggleDrawing();
                polygonManager.selectedPolygon = null;
              });
            },
            onToggleEditing: () {
              setState(() {
                polygonManager.toggleEditing();
                if (!polygonManager.isEditing) {
                  // Clear the selected polygon when exiting editing mode
                  polygonManager.selectedPolygon = null;
                }
              });
            },
            onMapLayerChange: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  selectedMap = newValue;
                });
              }
            },
            onUndo: () {
              print('undo button pressed ');
              if (polygonManager.canUndo()) {
                setState(() {
                  polygonManager.undoLastPoint();
                });
              }
            },
          ),
        ),

        if (polygonManager.selectedPolygon != null &&
            polygonManager.selectedPolygon!.vertices.isNotEmpty)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                child: PolygonInfoPanel(
                  polygon: polygonManager.selectedPolygon!,
                  onUpdateCenter: (LatLng newCenter) {
                    // Handle center update
                    polygonManager.selectedPolygon!.updateCenter(newCenter);
                  },
                  onUpdatePinStyle: (PinStyle newStyle) {
                    setState(() {
                      // selectedPinStyle = newStyle;
                      polygonManager.selectedPolygon!.pinStyle = newStyle;
                    });
                  },
                  onUpdateColor: (Color newColor) {
                    setState(() {
                      polygonManager.selectedPolygon!.color = newColor;
                    });
                  },
                  onSave: () {
                    // Handle save action
                    polygonManager
                        .saveEditedPolygon(); // Save the polygon changes
                    setState(() {}); // Refresh the UI
                  },
                )),
          ),

        // Save button (visible only in editing mode)
        if (polygonManager.selectedPolygonIndex != null &&
            polygonManager.isEditing)
          Positioned(
            bottom: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  polygonManager.saveEditedPolygon();
                  polygonManager
                      .toggleEditing(); // Exit editing mode after saving

                  polygonManager.selectedPolygon = null;
                  polygonManager.selectedPolygonIndex = null;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Button color
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                'Save',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
      ],
    );
  }

  MapOptions _buildMapOptions() {
    return MapOptions(
        center: LatLng(14.077557, 121.328938),
        zoom: zoomLevel,
        minZoom: 13,
        maxBounds: LatLngBounds(
          LatLng(14.027557, 121.278938),
          LatLng(14.127557, 121.378938),
        ),
        onTap: (_, LatLng point) {
          setState(() {
            if (polygonManager.isDrawing) {
              polygonManager.handleDrawingTap(point);
            } else {
              polygonManager.handleSelectionTap(point);
            }
          });
        });
  }
}
