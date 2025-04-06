import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'polygon_modal_components/edit_controls.dart';
import 'polygon_modal_components/farm_info_card.dart';
import 'polygon_modal_components/yield_data_table.dart';
import 'polygon_modal_components/vertices_coordinates_card.dart';

import '../pin_style.dart';
import '../polygon_manager.dart';

class PolygonModal {
  static Future<void> show({
    required BuildContext context,
    required PolygonData polygon,
    required Function(LatLng) onUpdateCenter,
    required Function(PinStyle) onUpdatePinStyle,
    required Function(Color) onUpdateColor,
    required VoidCallback onSave,
    String selectedYear = '2024',
    required Function(String) onYearChanged,
  }) async {
    final theme = Theme.of(context);
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    final polygonCopy = polygon.copyWith();

    // Create local callbacks that update the copy
    void updateCopyCenter(LatLng center) {
      polygonCopy.center = center;
    }

    void updateCopyPinStyle(PinStyle style) {
      polygonCopy.pinStyle = style;
    }

    void updateCopyColor(Color color) {
      polygonCopy.color = color;
    }

    if (isLargeScreen) {
      await _showLargeScreenModal(
        context: context,
        polygon: polygonCopy, // Pass the copy
        onUpdateCenter: updateCopyCenter, // Use local callback
        onUpdatePinStyle: updateCopyPinStyle, // Use local callback
        onUpdateColor: updateCopyColor, // Use local callback
        onSave: () {
          // Only update the original polygon when saved
          polygon.updateFrom(polygonCopy);
          onSave();
        },
        selectedYear: selectedYear,
        onYearChanged: onYearChanged,
        theme: theme,
      );
    } else {
      await _showSmallScreenModal(
        context: context,
        polygon: polygonCopy, // Pass the copy
        onUpdateCenter: updateCopyCenter, // Use local callback
        onUpdatePinStyle: updateCopyPinStyle, // Use local callback
        onUpdateColor: updateCopyColor, // Use local callback
        onSave: () {
          // Only update the original polygon when saved
          polygon.updateFrom(polygonCopy);
          onSave();
        },
        selectedYear: selectedYear,
        onYearChanged: onYearChanged,
        theme: theme,
      );
    }
  }

  static Future<void> _showSmallScreenModal({
    required BuildContext context,
    required PolygonData polygon,
    required Function(LatLng) onUpdateCenter,
    required Function(PinStyle) onUpdatePinStyle,
    required Function(Color) onUpdateColor,
    required VoidCallback onSave,
    required String selectedYear,
    required Function(String) onYearChanged,
    required ThemeData theme,
  }) async {
    await WoltModalSheet.show(
      context: context,
      pageListBuilder: (modalContext) {
        return [
          WoltModalSheetPage(
            hasSabGradient: true,
            topBarTitle: Text(
              'Farm Details',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            isTopBarLayerAlwaysVisible: true,
            trailingNavBarWidget: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(modalContext).pop(),
            ),
            child: _ModalContent(
              polygon: polygon,
              onUpdateCenter: onUpdateCenter,
              onUpdatePinStyle: onUpdatePinStyle,
              onUpdateColor: onUpdateColor,
              selectedYear: selectedYear,
              theme: theme,
            ),
            stickyActionBar: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  )
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: () {
                  onSave();
                  Navigator.of(modalContext).pop();
                },
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                      fontSize: 16, // Slightly larger font size
                      fontWeight: FontWeight.w600, // Semi-bold weight
                      color: Colors.white),
                ),
              ),
            ),
          )
        ];
      },
      modalTypeBuilder: (context) => const WoltBottomSheetType(),
      onModalDismissedWithBarrierTap: () => Navigator.of(context).pop(),
    );
  }

  static Future<void> _showLargeScreenModal({
    required BuildContext context,
    required PolygonData polygon,
    required Function(LatLng) onUpdateCenter,
    required Function(PinStyle) onUpdatePinStyle,
    required Function(Color) onUpdateColor,
    required VoidCallback onSave,
    required String selectedYear,
    required Function(String) onYearChanged,
    required ThemeData theme,
  }) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.all(20),
          contentPadding: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            child: _ModalContent(
              polygon: polygon,
              onUpdateCenter: onUpdateCenter,
              onUpdatePinStyle: onUpdatePinStyle,
              onUpdateColor: onUpdateColor,
              selectedYear: selectedYear,
              theme: theme,
              isLargeScreen: true,
              onSave: () {
                onSave();
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      },
    );
  }
}

class _ModalContent extends StatefulWidget {
  final PolygonData polygon;
  final Function(LatLng) onUpdateCenter;
  final Function(PinStyle) onUpdatePinStyle;
  final Function(Color) onUpdateColor;
  final String selectedYear;
  final ThemeData theme;
  final bool isLargeScreen;
  final VoidCallback? onSave;

  const _ModalContent({
    required this.polygon,
    required this.onUpdateCenter,
    required this.onUpdatePinStyle,
    required this.onUpdateColor,
    required this.selectedYear,
    required this.theme,
    this.isLargeScreen = false,
    this.onSave,
  });

  @override
  State<_ModalContent> createState() => _ModalContentState();
}

class _ModalContentState extends State<_ModalContent> {
  late TextEditingController latController;
  late TextEditingController lngController;
  late Color selectedColor;
  late PinStyle selectedPinStyle; // Add this variable

  @override
  void initState() {
    super.initState();
    _updateControllers();
    selectedColor = widget.polygon.color;
    selectedPinStyle = widget.polygon.pinStyle; // Initialize it
  }

  @override
  void didUpdateWidget(covariant _ModalContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.polygon != widget.polygon) {
      _updateControllers();
      selectedColor = widget.polygon.color;
      selectedPinStyle =
          widget.polygon.pinStyle; // Update it when polygon changes
    }
  }

  void _updateControllers() {
    latController = TextEditingController(
      text: widget.polygon.center.latitude.toStringAsFixed(6),
    );
    lngController = TextEditingController(
      text: widget.polygon.center.longitude.toStringAsFixed(6),
    );
  }

  @override
  void dispose() {
    latController.dispose();
    lngController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = widget.theme.colorScheme;
    final textTheme = widget.theme.textTheme;

    if (widget.isLargeScreen) {
      return Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Farm Details: ${widget.polygon.name}',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side - Info and controls
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FarmInfoCard.build(
                          context: context,
                          polygon: widget.polygon,
                          theme: widget.theme,
                          onBarangayChanged: (newBarangay) {
                            // Handle barangay change here
                          },
                        ),
                        const SizedBox(height: 24),
                        EditControls.build(
                          context: context,
                          polygon: widget.polygon,
                          selectedPinStyle:
                              selectedPinStyle, // Add this parameter
                          latController: latController,
                          lngController: lngController,
                          selectedColor: selectedColor,
                          onColorChanged: (color) {
                            setState(() {
                              selectedColor = color;
                              // widget.polygon.color =
                              //     color; // Update local copy only
                            });
                            widget
                                .onUpdateColor(color); // This updates the copy
                          },
                          onPinStyleChanged: (style) {
                            setState(() {
                              selectedPinStyle = style;
                              // widget.polygon.pinStyle =
                              //     style; // Update local copy only
                            });
                            widget.onUpdatePinStyle(
                                style); // This updates the copy
                          },
                          onCenterChanged: (center) {
                            widget.onUpdateCenter(center);
                            setState(() {
                              latController.text =
                                  center.latitude.toStringAsFixed(6);
                              lngController.text =
                                  center.longitude.toStringAsFixed(6);
                            });
                          },
                          theme: widget.theme,
                        ),
                        const SizedBox(height: 24),
                        VerticesCoordinatesCard.build(
                          context: context,
                          vertices: widget.polygon.vertices,
                          theme: widget.theme,
                        ),
                      ],
                    ),
                  ),
                ),
                const VerticalDivider(width: 1),
                // Right side - Data tables
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const YieldDataTable(), // Simplified usage
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Footer with save button
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal:
                  24.0, // Increased horizontal padding for larger screens
              vertical: 16.0,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 200, // Minimum width
                maxWidth: 400, // Maximum width for very large screens
              ),
              child: SizedBox(
                width: double.infinity, // Will expand up to maxWidth
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.black87,
                    elevation:
                        2, // Added slight elevation for better visibility
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 18, // Slightly increased vertical padding
                      horizontal: 32, // Increased horizontal padding
                    ),
                  ),
                  onPressed: widget.onSave,
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                        fontSize: 16, // Slightly larger font size
                        fontWeight: FontWeight.w600, // Semi-bold weight
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with farm name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                widget.polygon.name,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ),

            // Farm info card
            FarmInfoCard.build(
              context: context,
              polygon: widget.polygon,
              theme: widget.theme,
              onBarangayChanged: (newBarangay) {
                // Handle barangay change here
              },
            ),
            const SizedBox(height: 16),

            // Edit controls section
            EditControls.build(
              context: context,
              polygon: widget.polygon,
              selectedPinStyle: selectedPinStyle, // Add this parameter
              latController: latController,
              lngController: lngController,
              selectedColor: selectedColor,
              onColorChanged: (color) {
                setState(() {
                  selectedColor = color;
                  // widget.polygon.color = color; // Update local copy only
                });
                widget.onUpdateColor(color); // This updates the copy
              },
              onPinStyleChanged: (style) {
                setState(() {
                  selectedPinStyle = style;
                  // widget.polygon.pinStyle = style; // Update local copy only
                });
                widget.onUpdatePinStyle(style); // This updates the copy
              },
              onCenterChanged: (center) {
                widget.polygon.center = center; // Update local copy only
                setState(() {
                  latController.text = center.latitude.toStringAsFixed(6);
                  lngController.text = center.longitude.toStringAsFixed(6);
                });
              },
              theme: widget.theme,
            ),

            // Yield data section
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 100),
              child: const YieldDataTable(),
            ),

            // Add the vertices coordinates card
            VerticesCoordinatesCard.build(
              context: context,
              vertices: widget.polygon.vertices,
              theme: widget.theme,
            ),
          ],
        ),
      );
    }
  }
}
