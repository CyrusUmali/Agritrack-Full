// File: map_widget/map_layers.dart
// ignore_for_file: deprecated_member_use

import 'package:flareline/pages/test/map_widget/pin_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_dragmarker/flutter_map_dragmarker.dart';

/// Helper class for working with map layers
class MapLayersHelper {
  /// Creates a polygon layer from the given polygons and current polygon
  static PolygonLayer createPolygonLayer(
      List<List<LatLng>> polygons, // List of polygon vertices
      List<LatLng> currentPolygon, // Current polygon being drawn
      List<Color>? polygonColors, // Optional list of colors for each polygon
      {Color defaultColor =
          Colors.blue} // Default color if no color is provided
      ) {
    return PolygonLayer(
      polygons: [
        for (int i = 0; i < polygons.length; i++)
          Polygon(
            points: polygons[i],
            color: (polygonColors != null && i < polygonColors.length)
                ? polygonColors[i].withOpacity(0.2) // Use provided color
                : defaultColor.withOpacity(0.2), // Use default color
            borderStrokeWidth: 3,
            borderColor: (polygonColors != null && i < polygonColors.length)
                ? polygonColors[i] // Use provided color
                : defaultColor, // Use default color
            isFilled: true,
          ),
        if (currentPolygon.isNotEmpty)
          Polygon(
            points: currentPolygon,
            color: Colors.red.withOpacity(0.5), // Current polygon color
            borderStrokeWidth: 3,
            borderColor: Colors.red,
            isFilled: true,
          ),
      ],
    );
  }

  /// Creates a polyline layer from the given polygons, current polygon and preview point
  static PolylineLayer createPolylineLayer(List<List<LatLng>> polygons,
      List<LatLng> currentPolygon, LatLng? previewPoint, bool isDrawing) {
    return PolylineLayer(
      polylines: [
        for (var poly in polygons)
          Polyline(
            points: poly,
            color: Colors.blue,
            strokeWidth: 3,
            isDotted: true,
          ),
        if (isDrawing && currentPolygon.isNotEmpty && previewPoint != null)
          Polyline(
            points: [currentPolygon.last, previewPoint],
            color: Colors.red,
            strokeWidth: 2,
            isDotted: true,
          ),
      ],
    );
  }

  static MarkerLayer createMarkerLayer(
    List<List<LatLng>> polygons,
    List<LatLng> currentPolygon,
    int? selectedPolygonIndex,
    bool isEditing,
    Function(int, int) onMarkerTap,
    Function(int) onCurrentPolygonMarkerTap,
    List<PinStyle> pinStyles,
  ) {
    return MarkerLayer(
      markers: [
        // Polygon vertices (only shown if isEditing is true and the polygon is selected)
        if (selectedPolygonIndex != null)
          for (int j = 0; j < polygons[selectedPolygonIndex].length; j++)
            Marker(
              point: polygons[selectedPolygonIndex][j],
              width: 10.0,
              height: 10.0,
              child: GestureDetector(
                onTap: () {
                  onMarkerTap(selectedPolygonIndex, j);
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red, // Highlight selected polygon vertices
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ),

        // Current polygon vertices (always shown)
        for (int i = 0; i < currentPolygon.length; i++)
          Marker(
            point: currentPolygon[i],
            width: 30.0,
            height: 30.0,
            child: GestureDetector(
              onTap: () {
                onCurrentPolygonMarkerTap(i);
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == 0 ? Colors.red : Colors.green,
                  border: Border.all(color: Colors.black, width: 2),
                ),
              ),
            ),
          ),

        // Polygon center markers (always shown)
        for (int i = 0; i < polygons.length; i++)
          Marker(
            point: _calculateCenter(polygons[i]),
            width: 35.0,
            height: 35.0,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color.fromARGB(255, 0, 0, 0),
                border: Border.all(color: Colors.transparent, width: 3),
              ),
              child: getPinIcon(pinStyles[i]),
            ),
          ),
      ],
    );
  }

  /// Helper method to calculate the center of a polygon
  static LatLng _calculateCenter(List<LatLng> vertices) {
    if (vertices.isEmpty) return const LatLng(0, 0);

    double latSum = 0, lngSum = 0;
    for (var vertex in vertices) {
      latSum += vertex.latitude;
      lngSum += vertex.longitude;
    }
    return LatLng(latSum / vertices.length, lngSum / vertices.length);
  }

  /// Creates a drag marker layer for editing polygons
  static DragMarkers createDragMarkerLayer(
      List<List<LatLng>> polygons,
      int selectedPolygonIndex,
      Function(int) onVertexRemove,
      Function(int, LatLng) onVertexDrag,
      Function(int, LatLng) onMidpointDrag) {
    return DragMarkers(
      markers: [
        // Vertex markers
        for (int j = 0; j < polygons[selectedPolygonIndex].length; j++)
          DragMarker(
            point: polygons[selectedPolygonIndex][j],
            size: const Size(20, 20),
            builder: (context, point, isDragging) {
              return GestureDetector(
                onTap: () {
                  onVertexRemove(j);
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              );
            },
            onDragUpdate: (details, newPoint) {
              onVertexDrag(j, newPoint);
            },
          ),

        // Midpoint markers
        for (int j = 0; j < polygons[selectedPolygonIndex].length; j++)
          DragMarker(
            point: LatLng(
              (polygons[selectedPolygonIndex][j].latitude +
                      polygons[selectedPolygonIndex]
                              [(j + 1) % polygons[selectedPolygonIndex].length]
                          .latitude) /
                  2,
              (polygons[selectedPolygonIndex][j].longitude +
                      polygons[selectedPolygonIndex]
                              [(j + 1) % polygons[selectedPolygonIndex].length]
                          .longitude) /
                  2,
            ),
            size: const Size(20, 20),
            builder: (context, point, isDragging) {
              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange.withOpacity(0.5),
                  border: Border.all(color: Colors.white, width: 2),
                ),
              );
            },
            onDragUpdate: (details, newPoint) {
              onMidpointDrag(j, newPoint);
            },
          ),
      ],
    );
  }

  /// Available map layer templates
  static final Map<String, String> availableLayers = {
    "OSM": "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
    "Google Satellite": "https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}"
  };
}

// Example colors for polygons
List<Color> polygonColors = [
  Colors.green, // Color for the first polygon
  Colors.orange, // Color for the second polygon
  Colors.blue,
];
