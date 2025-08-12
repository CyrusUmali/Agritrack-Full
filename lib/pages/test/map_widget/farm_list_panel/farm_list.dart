import 'package:flareline/pages/test/map_widget/farm_list_panel/barangay_filter_panel.dart';
import 'package:flareline/pages/test/map_widget/polygon_manager.dart';
import 'package:flutter/material.dart';

class FarmListPanel extends StatefulWidget {
  final PolygonManager polygonManager;
  final BarangayManager barangayManager;
  final List<String> selectedBarangays;
  final Function(List<String>) onBarangayFilterChanged;
  final Function(int) onPolygonSelected;
  final Function() onFiltersChanged;

  const FarmListPanel({
    Key? key,
    required this.polygonManager,
    required this.barangayManager,
    required this.selectedBarangays,
    required this.onBarangayFilterChanged,
    required this.onPolygonSelected,
    required this.onFiltersChanged,
  }) : super(key: key);

  @override
  _FarmListPanelState createState() => _FarmListPanelState();
}

class _FarmListPanelState extends State<FarmListPanel> with AutomaticKeepAliveClientMixin {
  String searchQuery = '';
  bool showBarangayFilter = false;

    @override
  bool get wantKeepAlive => true; // This preserves the state


  // Cache variables
  List<PolygonData>? _cachedFilteredPolygons;
  List<String>? _lastSelectedBarangays;
  String? _lastSearchQuery;
  Map<String, bool>? _lastFilterOptions;
  List<PolygonData>? _lastPolygons;

  @override
  void didUpdateWidget(FarmListPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Invalidate cache if any dependencies changed
    if (widget.polygonManager.polygons != _lastPolygons ||
        widget.selectedBarangays != _lastSelectedBarangays) {
      _cachedFilteredPolygons = null;
    }
  }

  List<PolygonData> get filteredPolygons {
    // Return cached result if nothing relevant changed
    if (_cachedFilteredPolygons != null &&
        _lastSelectedBarangays == widget.selectedBarangays &&
        _lastSearchQuery == searchQuery &&
        _lastFilterOptions == BarangayFilterPanel.filterOptions &&
        _lastPolygons == widget.polygonManager.polygons) {
      return _cachedFilteredPolygons!;
    }

    // Store current values for next comparison
    _lastSelectedBarangays = widget.selectedBarangays;
    _lastSearchQuery = searchQuery;
    _lastFilterOptions = Map.from(BarangayFilterPanel.filterOptions);
    _lastPolygons = widget.polygonManager.polygons;

    List<PolygonData> result = widget.polygonManager.polygons;

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      result = result
          .where((polygon) =>
              polygon.name.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    // Apply farm type filter
    result = result.where((polygon) {
      final pinStyle = polygon.pinStyle.toString().split('.').last;
      final filterKey = pinStyle[0].toUpperCase() + pinStyle.substring(1);
      return BarangayFilterPanel.filterOptions[filterKey] ?? false;
    }).toList();

    // Apply barangay filter
    if (widget.selectedBarangays.isNotEmpty) {
      result = result
          .where((p) => widget.selectedBarangays.contains(p.parentBarangay))
          .toList();
    }

    // Cache the result
    _cachedFilteredPolygons = result;
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (showBarangayFilter) {
      return BarangayFilterPanel(
        barangayManager: widget.barangayManager,
        selectedBarangays: widget.selectedBarangays,
        onFiltersChanged: (barangays, farmFilters) {
          setState(() {
            widget.onBarangayFilterChanged(barangays);
            BarangayFilterPanel.filterOptions = farmFilters;
          });
          widget.onFiltersChanged();
        },
        onClose: () => setState(() => showBarangayFilter = false),
      );
    }

    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? Colors.white,
        border: Border(
          left: BorderSide(
              color: theme.cardTheme.surfaceTintColor ?? Colors.grey,
              width: 2.0),
        ),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row( 
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search farms...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) => setState(() => searchQuery = value),
                ),
              ),
              SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.tune_sharp,
                    color: widget.selectedBarangays.isNotEmpty
                        ? theme.colorScheme.primary
                        : theme.disabledColor),
                onPressed: () {
                  setState(() => showBarangayFilter = true);
                },
              ),
            ],
          ),
          SizedBox(height: 16),
          Text('Farms',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontSize: 20, fontWeight: FontWeight.w400)),
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: filteredPolygons.length,
              itemBuilder: (context, filteredIndex) {
                final polygon = filteredPolygons[filteredIndex];
                final originalIndex =
                    widget.polygonManager.polygons.indexOf(polygon);

                return ListTile(
                  title: Text(
                    polygon.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: polygon.parentBarangay != null
                      ? Text(
                          'Barangay: ${polygon.parentBarangay}',
                          style: TextStyle(fontSize: 12),
                        )
                      : null,
                  tileColor: widget.polygonManager.selectedPolygonIndex ==
                          originalIndex
                      ? theme.colorScheme.primary.withOpacity(0.3)
                      : null,
                  onTap: () {
                    final overlayContext =
                        Navigator.of(context, rootNavigator: true).context;

                    widget.polygonManager.selectPolygon(
                      originalIndex,
                      context: overlayContext,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
