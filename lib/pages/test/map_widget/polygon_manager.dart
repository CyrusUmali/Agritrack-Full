// ignore_for_file: avoid_print

import 'package:flareline/pages/test/map_widget/pin_style.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:developer'; // Import the developer library for logging
import 'package:flutter/foundation.dart'; // For ValueNotifier
import 'package:flutter/material.dart'; // For Colors
import 'package:turf/turf.dart' as turf;

class PolygonManager {
  final MapController mapController; // Add MapController as a member variable
  List<PolygonData> polygons = []; // Store PolygonData objects
  List<LatLng> currentPolygon = [];
  int? selectedPolygonIndex;
  PolygonData? selectedPolygon; // Use PolygonData instead of List<LatLng>
  bool isDrawing = false;
  bool isEditing = false;
  ValueNotifier<PolygonData?> selectedPolygonNotifier = ValueNotifier(null);

  // Undo and redo history
  List<PolygonHistoryEntry> undoHistory = [];
  List<PolygonHistoryEntry> redoHistory = [];

  // Constructor to accept MapController
  PolygonManager(this.mapController);

  /// Logs all polygon data to the console
  void logPolygons() {
    if (polygons.isEmpty) {
      print("No polygons available.");
      return;
    }

    print("===== Logging Polygon Data =====");
    for (int i = 0; i < polygons.length; i++) {
      final polygon = polygons[i];
      print("Polygon ${i + 1}: ${polygon.name}");
      print("  - Vertices:");
      for (int j = 0; j < polygon.vertices.length; j++) {
        final vertex = polygon.vertices[j];
        print(
            "    ${j + 1}: Lat: ${vertex.latitude}, Lng: ${vertex.longitude}");
      }
      print("  - Color: ${polygon.color}");
      print(
          "  - Center: Lat: ${polygon.center.latitude}, Lng: ${polygon.center.longitude}");
      if (polygon.description != null) {
        print("  - Description: ${polygon.description}");
      }
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

  void handleDrawingTap(LatLng point) {
    _saveState();
    if (selectedPolygonIndex != null) {
      polygons[selectedPolygonIndex!].vertices.add(point);
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
            name: 'Polygon ${polygons.length + 1}', // Default name
            color: Colors.blue, // Default color
          ));
          selectedPolygonIndex = polygons.length - 1;
          selectedPolygon = polygons[selectedPolygonIndex!];
          currentPolygon.clear();
        } else {
          currentPolygon.add(point);
        }
      } else {
        currentPolygon.add(point);
      }
    }
  }

  void handleSelectionTap(LatLng tapPoint) {
    _saveState();
    selectedPolygon = null;
    selectedPolygonIndex = null;

    log("Tap at: ${tapPoint.latitude}, ${tapPoint.longitude}");

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

      log("Checking polygon ${polygons[i].name}: ${polygonCoordinates}");

      // ✅ Fix: Pass tapTurfPoint.coordinates, not tapTurfPoint itself
      bool isInside = turf.booleanPointInPolygon(tapTurfPoint.coordinates,
          turf.Polygon(coordinates: [polygonCoordinates]));

      if (isInside) {
        log("Point is inside ${polygons[i].name}");
        selectedPolygon = polygons[i];
        selectedPolygonIndex = i;
        selectedPolygonNotifier.value = selectedPolygon;

        // Zoom and center the map on the selected polygon
        _zoomToPolygon(polygons[i]);
        break;
      }
    }

    if (selectedPolygon == null) {
      log("No polygon selected.");
    }
  }

  void _zoomToPolygon(PolygonData polygon) {
    if (polygon.vertices.isEmpty) return;

    // Calculate the bounding box of the polygon
    double minLat = polygon.vertices[0].latitude;
    double maxLat = polygon.vertices[0].latitude;
    double minLng = polygon.vertices[0].longitude;
    double maxLng = polygon.vertices[0].longitude;

    for (var point in polygon.vertices) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    // Calculate the center of the bounding box
    LatLng center = LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);

    // Calculate the zoom level based on the bounding box size
    double zoomLevel = _calculateZoomLevel(minLat, maxLat, minLng, maxLng);

    // Move the map to the calculated center and zoom level
    mapController.move(center, zoomLevel);
  }

  double _calculateZoomLevel(
      double minLat, double maxLat, double minLng, double maxLng) {
    // This is a simple calculation, you might need to adjust it based on your map's projection
    double latDiff = maxLat - minLat;
    double lngDiff = maxLng - minLng;
    double maxDiff = (latDiff > lngDiff) ? latDiff : lngDiff;

    if (maxDiff < 0.01) return 20.0;
    if (maxDiff < 0.05) return 14.0;
    if (maxDiff < 0.1) return 12.0;
    if (maxDiff < 0.5) return 10.0;
    if (maxDiff < 1.0) return 8.0;
    if (maxDiff < 5.0) return 6.0;
    if (maxDiff < 10.0) return 4.0;
    return 2.0;
  }

  /// Loads a list of polygons into the manager
  void loadPolygons(List<PolygonData> polygonsToLoad) {
    _saveState(); // Save the current state before loading new polygons
    polygons = List<PolygonData>.from(polygonsToLoad);
    selectedPolygonIndex = null;
    selectedPolygon = null;
    selectedPolygonNotifier.value = null;
  }

  void completeCurrentPolygon() {
    _saveState();
    if (currentPolygon.length > 2) {
      polygons.add(PolygonData(
        vertices: List.from(currentPolygon),
        name: 'Polygon ${polygons.length + 1}',
        color: Colors.blue,
      ));
      currentPolygon.clear();
      isDrawing = false;
    }
  }

  void selectPolygon(int index) {
    if (index >= 0 && index < polygons.length) {
      selectedPolygonIndex = index;
      selectedPolygon = polygons[index];
      selectedPolygonNotifier.value = selectedPolygon;
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
    }
  }

  void addMidpoint(int beforeIndex, LatLng newPoint) {
    _saveState();

    if (selectedPolygonIndex == null) return;

    PolygonData polygon = polygons[selectedPolygonIndex!];

    if (beforeIndex >= 0 && beforeIndex < polygon.vertices.length) {
      polygon.vertices.insert(beforeIndex + 1, newPoint);
    }
  }

  bool canUndo() {
    return undoHistory.isNotEmpty;
  }

  void undoLastPoint() {
    undo();
  }

  void _saveState() {
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
    redoHistory.clear();
  }

  /// Undo the last action
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

class PolygonData {
  List<LatLng> vertices;
  String name;
  LatLng center;
  Color color;
  String? description;
  PinStyle pinStyle; // Add PinStyle field

  PolygonData({
    required this.vertices,
    required this.name,
    LatLng? center,
    this.color = Colors.blue,
    this.description,
    this.pinStyle = PinStyle.fishery, // Default PinStyle
  }) : center = center ?? _calculateCenter(vertices);

  /// Calculates the geometric center of the polygon
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

  /// Converts the object to a map for storage
  Map<String, dynamic> toMap() {
    return {
      'vertices': vertices
          .map((point) => {'lat': point.latitude, 'lng': point.longitude})
          .toList(),
      'name': name,
      'center': {
        'lat': center.latitude,
        'lng': center.longitude
      }, // Store center
      'color': color.value,
      'description': description,
      'pinStyle':
          pinStyle.toString().split('.').last, // Store pinStyle as a string
    };
  }

  /// Creates an object from a map
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
      pinStyle: parsePinStyle(map['pinStyle']), // Use the utility function
    );
  }
}
