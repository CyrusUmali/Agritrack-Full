// ignore_for_file: avoid_print

import 'package:flareline/pages/test/map_widget/farm_list_panel/barangay_filter_panel.dart';
import 'package:flareline/pages/test/map_widget/map_panel/barangay_modal.dart';
import 'package:flareline/pages/test/map_widget/map_panel/brgy_prev.dart';
import 'package:flareline/pages/test/map_widget/map_panel/farm_creation/farm_creation_modal.dart';
import 'package:flareline/pages/test/map_widget/map_panel/farm_prev.dart';
import 'package:flareline/pages/test/map_widget/map_panel/polygon_modal.dart';
import 'package:flareline/pages/test/map_widget/pin_style.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_line_editor/flutter_map_line_editor.dart';
import 'package:latlong2/latlong.dart';
// Import the developer library for logging
import 'package:flutter/foundation.dart'; // For ValueNotifier
import 'package:flutter/material.dart'; // For Colors
import 'package:turf/turf.dart' as turf;
import 'package:flutter_map_animations/flutter_map_animations.dart'; // Add this import

class PolygonManager with RouteAware {
  // Add this field
  final AnimatedMapController mapController;
  List<PolygonData> polygons = [];
  List<LatLng> currentPolygon = [];

  int? selectedPolygonIndex;
  PolygonData? selectedPolygon;
  bool isDrawing = false;
  bool isEditing = false;
  ValueNotifier<PolygonData?> selectedPolygonNotifier = ValueNotifier(null);
  final Function()? onPolygonSelected;

  PolyEditor? polyEditor;

  List<PolygonHistoryEntry> undoHistory = [];
  List<PolygonHistoryEntry> redoHistory = [];

  final VoidCallback? onFiltersChanged;

  bool _isModalShowing = false;
  PolygonData? _lastShownPolygon;
  // Filter-related properties
  List<String> selectedBarangays = [];

  // New overlay controller
  OverlayEntry? _infoCardOverlay;

  PolygonManager({
    required this.mapController,
    this.onPolygonSelected,
    this.onFiltersChanged,
  });

  void didPush() {
    removeInfoCardOverlay();
  }

  void didPop() {
    removeInfoCardOverlay();
  }

  void showBarangayInfo(BuildContext context, PolygonData barangay,
      List<PolygonData> allPolygons) {
    removeInfoCardOverlay();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;

      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox == null || !renderBox.hasSize) return;

      final mapWidgetSize = renderBox.size;
      final mapWidgetPosition = renderBox.localToGlobal(Offset.zero);

      _infoCardOverlay = OverlayEntry(
        builder: (context) => Positioned(
          bottom: 20,
          left: mapWidgetPosition.dx,
          width: mapWidgetSize.width,
          child: Center(
            child: BarangayInfoCard(
              barangay: barangay,
              farmsInBarangay: allPolygons
                  .where((p) => p.parentBarangay == barangay.name)
                  .toList(),
              onTap: () {
                removeInfoCardOverlay();
                if (context.mounted) {
                  _showBarangayDetailsModal(
                      context,
                      barangay,
                      allPolygons
                          .where((p) => p.parentBarangay == barangay.name)
                          .toList());
                }
              },
            ),
          ),
        ),
      );

      if (context.mounted) {
        Overlay.of(context).insert(_infoCardOverlay!);
      }
    });
  }

  // Updated selectPolygon method
  void selectPolygon(int index, {BuildContext? context}) async {
    if (index >= 0 && index < polygons.length) {
      selectedPolygonIndex = index;
      selectedPolygon = polygons[index];
      selectedPolygonNotifier.value = selectedPolygon;

      // Start the zoom animation
      _zoomToPolygon(polygons[index]); // Make sure this is awaited
      onPolygonSelected?.call();

      if (context != null && context.mounted) {
        // Use a post-frame callback to ensure layout is complete
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            _showInfoCard(context, polygons[index]);
          }
        });
      }
    }
  }

  void _showInfoCard(BuildContext context, PolygonData polygon) {
    removeInfoCardOverlay();

    // Wait for the next frame to ensure layout is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;

      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox == null || !renderBox.hasSize) return;

      final mapWidgetSize = renderBox.size;
      final mapWidgetPosition = renderBox.localToGlobal(Offset.zero);

      _infoCardOverlay = OverlayEntry(
        builder: (context) => Positioned(
          left: mapWidgetPosition.dx,
          width: mapWidgetSize.width,
          bottom: 20,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Material(
              child: InfoCard(
                polygon: polygon,
                onTap: () {
                  removeInfoCardOverlay();
                  if (context.mounted) {
                    showPolygonModal(context, polygon);
                  }
                },
              ),
            ),
          ),
        ),
      );

      if (context.mounted) {
        Overlay.of(context).insert(_infoCardOverlay!);
      }
    });
  }

  void _showBarangayDetailsModal(
      BuildContext context, PolygonData barangay, List<PolygonData> farms) {
    BarangayModal.show(
      context: context,
      barangay: barangay,
      farms: farms,
      polygonManager: this,
    ).then((_) {
      // Modal closed callback
      _isModalShowing = false;
      _lastShownPolygon = null;
    });
  }

  // Method to remove the info card overlay
  void removeInfoCardOverlay() {
    if (_infoCardOverlay != null && _infoCardOverlay!.mounted) {
      _infoCardOverlay!.remove();
    }
    _infoCardOverlay = null;
  }

  void handleModalForSelectedPolygon(BuildContext context) {
    if (selectedPolygon != null &&
        selectedPolygon!.vertices.isNotEmpty &&
        !_isModalShowing &&
        _lastShownPolygon != selectedPolygon) {
      _lastShownPolygon = selectedPolygon;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          _showInfoCard(context, selectedPolygon!);
        }
      });
    }
  }

  // Existing showPolygonModal method remains unchanged
  Future<void> showPolygonModal(
      BuildContext context, PolygonData polygon) async {
    _isModalShowing = true;
    selectedPolygon = polygon;
    selectedPolygonNotifier.value = polygon;

    await PolygonModal.show(
      context: context,
      polygon: polygon,
      onUpdateCenter: (newCenter) {
        selectedPolygon?.center = newCenter;
        selectedPolygonNotifier.value = selectedPolygon;
      },
      onUpdatePinStyle: (newStyle) {
        selectedPolygon?.pinStyle = newStyle;
        selectedPolygonNotifier.value = selectedPolygon;
      },
      onUpdateColor: (color) {
        selectedPolygon?.color = color;
        selectedPolygonNotifier.value = selectedPolygon;
      },
      onSave: () {
        saveEditedPolygon();
      },
      selectedYear: DateTime.now().year.toString(),
      onYearChanged: (newYear) {
        // Store year in polygon data when implemented
        print('Year changed to: $newYear');
      },
    );

    _isModalShowing = false;
    _lastShownPolygon = polygon;
    selectedPolygon = null;
    selectedPolygonNotifier.value = null;
  }

  // Don't forget to clean up overlay when disposing
  void dispose() {
    removeInfoCardOverlay();
    selectedPolygonNotifier.dispose();
    // Other cleanup code...
  }

  void handleSelectionTap(LatLng tapPoint, BuildContext context) {
    // Add context parameter
    _saveState();
    selectedPolygon = null;
    selectedPolygonIndex = null;

    for (int i = 0; i < polygons.length; i++) {
      List<LatLng> polygonPoints = polygons[i].vertices;

      if (polygonPoints.length < 3) continue;

      // Convert to List<Position>
      List<turf.Position> polygonCoordinates = polygonPoints
          .map((p) => turf.Position(p.longitude, p.latitude))
          .toList();

      if (polygonCoordinates.first != polygonCoordinates.last) {
        polygonCoordinates.add(polygonCoordinates.first);
      }

      // Convert tapPoint to Turf Point correctly
      var tapTurfPoint = turf.Point(
          coordinates: turf.Position(tapPoint.longitude, tapPoint.latitude));

      bool isInside = turf.booleanPointInPolygon(tapTurfPoint.coordinates,
          turf.Polygon(coordinates: [polygonCoordinates]));

      if (isInside) {
        // Pass the context to selectPolygon
        selectPolygon(i, context: context);

        // Reinitialize the PolyEditor with the new polygon's vertices
        initializePolyEditor(selectedPolygon!);
        break;
      } else {
        removeInfoCardOverlay();
      }
    }

    if (selectedPolygon == null) {
      // Clear the PolyEditor when no polygon is selected
      polyEditor = null;
    }
  }

  void _zoomToPolygon(PolygonData polygon) {
    if (polygon.vertices.isEmpty) return;

    mapController.animatedFitCamera(
      cameraFit: CameraFit.coordinates(
        coordinates: polygon.vertices,
        padding: const EdgeInsets.all(30), // Decrease for tighter zoom
      ),
      curve: Curves.easeInOut,
    );
  }

  void handleDrawingTap(LatLng point) {
    if (selectedPolygonIndex != null) {
      polygons[selectedPolygonIndex!].vertices.add(point);
      _saveState(); // ✅ Already saving for existing polygons
    } else {
      if (currentPolygon.isNotEmpty) {
        final double distance = const Distance().as(
          LengthUnit.Meter,
          currentPolygon.first,
          point,
        );

        if (distance < 10) {
          currentPolygon.add(currentPolygon.first);
          polygons.add(PolygonData(
            vertices: List.from(currentPolygon),
            name: 'Polygon ${polygons.length + 1}',
            color: Colors.blue,
          ));
          selectedPolygonIndex = polygons.length - 1;
          selectedPolygon = polygons[selectedPolygonIndex!];
          currentPolygon.clear();
          _saveState(); // ✅ Save when finishing a new polygon
        } else {
          currentPolygon.add(point);
          _saveState(); // 🚀 NEW: Save after adding any intermediate point
        }
      } else {
        currentPolygon.add(point);
        _saveState(); // 🚀 NEW: Save after adding the first point
      }
    }
  }

  void clearFilters() {
    selectedBarangays.clear();
    BarangayFilterPanel.filterOptions.forEach((key, value) {
      BarangayFilterPanel.filterOptions[key] = true;
    });
    onFiltersChanged?.call();
  }

  /// Loads a list of polygons into the manager
  void loadPolygons(List<PolygonData> polygonsToLoad) {
    // _saveState();
    polygons = List<PolygonData>.from(polygonsToLoad);
    selectedPolygonIndex = null;
    selectedPolygon = null;
    selectedPolygonNotifier.value = null;
  }

  Future<void> completeCurrentPolygon(BuildContext context) async {
    _saveState();
    if (currentPolygon.length > 2) {
      // Create temporary polygon
      final tempPolygon = PolygonData(
        vertices: List.from(currentPolygon),
        name: 'New Farm ${polygons.length + 1}',
        color: Colors.blue,
      );

      // Show creation modal
      final shouldSave = await FarmCreationModal.show(
        context: context,
        polygon: tempPolygon,
        onNameChanged: (name) => tempPolygon.name = name,
      );

      if (shouldSave) {
        polygons.add(tempPolygon);
        currentPolygon.clear();
        isDrawing = false;
        clearFilters();
        selectedPolygonNotifier.value = tempPolygon;
      } else {
        // Reset drawing state completely
        currentPolygon.clear();
        isDrawing = false;
        isEditing = false;
        selectedPolygon = null;
        selectedPolygonIndex = null;
        polyEditor = null;

        // Notify listeners
        selectedPolygonNotifier.value = null;

        // Trigger state refresh using existing callback
        if (onFiltersChanged != null) {
          onFiltersChanged!();
        }
      }
    }
  }

  void initializePolyEditor(PolygonData polygon) {
    polyEditor = PolyEditor(
      points: polygon.vertices,
      pointIcon: Container(
        width: 40, // Adjust the size of the container
        height: 40, // Adjust the size of the container
        decoration: BoxDecoration(
          shape: BoxShape.circle, // Make the container circular
          color: Colors.orange, // Fill color of the circle
          border: Border.all(
            color: Colors.white, // Border color
            width: 2.0, // Border width
          ),
        ),
      ),
      intermediateIcon: Icon(
        Icons.lens,
        size: 25,
        color: Colors.grey,
      ),
      callbackRefresh: () {
        // Refresh the state or update the map
        selectedPolygonNotifier.value = selectedPolygon;
      },
      addClosePathMarker: true, // Set to true for polygons
    );
  }

  void saveEditedPolygon() {
    if (selectedPolygonIndex != null && selectedPolygon != null) {
      polygons[selectedPolygonIndex!] = PolygonData(
        vertices: List<LatLng>.from(selectedPolygon!.vertices),
        name: selectedPolygon!.name,
        color: selectedPolygon!.color,
        description: selectedPolygon!.description,
        pinStyle: selectedPolygon!.pinStyle,
      );
      selectedPolygonNotifier.value = selectedPolygon;
    } else {
      print('Cannot save polygon: No polygon is selected.');
    }
  }

  /// Logs all polygon data to the console
  void logPolygons() {
    if (polygons.isEmpty) {
      // print("No polygons available.");
      return;
    }

    // print("===== Logging Polygon Data =====");
    for (int i = 0; i < polygons.length; i++) {
      final polygon = polygons[i];
      print("Polygon ${i + 1}: ${polygon.name}");

      print("  - Color: ${polygon.color}");
      print(
          "  - Center: Lat: ${polygon.center.latitude}, Lng: ${polygon.center.longitude}");

      print("  - Description: ${polygon.description}");

      if (polygon.pinStyle != null) {
        print("  - Icon: ${polygon.pinStyle}");
      }
      print("-----------------------------");
    }
    print("===== End of Polygon Data =====");
  }

  void toggleDrawing() {
    _saveState();
    isDrawing = !isDrawing;

    if (!isDrawing) {
      currentPolygon.clear();
      if (selectedPolygon == null) {
        polyEditor = null; // Clear the PolyEditor when no polygon is selected
      }
    }

    if (isDrawing) {
      isEditing = false;
      currentPolygon.clear();
      selectedPolygon = null;
      selectedPolygonIndex = null;
    }
  }

  void toggleEditing() {
    _saveState();
    if (isDrawing) {
      currentPolygon.clear();
    }
    isEditing = !isEditing;

    if (isEditing) {
      isDrawing = false;
      selectedPolygonIndex = null;
    }
  }

  void removeVertex(int vertexIndex) {
    _saveState();

    if (selectedPolygonIndex == null) return;

    PolygonData polygon = polygons[selectedPolygonIndex!];

    if (vertexIndex >= 0 && vertexIndex < polygon.vertices.length) {
      polygon.vertices.removeAt(vertexIndex);

      if (polygon.vertices.length < 3) {
        // If less than 3 vertices remain, remove the polygon
        polygons.removeAt(selectedPolygonIndex!);
        selectedPolygonIndex = null;
        selectedPolygon = null;
      } else {
        selectedPolygon = polygon;
      }
    }
  }

  void updateVertex(int vertexIndex, LatLng newPoint) {
    _saveState();

    if (selectedPolygonIndex == null) return;

    PolygonData polygon = polygons[selectedPolygonIndex!];

    if (vertexIndex >= 0 && vertexIndex < polygon.vertices.length) {
      polygon.vertices[vertexIndex] = newPoint;
      initializePolyEditor(
          polygon); // Reinitialize the editor with updated points
    }
  }

  void addMidpoint(int beforeIndex, LatLng newPoint) {
    _saveState();

    if (selectedPolygonIndex == null) return;

    PolygonData polygon = polygons[selectedPolygonIndex!];

    if (beforeIndex >= 0 && beforeIndex < polygon.vertices.length) {
      polygon.vertices.insert(beforeIndex + 1, newPoint);
      initializePolyEditor(
          polygon); // Reinitialize the editor with updated points
    }
  }

  bool canUndo() {
    return undoHistory.isNotEmpty;
  }

  void undoLastPoint() {
    undo();
  }

  void _saveState() {
    if (undoHistory.isNotEmpty && redoHistory.isNotEmpty) {
      redoHistory.clear();
    }

    final newState = PolygonHistoryEntry(
      List<PolygonData>.from(polygons.map((polygon) => PolygonData(
            vertices: List<LatLng>.from(polygon.vertices),
            name: polygon.name,
            color: polygon.color,
            description: polygon.description,
            pinStyle: polygon.pinStyle,
          ))),
      List<LatLng>.from(currentPolygon),
      selectedPolygonIndex,
    );
    undoHistory.add(newState);
  }

  void undo() {
    if (undoHistory.isNotEmpty) {
      final lastState = undoHistory.removeLast();
      redoHistory.add(PolygonHistoryEntry(
        List<PolygonData>.from(polygons.map((polygon) => PolygonData(
              vertices: List<LatLng>.from(polygon.vertices),
              name: polygon.name,
              color: polygon.color,
              description: polygon.description,
              pinStyle: polygon.pinStyle,
            ))),
        List<LatLng>.from(currentPolygon),
        selectedPolygonIndex,
      ));
      polygons = lastState.polygons;
      currentPolygon = lastState.currentPolygon;
      selectedPolygonIndex = lastState.selectedPolygonIndex;
      selectedPolygon =
          selectedPolygonIndex != null ? polygons[selectedPolygonIndex!] : null;
      selectedPolygonNotifier.value = selectedPolygon;
    }
  }

  void redo() {
    if (redoHistory.isNotEmpty) {
      final nextState = redoHistory.removeLast();
      undoHistory.add(PolygonHistoryEntry(
        List<PolygonData>.from(polygons.map((polygon) => PolygonData(
              vertices: List<LatLng>.from(polygon.vertices),
              name: polygon.name,
              color: polygon.color,
              description: polygon.description,
              pinStyle: polygon.pinStyle,
            ))),
        List<LatLng>.from(currentPolygon),
        selectedPolygonIndex,
      ));
      polygons = nextState.polygons;
      currentPolygon = nextState.currentPolygon;
      selectedPolygonIndex = nextState.selectedPolygonIndex;
      selectedPolygon =
          selectedPolygonIndex != null ? polygons[selectedPolygonIndex!] : null;
      selectedPolygonNotifier.value = selectedPolygon;
    }
  }
}

class PolygonHistoryEntry {
  final List<PolygonData> polygons;
  final List<LatLng> currentPolygon;
  final int? selectedPolygonIndex;

  PolygonHistoryEntry(
      this.polygons, this.currentPolygon, this.selectedPolygonIndex);
}

enum PolygonType { farm, barangay }

class PolygonData {
  List<LatLng> vertices;
  String name;
  LatLng center;
  Color color;
  String? description;
  PinStyle pinStyle;
  PolygonType type;
  String? barangay; // Add barangay reference
  String? parentBarangay; // For farms, reference which barangay they belong to

  PolygonData({
    required this.vertices,
    required this.name,
    LatLng? center,
    this.color = Colors.blue,
    this.description,
    this.pinStyle = PinStyle.fishery,
    this.type = PolygonType.farm,
    this.barangay, // For barangay polygons
    this.parentBarangay, // For farm polygons
  }) : center = center ?? _calculateCenter(vertices);

  Map<String, dynamic> toMap() {
    return {
      'vertices': vertices
          .map((point) => {'lat': point.latitude, 'lng': point.longitude})
          .toList(),
      'name': name,
      'center': {'lat': center.latitude, 'lng': center.longitude},
      'color': color.value,
      'description': description,
      'pinStyle': pinStyle.toString().split('.').last,
      'type': type.toString().split('.').last,
      'barangay': barangay,
      'parentBarangay': parentBarangay,
    };
  }

  /// Update fromMap() to include barangay/parentBarangay
  factory PolygonData.fromMap(Map<String, dynamic> map) {
    return PolygonData(
      vertices: (map['vertices'] as List)
          .map((point) => LatLng(point['lat'], point['lng']))
          .toList(),
      name: map['name'],
      center: map.containsKey('center')
          ? LatLng(map['center']['lat'], map['center']['lng'])
          : _calculateCenter((map['vertices'] as List)
              .map((point) => LatLng(point['lat'], point['lng']))
              .toList()),
      color: Color(map['color']),
      description: map['description'],
      pinStyle: parsePinStyle(map['pinStyle']),
      type: map['type'] == 'barangay' ? PolygonType.barangay : PolygonType.farm,
      barangay: map['barangay'],
      parentBarangay: map['parentBarangay'],
    );
  }

  PolygonData copyWith() {
    return PolygonData(
      name: name,
      center: LatLng(center.latitude, center.longitude),
      vertices: List.from(vertices),
      color: color,
      pinStyle: pinStyle,
      description: description,
      parentBarangay: parentBarangay,
      // Copy all other properties
    );
  }

  void updateFrom(PolygonData other) {
    name = other.name;
    center = other.center;
    vertices = List.from(other.vertices);
    color = other.color;
    pinStyle = other.pinStyle;
    description = other.description;
    parentBarangay = other.parentBarangay;
    // Update all other properties that should be copied
  }

  static LatLng _calculateCenter(List<LatLng> vertices) {
    if (vertices.isEmpty) return const LatLng(0, 0);

    double latSum = 0, lngSum = 0;
    for (var vertex in vertices) {
      latSum += vertex.latitude;
      lngSum += vertex.longitude;
    }
    return LatLng(latSum / vertices.length, lngSum / vertices.length);
  }

  /// Updates the center manually
  void updateCenter(LatLng newCenter) {
    center = newCenter;
  }
}

class BarangayManager {
  List<PolygonData> barangays = [];

  void loadBarangays(List<Map<String, dynamic>> barangayMaps) {
    barangays = barangayMaps.map((map) {
      final polygon = PolygonData.fromMap(map);
      polygon.type = PolygonType.barangay;
      return polygon;
    }).toList();
  }
}
