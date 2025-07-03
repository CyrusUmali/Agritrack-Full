import 'package:flareline/core/models/farmer_model.dart';
import 'package:flareline/core/models/product_model.dart';
import 'package:flareline_uikit/core/theme/flareline_colors.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'polygon_modal_components/edit_controls.dart';
import 'polygon_modal_components/farm_info_card.dart';
import 'polygon_modal_components/yield_data_table.dart';
import '../pin_style.dart';
import '../polygon_manager.dart';

class PolygonModal {
  static Future<void> show({
    required BuildContext context,
    required PolygonData polygon,
    required Function(LatLng) onUpdateCenter,
    required Function(PinStyle) onUpdatePinStyle,
    required Function(Color) onUpdateColor,
    required Function(List<String>) onUpdateProducts,
    required Function(String) onUpdateFarmName,
    required Function(String) onUpdateFarmOwner,
    required Function(String) onUpdateBarangay,
    required VoidCallback onSave,
    required Function(int) onDeletePolygon, // Add this parameter
    String selectedYear = '2024',
    required Function(String) onYearChanged,
    required List<Product> products,
    required List<Farmer> farmers,
  }) async {
    final theme = Theme.of(context);
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    final polygonCopy = polygon.copyWith();

    // Local update callbacks
    void updateCopyCenter(LatLng center) => polygonCopy.center = center;
    void updateCopyPinStyle(PinStyle style) => polygonCopy.pinStyle = style;
    void updateCopyColor(Color color) => polygonCopy.color = color;
    void updateCopyProducts(List<String> products) =>
        polygonCopy.products = products;
    void updateCopyFarmName(String name) => polygonCopy.name = name;
    void updateCopyFarmOwner(String owner) => polygonCopy.owner = owner;
    void updateCopyBarangay(String barangay) =>
        polygonCopy.parentBarangay = barangay;

    if (isLargeScreen) {
      await _showLargeScreenModal(
        context: context,
        polygon: polygonCopy,
        farmers: farmers,
        products: products,
        onUpdateCenter: updateCopyCenter,
        onUpdatePinStyle: updateCopyPinStyle,
        onUpdateColor: updateCopyColor,
        onUpdateProducts: updateCopyProducts,
        onUpdateFarmName: updateCopyFarmName,
        onUpdateFarmOwner: updateCopyFarmOwner,
        onUpdateBarangay: updateCopyBarangay,
        onSave: () {
          polygon.updateFrom(polygonCopy);
          onSave();
        },
        onDeletePolygon: onDeletePolygon,
        selectedYear: selectedYear,
        onYearChanged: onYearChanged,
        theme: theme,
      );
    } else {
      await _showSmallScreenModal(
        context: context,
        polygon: polygonCopy,
        farmers: farmers,
        products: products,
        onUpdateCenter: updateCopyCenter,
        onUpdatePinStyle: updateCopyPinStyle,
        onUpdateColor: updateCopyColor,
        onUpdateProducts: updateCopyProducts,
        onUpdateFarmName: updateCopyFarmName,
        onUpdateFarmOwner: updateCopyFarmOwner,
        onUpdateBarangay: updateCopyBarangay,
        onSave: () {
          polygon.updateFrom(polygonCopy);
          onSave();
        },
        onDeletePolygon: onDeletePolygon, // Pass it through
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
    required Function(List<String>) onUpdateProducts,
    required Function(String) onUpdateFarmName,
    required Function(String) onUpdateFarmOwner,
    required Function(String) onUpdateBarangay,
    required Function(int) onDeletePolygon, // Add this parameter
    required VoidCallback onSave,
    required String selectedYear,
    required Function(String) onYearChanged,
    required ThemeData theme,
    required List<Farmer> farmers,
    required List<Product> products,
  }) async {
    await WoltModalSheet.show(
      context: context,
      pageListBuilder: (modalContext) => [
        WoltModalSheetPage(
          backgroundColor: Colors.white,
          hasSabGradient: false,
          isTopBarLayerAlwaysVisible: true,
          trailingNavBarWidget: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () => Navigator.of(modalContext).pop(),
                ),
              ],
            ),
          ),
          child: Container(
            color: Colors.white,
            child: _ModalContent(
              polygon: polygon,
              products: products,
              farmers: farmers,
              onUpdateCenter: onUpdateCenter,
              onUpdatePinStyle: onUpdatePinStyle,
              onUpdateColor: onUpdateColor,
              onUpdateProducts: onUpdateProducts,
              onUpdateFarmName: onUpdateFarmName,
              onUpdateFarmOwner: onUpdateFarmOwner,
              onUpdateBarangay: onUpdateBarangay,
              selectedYear: selectedYear,
              theme: theme,
              onSave: () {},
              onDeletePolygon: onDeletePolygon,
            ),
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
                backgroundColor: FlarelineColors.primary,
                foregroundColor: Colors.white,
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
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        )
      ],
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
    required Function(List<String>) onUpdateProducts,
    required Function(String) onUpdateFarmName,
    required Function(String) onUpdateFarmOwner,
    required Function(String) onUpdateBarangay,
    required VoidCallback onSave,
    required Function(int) onDeletePolygon, // Add this parameter
    required String selectedYear,
    required Function(String) onYearChanged,
    required ThemeData theme,
    required List<Farmer> farmers,
    required List<Product> products,
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
              products: products,
              farmers: farmers,
              onUpdateCenter: onUpdateCenter,
              onUpdatePinStyle: onUpdatePinStyle,
              onUpdateColor: onUpdateColor,
              onUpdateProducts: onUpdateProducts,
              onUpdateFarmName: onUpdateFarmName,
              onUpdateFarmOwner: onUpdateFarmOwner,
              onUpdateBarangay: onUpdateBarangay,
              selectedYear: selectedYear,
              theme: theme,
              isLargeScreen: true,
              onSave: () {
                onSave();
                Navigator.of(context).pop();
              },
              onDeletePolygon: onDeletePolygon,
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
  final Function(List<String>) onUpdateProducts;
  final Function(String) onUpdateFarmName;
  final Function(String) onUpdateFarmOwner;
  final Function(String) onUpdateBarangay;
  final Function(int) onDeletePolygon; // Add this
  final String selectedYear;
  final ThemeData theme;
  final bool isLargeScreen;
  final VoidCallback onSave;
  final List<Product> products;
  final List<Farmer> farmers;

  const _ModalContent({
    required this.polygon,
    required this.onUpdateCenter,
    required this.onUpdatePinStyle,
    required this.onUpdateColor,
    required this.onUpdateProducts,
    required this.onUpdateFarmName,
    required this.onUpdateFarmOwner,
    required this.onUpdateBarangay,
    required this.onDeletePolygon, // Add this
    required this.selectedYear,
    required this.theme,
    required this.products,
    required this.farmers,
    this.isLargeScreen = false,
    required this.onSave,
    Key? key,
  }) : super(key: key);

  @override
  State<_ModalContent> createState() => _ModalContentState();
}

class _ModalContentState extends State<_ModalContent> {
  late TextEditingController latController;
  late TextEditingController lngController;
  late Color selectedColor;
  late PinStyle selectedPinStyle;
  late List<String> selectedProducts;
  late String farmName;
  late String farmOwner;
  late String barangay;

  @override
  void initState() {
    super.initState();
    final center = widget.polygon.center;
    latController = TextEditingController(
      text: center?.latitude.toStringAsFixed(6) ?? '0.0',
    );
    lngController = TextEditingController(
      text: center?.longitude.toStringAsFixed(6) ?? '0.0',
    );

    selectedColor = widget.polygon.color;
    selectedPinStyle = widget.polygon.pinStyle;
    selectedProducts = widget.polygon.products?.toList() ?? [];
    farmName = widget.polygon.name ?? '';
    farmOwner = widget.polygon.owner ?? '';
    barangay = widget.polygon.parentBarangay ?? '';
  }

  @override
  void didUpdateWidget(covariant _ModalContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.polygon != widget.polygon) {
      final center = widget.polygon.center;
      latController.text = center?.latitude.toStringAsFixed(6) ?? '0.0';
      lngController.text = center?.longitude.toStringAsFixed(6) ?? '0.0';
      selectedColor = widget.polygon.color;
      selectedPinStyle = widget.polygon.pinStyle;
      selectedProducts = widget.polygon.products?.toList() ?? [];
      farmName = widget.polygon.name ?? '';
      farmOwner = widget.polygon.owner ?? '';
      barangay = widget.polygon.parentBarangay ?? '';
    }
  }

  @override
  void dispose() {
    latController.dispose();
    lngController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.polygon.vertices.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.isLargeScreen) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
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
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FarmInfoCard.build(
                          context: context,
                          products: widget.products, // Add this
                          farmers: widget.farmers, // Add this
                          polygon: widget.polygon.copyWith(
                            products: selectedProducts,
                            name: farmName,
                            owner: farmOwner,
                            parentBarangay: barangay,
                          ),
                          theme: widget.theme,
                          onBarangayChanged: (newBarangay) {
                            setState(() => barangay = newBarangay);
                            widget.onUpdateBarangay(newBarangay);
                          },
                          onFarmOwnerChanged: (newOwner) {
                            setState(() => farmOwner = newOwner);
                            widget.onUpdateFarmOwner(newOwner);
                          },
                          onFarmNameChanged: (newName) {
                            setState(() => farmName = newName);
                            widget.onUpdateFarmName(newName);
                          },
                          onFarmUpdated: (updatedPolygon) {
                            setState(() {
                              selectedProducts = updatedPolygon.products ?? [];
                              farmName = updatedPolygon.name ?? '';
                              farmOwner = updatedPolygon.owner ?? '';
                              barangay = updatedPolygon.parentBarangay ?? '';
                            });
                            widget.onUpdateProducts(selectedProducts);
                            widget.onUpdateFarmName(farmName);
                            widget.onUpdateFarmOwner(farmOwner);
                            widget.onUpdateBarangay(barangay);
                          },
                        ),
                        const SizedBox(height: 24),
                        EditControls.build(
                          context: context,
                          polygon: widget.polygon,
                          selectedPinStyle: selectedPinStyle,
                          selectedColor: selectedColor,
                          onColorChanged: (color) {
                            setState(() => selectedColor = color);
                            widget.onUpdateColor(color);
                          },
                          onPinStyleChanged: (style) {
                            setState(() => selectedPinStyle = style);
                            widget.onUpdatePinStyle(style);
                          },
                          onDelete: () {
                            // Add this new callback
                            widget.onDeletePolygon(
                                widget.polygon.id!); // Add ! to assert non-null
                            debugPrint('id' + widget.polygon.id.toString());

                            Navigator.of(context)
                                .pop(); // Close the edit dialog if needed
                          },
                          theme: widget.theme,
                        ),
                      ],
                    ),
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    // padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [YieldDataTable(polygon: widget.polygon)],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: FlarelineColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 48),
                maximumSize: const Size(400, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: widget.onSave,
              child: const Text(
                'Save Changes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
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
            FarmInfoCard.build(
              context: context,
              products: widget.products, // Add this
              farmers: widget.farmers, // Add this
              polygon: widget.polygon.copyWith(
                products: selectedProducts,
                name: farmName,
                owner: farmOwner,
                parentBarangay: barangay,
              ),
              theme: widget.theme,
              onBarangayChanged: (newBarangay) {
                setState(() => barangay = newBarangay);
                widget.onUpdateBarangay(newBarangay);
              },
              onFarmOwnerChanged: (newOwner) {
                setState(() => farmOwner = newOwner);
                widget.onUpdateFarmOwner(newOwner);
              },
              onFarmNameChanged: (newName) {
                setState(() => farmName = newName);
                widget.onUpdateFarmName(newName);
              },
              onFarmUpdated: (updatedPolygon) {
                setState(() {
                  selectedProducts = updatedPolygon.products ?? [];
                  farmName = updatedPolygon.name ?? '';
                  farmOwner = updatedPolygon.owner ?? '';
                  barangay = updatedPolygon.parentBarangay ?? '';
                });
                widget.onUpdateProducts(selectedProducts);
                widget.onUpdateFarmName(farmName);
                widget.onUpdateFarmOwner(farmOwner);
                widget.onUpdateBarangay(barangay);
              },
            ),
            // const SizedBox(height: 16),
            EditControls.build(
              context: context,
              polygon: widget.polygon,
              selectedPinStyle: selectedPinStyle,
              selectedColor: selectedColor,
              onColorChanged: (color) {
                setState(() => selectedColor = color);
                widget.onUpdateColor(color);
              },
              onPinStyleChanged: (style) {
                setState(() => selectedPinStyle = style);
                widget.onUpdatePinStyle(style);
              },
              onDelete: () {
                // Add this new callback
                widget.onDeletePolygon(
                    widget.polygon.id!); // Add ! to assert non-null
                Navigator.of(context).pop(); // Close the edit dialog if needed
              },
              theme: widget.theme,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 100),
              child: YieldDataTable(polygon: widget.polygon),
            ),
          ],
        ),
      );
    }
  }
}
