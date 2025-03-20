// File: map_widget/map_controls.dart
import 'package:flutter/material.dart';

class MapControls extends StatelessWidget {
  final double zoomLevel;
  final bool isDrawing;
  final bool isEditing;
  final Map<String, String> mapLayers;
  final String selectedMap;
  final int? selectedPolygonIndex;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onToggleDrawing;
  final VoidCallback onToggleEditing;
  final Function(String?) onMapLayerChange;
  final VoidCallback onUndo;

  const MapControls({
    super.key,
    required this.zoomLevel,
    required this.isDrawing,
    required this.isEditing,
    required this.mapLayers,
    required this.selectedMap,
    required this.selectedPolygonIndex,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onToggleDrawing,
    required this.onToggleEditing,
    required this.onMapLayerChange,
    required this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildControlButton(
          tooltip: "Zoom In",
          icon: Icons.add,
          onPressed: onZoomIn,
        ),
        const SizedBox(height: 5),
        _buildControlButton(
          tooltip: "Zoom Out",
          icon: Icons.remove,
          onPressed: onZoomOut,
        ),
        const SizedBox(height: 5),
        _buildControlButton(
          tooltip: "Toggle Drawing Mode",
          icon: Icons.create,
          onPressed: onToggleDrawing,
          backgroundColor: isDrawing ? Colors.red : Colors.green,
        ),
        const SizedBox(height: 5),
        _buildControlButton(
          tooltip: "Change Map Layer",
          icon: Icons.map,
          onPressed: () async {
            final String? newValue = await showMenu<String>(
              context: context,
              position: RelativeRect.fromLTRB(100, 100, 50, 0),
              items: mapLayers.keys.map((String key) {
                return PopupMenuItem<String>(
                  value: key,
                  child: Text(key),
                );
              }).toList(),
            );

            onMapLayerChange(newValue);
          },
        ),
        const SizedBox(height: 5),
        _buildControlButton(
          tooltip: "Undo last point in selected polygon",
          icon: Icons.undo,
          onPressed: onUndo,
        ),
        const SizedBox(height: 5),
        _buildControlButton(
          tooltip: "Toggle Edit Mode",
          icon: Icons.edit,
          onPressed: onToggleEditing,
          backgroundColor: isEditing ? Colors.orange : Colors.grey,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required String tooltip,
    required IconData icon,
    required VoidCallback onPressed,
    Color? backgroundColor,
  }) {
    return Tooltip(
      message: tooltip,
      child: FloatingActionButton(
        mini: true,
        onPressed: onPressed,
        backgroundColor: backgroundColor,
        child: Icon(icon),
      ),
    );
  }
}
