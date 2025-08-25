import 'dart:math';
import 'package:flareline/core/models/farmer_model.dart';
import 'package:flareline/core/models/product_model.dart';
import 'package:flareline/pages/test/map_widget/farm_list_panel/barangay_filter_panel.dart';
import 'package:flareline/pages/test/map_widget/farm_service.dart';
import 'package:flareline/pages/test/map_widget/map_panel/polygon_modal_components/farm_info_card.dart';
import 'package:flareline/pages/toast/toast_helper.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flareline/pages/test/map_widget/pin_style.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
  bool _showLegendPanel = false;
  double zoomLevel = 15.0;
  LatLng? previewPoint;
  bool _isLoading = true;
  String? _loadingError;

    bool get isMobile => MediaQuery.of(context).size.width < 600;

  late final AnimatedMapController _animatedMapController;
  late PolygonManager polygonManager;
  late BarangayManager barangayManager;
  final ValueNotifier<LatLng?> previewPointNotifier = ValueNotifier(null);
  late final RenderBox _renderBox;
  LatLng? _lastPoint;

  @override
  void initState() {
    print("Initializing MapWidget with products and farmers"); 
    print(widget.farmers);
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
        products: widget.products,
        farmers: widget.farmers,
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
        ToastHelper.showErrorToast(
          'Failed to load farms: ${e.toString()}',
          context,
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
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: LoadingAnimationWidget.inkDrop(
            color: Colors.blue,
            size: 50,
          ),
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
            if (!polygonManager.isDrawing) return;
            try {
              final renderBox =
                  _renderBox ?? context.findRenderObject() as RenderBox?;
              if (renderBox == null) return;
              final localPosition = renderBox.globalToLocal(event.position);
              final newPoint = _animatedMapController.mapController.camera
                  .pointToLatLng(Point(localPosition.dx, localPosition.dy));
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

        // Farm List Panel
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
                setState(() {});
              },
              onFiltersChanged: () {
                setState(() {});
              },
            ),
          ),
  
        // Legend Panel
        if (_showLegendPanel)
          Positioned(
            left: _showFarmListPanel ? 320 : 60,
            top: 20,
            child: _buildLegendPanel(),
          ),

        // Panel and Legend Toggle Buttons in Column
        Positioned(
          top: 10,
          left: _showFarmListPanel ? 270 : 10,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Panel Toggle Button
              _buildStyledIconButton(
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
                 buttonSize:  isMobile ?40.0 : 30,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              SizedBox(height: 10), // Add some spacing between buttons
              // Legend Toggle Button
              _buildStyledIconButton(
                icon: _showLegendPanel
                    ? Icons.legend_toggle
                    : Icons.legend_toggle_outlined,
                onPressed: () {
                  setState(() {
                    _showLegendPanel = !_showLegendPanel;
                  });
                },
                backgroundColor: Colors.white,
                iconSize: 15,
                buttonSize:  isMobile ?40.0 : 30,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ],
          ),
        ),
        // Map Controls
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

        if (polygonManager.selectedPolygonIndex != null &&
            polygonManager.isEditing)
          Positioned(
            bottom: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  polygonManager.saveEditedPolygon();
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
        if (polygonManager.selectedBarangays.isNotEmpty && !_showFarmListPanel ||
            BarangayFilterPanel.filterOptions.values 
                .any((isChecked) => !isChecked)  && !_showFarmListPanel   )
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

Widget _buildLegendPanel() {
  return Container(
    width: 200,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration( 
      color:Theme.of(context).cardTheme.color ?? Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).shadowColor.withOpacity(0.1),
          blurRadius: 16,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ],
      border: Border.all(
        color: Theme.of(context).dividerColor.withOpacity(0.1),
        width: 1,
      ),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Legend',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
        ),
        const SizedBox(height: 16),
        ...PinStyle.values.map((style) => _buildLegendItem(style)),
        const SizedBox(height: 8),
        _buildBarangayLegendItem(),
      ],
    ),
  );
}

Widget _buildLegendItem(PinStyle pinStyle) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: getPinColor(pinStyle),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: getPinColor(pinStyle).withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: getPinIcon(pinStyle),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            _formatPinStyleName(pinStyle),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildBarangayLegendItem() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.redAccent,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.account_balance,
            color: Colors.white,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Barangay',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildStyledIconButton({
  required IconData icon,
  required VoidCallback onPressed,
  Color? backgroundColor,
  Color? iconColor,
  double iconSize = 24.0,
  double buttonSize = 48.0,
  ShapeBorder? shape,
  bool elevated = false,
}) {
  final defaultBackgroundColor = Theme.of(context).cardColor;
  final defaultIconColor = Theme.of(context).iconTheme.color;

      final cardColor = Theme.of(context).cardTheme.color ?? Colors.white;
  
  return Material(
    color: Colors.transparent,
    child: Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        color: cardColor,
        shape: shape is CircleBorder ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: shape is RoundedRectangleBorder
            ? (shape.borderRadius as BorderRadius?)
            : shape == null
                ? BorderRadius.circular(8)
                : null,
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: shape is CircleBorder
            ? BorderRadius.circular(buttonSize / 2)
            : shape is RoundedRectangleBorder
                ? (shape.borderRadius as BorderRadius?)
                : BorderRadius.circular(8),
        child: Icon(
          icon,
          size: iconSize,
          color: iconColor ?? defaultIconColor,
        ),
      ),
    ),
  );
}

// Helper method to format pin style names
String _formatPinStyleName(PinStyle pinStyle) {
  String name = pinStyle.toString().split('.').last;
  
  // Handle special cases for better readability
  switch (name.toLowerCase()) {
    case 'hvc':
      return 'High Value Crops';
    default:
      return name;
  }
}

}
