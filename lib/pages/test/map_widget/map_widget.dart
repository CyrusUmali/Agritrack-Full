import 'dart:math';
import 'package:flareline/pages/test/map_widget/farm_list_panel/barangay_filter_panel.dart';
import 'package:flareline/pages/test/map_widget/map_panel/polygon_modal_components/farm_info_card.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';

import 'farm_list_panel/farm_list.dart';
import 'stored_polygons.dart';
import 'map_controls.dart';
import 'map_layers.dart';
import 'polygon_manager.dart';
import 'map_content.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> with TickerProviderStateMixin {
  PolygonData?
      _selectedPolygonForModal; // Track which polygon is being shown in modal

  String selectedMap = "Google Satellite";
  bool _showFarmListPanel = false;
  double zoomLevel = 15.0;
  LatLng? previewPoint;

  late final AnimatedMapController _animatedMapController;
  late PolygonManager polygonManager;
  late BarangayManager barangayManager;
  final ValueNotifier<LatLng?> previewPointNotifier = ValueNotifier(null);

  late final RenderBox _renderBox;
  LatLng? _lastPoint;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _renderBox = context.findRenderObject() as RenderBox;
    });
    FarmInfoCard.loadBarangays();
    barangayManager = BarangayManager();
    _animatedMapController = AnimatedMapController(vsync: this);
    polygonManager = PolygonManager(
        mapController: _animatedMapController,
        onPolygonSelected: _hideFarmListPanel,
        onFiltersChanged: () => setState(() {}));

    List<PolygonData> polygonsToLoad =
        storedPolygons.map((map) => PolygonData.fromMap(map)).toList();
    polygonManager.loadPolygons(polygonsToLoad);

    barangayManager = BarangayManager();
    barangayManager.loadBarangays(barangays);
  }

  void _hideFarmListPanel() {
    setState(() {
      _showFarmListPanel = false;
    });
  }

  @override
  void dispose() {
    _animatedMapController.dispose();
    previewPointNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Listener(
          onPointerMove: (event) {
            // Only process if in drawing mode
            if (!polygonManager.isDrawing) return;

            try {
              // Get the render box if not already available
              final renderBox =
                  _renderBox ?? context.findRenderObject() as RenderBox?;
              if (renderBox == null) return;

              // Convert global position to local coordinates
              final localPosition = renderBox.globalToLocal(event.position);
              final newPoint = _animatedMapController.mapController.camera
                  .pointToLatLng(Point(localPosition.dx, localPosition.dy));

              // Update only if point changed significantly (optimization)
              if (_lastPoint == null ||
                  (newPoint.latitude - _lastPoint!.latitude).abs() > 0.0001 ||
                  (newPoint.longitude - _lastPoint!.longitude).abs() > 0.0001) {
                _lastPoint = newPoint;
                previewPointNotifier.value = newPoint;
              }
            } catch (e) {
              debugPrint('Error in pointer move: $e');
            }
          },
          child: MouseRegion(
            onHover: (event) {
              // Add hover support for smoother preview
              if (!polygonManager.isDrawing) return;

              try {
                final renderBox = context.findRenderObject() as RenderBox?;
                if (renderBox == null) return;

                final localPosition = renderBox.globalToLocal(event.position);
                final newPoint = _animatedMapController.mapController.camera
                    .pointToLatLng(Point(localPosition.dx, localPosition.dy));

                previewPointNotifier.value = newPoint;
              } catch (e) {
                debugPrint('Error in hover: $e');
              }
            },
            child: MapContent(
              mapController: _animatedMapController.mapController,
              selectedMap: selectedMap,
              zoomLevel: zoomLevel,
              polygonManager: polygonManager,
              barangayManager: barangayManager,
              previewPointNotifier: previewPointNotifier,
              setState: setState,
              barangayFilter: polygonManager.selectedBarangays,
              farmTypeFilters: BarangayFilterPanel.filterOptions,
              animatedMapController: _animatedMapController,
              onBarangayFilterChanged: (newFilters) {
                setState(() {
                  polygonManager.selectedBarangays = newFilters;
                });
              },
            ),
          ),
        ),
        if (_showFarmListPanel)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: FarmListPanel(
              polygonManager: polygonManager,
              barangayManager: barangayManager,
              selectedBarangays: polygonManager.selectedBarangays,
              onBarangayFilterChanged: (newFilters) {
                setState(() {
                  polygonManager.selectedBarangays = newFilters;
                });
              },
              onPolygonSelected: (int index) {
                setState(() {
                  polygonManager.selectPolygon(index);
                });
              },
              onFiltersChanged: () {
                setState(() {});
              },
            ),
          ),
        Positioned(
          top: 10,
          left: _showFarmListPanel ? 260 : 10,
          child: _buildStyledIconButton(
            icon: _showFarmListPanel
                ? Icons.arrow_left_rounded
                : Icons.arrow_right_rounded,
            onPressed: () {
              setState(() {
                _showFarmListPanel = !_showFarmListPanel;
              });
            },
            backgroundColor: Colors.white,
            iconSize: 15,
            buttonSize: 30.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
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
              setState(() {
                _animatedMapController.animatedZoomIn();
              });
            },
            onZoomOut: () {
              setState(() {
                _animatedMapController.animatedZoomOut();
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
              if (polygonManager.canUndo()) {
                setState(() {
                  polygonManager.undoLastPoint();
                });
              }
            },
          ),
        ),
        if (polygonManager.selectedPolygonIndex == null &&
            polygonManager.isEditing)
          Positioned(
            bottom: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  polygonManager.saveEditedPolygon();
                  polygonManager.toggleEditing();
                  polygonManager.selectedPolygon = null;
                  polygonManager.selectedPolygonIndex = null;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                'Save',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        if (polygonManager.selectedBarangays.isNotEmpty ||
            BarangayFilterPanel.filterOptions.values
                .any((isChecked) => !isChecked))
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 20),
              child: ElevatedButton(
                onPressed: polygonManager.clearFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(
                  'Reset Filters',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStyledIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? backgroundColor,
    double iconSize = 24.0,
    double buttonSize = 48.0,
    ShapeBorder? shape,
  }) {
    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        shape: shape is CircleBorder ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: shape is RoundedRectangleBorder
            ? (shape.borderRadius as BorderRadius?)
            : null,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: iconSize),
        padding: EdgeInsets.zero,
        alignment: Alignment.center,
      ),
    );
  }
}
