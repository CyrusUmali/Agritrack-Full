import 'dart:math';
import 'package:flareline/core/models/farmer_model.dart';
import 'package:flareline/core/models/product_model.dart';
import 'package:flareline/pages/test/map_widget/farm_list_panel/barangay_filter_panel.dart';
import 'package:flareline/pages/test/map_widget/farm_service.dart';
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
  const MapWidget({
    super.key,
    required this.routeObserver,
    required this.farmService,
    required this.products,
    required this.farmers,
  });

  final RouteObserver<ModalRoute> routeObserver;
  final FarmService farmService;
  final List<Product> products;
  final List<Farmer> farmers;

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget>
    with TickerProviderStateMixin, RouteAware {
  PolygonData? _selectedPolygonForModal;

  String selectedMap = "Google Satellite (No Labels)";
  bool _showFarmListPanel = false;
  double zoomLevel = 15.0;
  LatLng? previewPoint;

  bool _isLoading = true;
  String? _loadingError;

  late final AnimatedMapController _animatedMapController;
  late PolygonManager polygonManager;
  late BarangayManager barangayManager;
  final ValueNotifier<LatLng?> previewPointNotifier = ValueNotifier(null);

  late final RenderBox _renderBox;
  LatLng? _lastPoint;

  @override
  void initState() {
    super.initState();

    _loadFarmsFromApi();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _renderBox = context.findRenderObject() as RenderBox;
    });
    FarmInfoCard.loadBarangays();
    barangayManager = BarangayManager();
    _animatedMapController = AnimatedMapController(vsync: this);
    polygonManager = PolygonManager(
        context: context,
        mapController: _animatedMapController,
        onPolygonSelected: hideFarmListPanel,
        products: widget.products, // Add this
        farmers: widget.farmers, // Add this
        farmService: widget.farmService,
        onFiltersChanged: () => setState(() {}));

    barangayManager = BarangayManager();
    barangayManager.loadBarangays(barangays);
  }

  Future<void> _loadFarmsFromApi() async {
    if (!mounted) return; // Add this check

    setState(() {
      _isLoading = true;
      _loadingError = null;
    });

    try {
      final farmsData = await widget.farmService.fetchFarms();
      if (!mounted) return; // Check again after async operation

      final polygonsToLoad =
          farmsData.map((map) => PolygonData.fromMap(map)).toList();
      polygonManager.loadPolygons(polygonsToLoad);
    } catch (e) {
      if (!mounted) return; // Check before error handling

      setState(() {
        _loadingError = e.toString();
      });
      if (mounted) {
        // Additional check for ScaffoldMessenger
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load farms: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        // Check before final state update
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void hideFarmListPanel() {
    setState(() {
      _showFarmListPanel = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final route = ModalRoute.of(context);
    if (route == null) return;

    // Find any RouteObserver that can observe ModalRoute
    final navigator = Navigator.of(context);
    if (navigator is NavigatorState) {
      for (final observer in navigator.widget.observers) {
        if (observer is RouteObserver<ModalRoute>) {
          observer.subscribe(this, route);
          break;
        }
      }
    }
  }

  @override
  void dispose() {
    // Unsubscribe from route changes
    widget.routeObserver.unsubscribe(this);
    polygonManager.dispose();
    _animatedMapController.dispose();
    previewPointNotifier.dispose();
    super.dispose();
  }

  // Handle route changes
  @override
  void didPush() {
    polygonManager.removeInfoCardOverlay();
  }

  @override
  void didPop() {
    polygonManager.removeInfoCardOverlay();
  }

  @override
  void didPopNext() {
    polygonManager.removeInfoCardOverlay();
  }

  @override
  void didPushNext() {
    polygonManager.removeInfoCardOverlay();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading farm data...'),
          ],
        ),
      );
    }

    if (_loadingError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error loading data', style: TextStyle(color: Colors.red)),
            Text(_loadingError!),
            ElevatedButton(
              onPressed: _loadFarmsFromApi,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

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
                  hideFarmListPanel();
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

                if (_showFarmListPanel) {
                  polygonManager.selectedPolygonIndex = -1;
                  polygonManager.selectedPolygon = null;
                  polygonManager.selectedPolygonNotifier.value = null;

                  polygonManager.removeInfoCardOverlay();
                }
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
