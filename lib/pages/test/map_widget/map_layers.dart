// File: map_widget/map_layers.dart
// ignore_for_file: deprecated_member_use
import 'polygon_manager.dart';
import 'package:flareline/pages/test/map_widget/pin_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_dragmarker/flutter_map_dragmarker.dart';

/// Helper class for working with map layers
class MapLayersHelper {
  // Define maximum area limits for each pin style in HECTARES
  static final Map<PinStyle, double> maxAreaLimitsHectares = {
    PinStyle.Fishery: 5,
    PinStyle.Rice: 5,
    PinStyle.HVC: 5,
    PinStyle.Organic: 5,
    PinStyle.Corn: 5,
    PinStyle.Livestock: 5,
  };

  static PolygonLayer createBarangayLayer(List<PolygonData> barangays) {
    return PolygonLayer(
      polygons: barangays
          .map((barangay) => Polygon(
                points: barangay.vertices,
                color: const Color.fromARGB(255, 255, 255, 0).withOpacity(0.1),
                borderStrokeWidth: 1,
                borderColor: const Color.fromARGB(255, 223, 212, 1),
                isFilled: true,
              ))
          .toList(),
    );
  }

  static PolygonLayer createLakeLayer(List<PolygonData> lakes) {
    return PolygonLayer(
      polygons: lakes
          .map((lake) => Polygon(
                points: lake.vertices,
                color: const Color.fromARGB(255, 255, 255, 0).withOpacity(0.1),
                borderStrokeWidth: 1,
                borderColor: const Color.fromARGB(255, 223, 212, 1),
                isFilled: true,
              ))
          .toList(),
    );
  }

  static PolygonLayer createPolygonLayer(
      List<List<LatLng>> polygons, // List of polygon vertices
      List<LatLng> currentPolygon, // Current polygon being drawn
      List<Color>? polygonColors, // Optional list of colors for each polygon
      {Color defaultColor =
          Colors.blue, // Default color if no color is provided
      int? selectedPolygonIndex} // Index of the selected polygon
      ) {
    return PolygonLayer(
      polygons: [
        for (int i = 0; i < polygons.length; i++)
          Polygon(
            points: polygons[i],
            color: (i == selectedPolygonIndex)
                ? Colors.red.withOpacity(0.3) // Highlight selected polygon
                : (polygonColors != null && i < polygonColors.length)
                    ? polygonColors[i].withOpacity(0.2)
                    : defaultColor.withOpacity(0.2),
            borderStrokeWidth: 3,
            borderColor: (i == selectedPolygonIndex)
                ? Colors.red // Highlight border of selected polygon
                : (polygonColors != null && i < polygonColors.length)
                    ? polygonColors[i]
                    : defaultColor,
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

  /// Creates a layer with interactive circles for barangay centers that will
  /// render even if the polygon itself is not shown
  static MarkerLayer createBarangayCenterFallbackLayer(
    List<PolygonData> barangays,
    Function(PolygonData) onTap, {
    Color circleColor = Colors.blue,
    Color iconColor = Colors.white,
    double size = 36.0,
    List<String>? filteredBarangays,
  }) {
    return MarkerLayer(
      markers: barangays.map((barangay) {
        final isFiltered = filteredBarangays != null &&
            filteredBarangays.contains(barangay.name);
        return Marker(
          point: MapLayersHelper.calculateCenter(barangay.vertices),
          width: size,
          height: size,
          child: GestureDetector(
            onTap: () => onTap(barangay),
            child: Container(
              decoration: BoxDecoration(
                color: isFiltered ? Colors.green : circleColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_balance, // Government building icon
                      color: isFiltered ? Colors.white : iconColor,
                      size: size * 0.5,
                    ),
                    Text(
                      'Brgy',
                      style: TextStyle(
                        color: isFiltered ? Colors.white : iconColor,
                        fontSize: size * 0.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Creates a layer with interactive circles for barangay centers that will
  /// render even if the polygon itself is not shown
  static MarkerLayer createLakeCenterFallbackLayer(
    List<PolygonData> lakes,
    Function(PolygonData) onTap, {
    Color circleColor = Colors.blue,
    Color iconColor = Colors.white,
    double size = 36.0,
    List<String>? filteredLakes,
  }) {
    return MarkerLayer(
      markers: lakes.map((lake) {
        final isFiltered =
            filteredLakes != null && filteredLakes.contains(lake.name);
        return Marker(
          point: MapLayersHelper.calculateCenter(lake.vertices),
          width: size,
          height: size,
          child: GestureDetector(
            onTap: () => onTap(lake),
            child: Container(
              decoration: BoxDecoration(
                color: isFiltered ? Colors.green : circleColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.water_drop_outlined, // Water/lake icon
                      color: isFiltered ? Colors.white : iconColor,
                      size: size * 0.5,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
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
    PolygonManager polygonManager,
    BuildContext context,
    bool isFarmer,
  ) {
    return MarkerLayer(
      markers: [
        // Current polygon vertices (always shown)
        for (int i = 0; i < currentPolygon.length; i++)
          Marker(
            point: currentPolygon[i],
            width: 36.0,
            height: 36.0,
            child: GestureDetector(
              onTap: () {
                onCurrentPolygonMarkerTap(i);
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == 0 ? Colors.red : Colors.green,
                  border: Border.all(color: Colors.white, width: 2.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Polygon center markers (always shown)
        for (int i = 0; i < polygons.length; i++)
          Marker(
            point: calculateCenter(polygons[i]),
            width: 30.0,
            height: 30.0,
            child: GestureDetector(
              // onTap: () => polygonManager.selectPolygon(i, context: context),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: getPinColor(pinStyles[i]).withOpacity(
                      polygonManager.selectedPolygonIndex == i ? 0.8 : 0.6),
                  border: Border.all(
                    color: Colors.white,
                    width: polygonManager.selectedPolygonIndex == i ? 3.0 : 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: _getExceedanceIcon(polygonManager.polygons[i],
                      pinStyles[i], isFarmer), // Pass the isFarmer flag
                ),
              ),
            ),
          ),
      ],
    );
  }

  static Widget _getExceedanceIcon(
      PolygonData polygon, PinStyle pinStyle, bool isFarmer) {
    // If user is a farmer, don't show the warning icon

    final maxArea = maxAreaLimitsHectares[pinStyle] ?? double.infinity;
    final exceedsLimit = polygon.area != null && polygon.area! > maxArea;

    if (exceedsLimit) {
      // print(maxAreaLimitsHectares);

      // print('wqqew');

      // print(maxArea);
      // print(polygon.name);
      // print(polygon.area);
      // Option 1: Animated pulsing warning badge (recommended)
      return Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          getPinIcon(pinStyle),
          Positioned(
            top: -8,
            right: -8,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.4),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      // Return normal pin icon
      return getPinIcon(pinStyle);
    }
  }

  /// Helper method to calculate the center of a polygon
  static LatLng calculateCenter(List<LatLng> vertices) {
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
    // OpenStreetMap & variants (public domain)
    "OSM": "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",

    // Satellite/Terrain
    "Google Satellite": "https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}",

    "Google Satellite (No Labels)":
        "https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}",

    // ESRI maps
    "ESRI World Imagery":
        "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}",

    // Wikimedia (free tiles)
    "Wikimedia": "https://maps.wikimedia.org/osm-intl/{z}/{x}/{y}.png",

    // CartoDB (free with attribution)
    "CartoDB Light":
        "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png",

    "OpenTopoMap": "https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png",
    "CyclOSM":
        "https://{s}.tile-cyclosm.openstreetmap.fr/cyclosm/{z}/{x}/{y}.png",
    "Humanitarian": "https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png",
  };
}
