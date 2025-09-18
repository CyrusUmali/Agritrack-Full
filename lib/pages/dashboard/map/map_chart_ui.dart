import 'package:flareline/core/theme/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'barangay_data_provider.dart';

class MapChartUIComponents {
  static Widget buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  static Widget buildErrorState(
      BuildContext context, String errorMessage, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          const Text('Error', style: TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

// In map_chart_ui.dart - Updated buildProductSelector method

  static Widget buildProductSelector(
      BarangayDataProvider provider, BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade400,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Text(
            'Product: ',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Autocomplete<String>(
              // Set the initial value based on the selected product
              initialValue: provider.selectedProduct.isNotEmpty
                  ? TextEditingValue(text: provider.selectedProduct)
                  : null,
              fieldViewBuilder: (context, textEditingController, focusNode,
                  onFieldSubmitted) {
                // Set the controller's text if there's a selected product
                if (provider.selectedProduct.isNotEmpty &&
                    textEditingController.text != provider.selectedProduct) {
                  textEditingController.text = provider.selectedProduct;
                }

                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Search or select product',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    suffixIcon: textEditingController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              size: 20,
                              color: theme.iconTheme.color,
                            ),
                            onPressed: () {
                              textEditingController.clear();
                              provider.selectedProduct = '';
                              provider.updateColorsBasedOnYield();
                              FocusScope.of(context).requestFocus(focusNode);
                            },
                          )
                        : null,
                  ),
                  onSubmitted: (value) => onFieldSubmitted(),
                );
              },
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return provider.availableProducts;
                }
                return provider.availableProducts.where((product) {
                  return product.toLowerCase().contains(
                        textEditingValue.text.toLowerCase(),
                      );
                });
              },
              onSelected: (String selection) {
                provider.selectedProduct = selection;
                provider.updateColorsBasedOnYield();
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4,
                    color: theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                      side: BorderSide(
                        color: theme.dividerColor,
                        width: 1,
                      ),
                    ),
                    child: SizedBox(
                      width: 300,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxHeight: 200,
                        ),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final option = options.elementAt(index);
                            return InkWell(
                              onTap: () {
                                onSelected(option);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: index < options.length - 1
                                      ? Border(
                                          bottom: BorderSide(
                                            color: theme.dividerColor,
                                            width: 1,
                                          ),
                                        )
                                      : null,
                                ),
                                child: Text(
                                  option,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
              displayStringForOption: (option) => option,
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildTooltipRow({
    required IconData icon,
    required String label,
    required String value,
    required Color textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              color: textColor.withOpacity(0.9),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildMap(BarangayDataProvider provider,
      MapZoomPanBehavior zoomPanBehavior, BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          SfMaps(
            layers: [
              MapShapeLayer(
                zoomPanBehavior: zoomPanBehavior,
                source: MapShapeSource.asset(
                  'assets/barangay.json',
                  shapeDataField: 'name',
                  dataCount: provider.data.length,
                  primaryValueMapper: (int index) => provider.data[index].name,
                  dataLabelMapper: (int index) => provider.data[index].name,
                  shapeColorValueMapper: (int index) =>
                      provider.data[index].color,
                ),
                showDataLabels: true,

                // SOLUTION 1: Enhanced tooltip settings for mobile
                shapeTooltipBuilder: (BuildContext context, int index) {
                  final barangay = provider.data[index];
                  final colorLightness = barangay.color.computeLuminance();
                  final textColor =
                      colorLightness > 0.5 ? Colors.black : Colors.white;

                  double? yieldPercentage;
                  if (provider.selectedProduct.isNotEmpty) {
                    final yields = provider.data
                        .map((b) => b.yieldData[provider.selectedProduct] ?? 0)
                        .toList();
                    final maxYield = yields.reduce((a, b) => a > b ? a : b);
                    yieldPercentage =
                        (barangay.yieldData[provider.selectedProduct] ?? 0) /
                            maxYield *
                            100;
                  }

                  return Container(
                    width: 220,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          barangay.color.withOpacity(0.95), // Increased opacity
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            Colors.white.withOpacity(0.8), // Increased opacity
                        width: 2, // Increased width
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              Colors.black.withOpacity(0.3), // Stronger shadow
                          blurRadius: 12, // Increased blur
                          spreadRadius: 2, // Added spread
                          offset: const Offset(0, 4), // Increased offset
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 16, color: textColor),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                barangay.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (provider.selectedProduct.isNotEmpty) ...[
                          buildTooltipRow(
                            icon: Icons.agriculture,
                            label: '${provider.selectedProduct} Yield',
                            value:
                                '${barangay.yieldData[provider.selectedProduct]?.toStringAsFixed(1) ?? 'N/A'} kg',
                            textColor: textColor,
                          ),
                          if (yieldPercentage != null)
                            buildTooltipRow(
                              icon: Icons.trending_up,
                              label: 'Yield Percentage',
                              value: '${yieldPercentage.toStringAsFixed(1)}%',
                              textColor: textColor,
                            ),
                          const SizedBox(height: 4),
                        ],
                        buildTooltipRow(
                          icon: Icons.landscape,
                          label: 'Area',
                          value: '${barangay.area.toStringAsFixed(2)} km²',
                          textColor: textColor,
                        ),
                        buildTooltipRow(
                          icon: Icons.people,
                          label: 'Farmers',
                          value: barangay.farmer?.toStringAsFixed(0) ?? 'N/A',
                          textColor: textColor,
                        ),
                        if (barangay.topProducts.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Top Products:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          ...barangay.topProducts
                              .map((product) => Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, top: 4),
                                    child: Text(
                                      '• $product',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: textColor.withOpacity(0.9),
                                      ),
                                    ),
                                  ))
                              .take(3),
                        ],
                      ],
                    ),
                  );
                },

                // SOLUTION 2: Enhanced tooltip settings for mobile compatibility
                tooltipSettings: MapTooltipSettings(
                  hideDelay: 2000, // Increased delay to 2 seconds
                  color: Colors.transparent, // Let custom tooltip handle color
                ),

                // SOLUTION 3: Add onSelectionChanged callback for mobile tap handling
                onSelectionChanged: (int index) {
                  // This will trigger on mobile tap
                  // You can add haptic feedback here
                  // HapticFeedback.lightImpact();
                },

                strokeColor: Colors.white,
                strokeWidth: 0.8,
                dataLabelSettings: MapDataLabelSettings(
                  textStyle: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : GlobalColors.darkerCardColor,
                    fontSize: 10,
                  ),
                ),

                // SOLUTION 4: Enable selection to make shapes tappable on mobile
                selectionSettings: const MapSelectionSettings(
                  strokeColor: Colors.blue,
                  strokeWidth: 3,
                ),
              ),
            ],
          ),

          // Zoom Controls
          Positioned(
            top: 16,
            right: 16,
            child: Column(
              children: [
                // Zoom In Button
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color?.withOpacity(0.95),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    border: Border.all(
                      color: theme.dividerColor,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // Zoom in
                        final currentZoom = zoomPanBehavior.zoomLevel;
                        final newZoom = (currentZoom + 1).clamp(
                          zoomPanBehavior.minZoomLevel,
                          zoomPanBehavior.maxZoomLevel,
                        );
                        zoomPanBehavior.zoomLevel = newZoom;
                      },
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          Icons.add,
                          size: 20,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),

                // Divider line
                Container(
                  height: 1,
                  width: 44,
                  color: theme.dividerColor,
                ),

                // Zoom Out Button
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color?.withOpacity(0.95),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                    border: Border.all(
                      color: theme.dividerColor,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // Zoom out
                        final currentZoom = zoomPanBehavior.zoomLevel;
                        final newZoom = (currentZoom - 1).clamp(
                          zoomPanBehavior.minZoomLevel,
                          zoomPanBehavior.maxZoomLevel,
                        );
                        zoomPanBehavior.zoomLevel = newZoom;
                      },
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          Icons.remove,
                          size: 20,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (provider.selectedProduct.isNotEmpty)
            Positioned(
              bottom: 16,
              left: 16,
              child: buildLegend(provider, context),
            ),
        ],
      ),
    );
  }

  static Widget buildLegend(
      BarangayDataProvider provider, BuildContext context) {
    final theme = Theme.of(context);
    final yields = provider.data
        .map((b) => b.yieldData[provider.selectedProduct] ?? 0)
        .toList();
    final maxYield =
        yields.isNotEmpty ? yields.reduce((a, b) => a > b ? a : b) : 1;
    final minYield =
        yields.isNotEmpty ? yields.reduce((a, b) => a < b ? a : b) : 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.dividerColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${provider.selectedProduct} Yield (kg)',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              buildLegendItem(
                Colors.red[700]!,
                'High (${maxYield.toStringAsFixed(1)})',
                context,
              ),
              const SizedBox(width: 8),
              buildLegendItem(
                Colors.orange[400]!,
                'Medium (${(maxYield * 0.66).toStringAsFixed(1)})',
                context,
              ),
              const SizedBox(width: 8),
              buildLegendItem(
                Colors.green[400]!,
                'Low (${minYield.toStringAsFixed(1)})',
                context,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget buildLegendItem(
      Color color, String text, BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  static Widget buildBarangayList(
      BarangayDataProvider provider, BuildContext context) {
    final theme = Theme.of(context);

    // Create a dedicated ScrollController for this widget
    final ScrollController scrollController = ScrollController();

    return Container(
      width: 200,
      height: 400, // Add explicit height constraint
      constraints: const BoxConstraints(
        maxWidth: 250,
        maxHeight: 600, // Add max height constraint
        minHeight: 200, // Add min height constraint
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        border: Border.all(
          color: theme.dividerColor,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'Barangay List',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Divider(
            height: 1,
            color: theme.dividerColor,
          ),
          Expanded(
            child: Theme(
              data: theme.copyWith(
                scrollbarTheme: theme.scrollbarTheme.copyWith(
                  thumbColor: WidgetStateProperty.all(
                    theme.colorScheme.outline.withOpacity(0.5),
                  ),
                  trackColor: WidgetStateProperty.all(
                    theme.colorScheme.outline.withOpacity(0.1),
                  ),
                ),
              ),
              child: Scrollbar(
                controller: scrollController,
                thumbVisibility: true,
                child: ListView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  itemCount: provider.data.length,
                  itemBuilder: (context, index) {
                    final barangay = provider.data[index];
                    return ListTile(
                      dense: true,
                      minLeadingWidth: 24,
                      leading: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: barangay.color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.dividerColor,
                            width: 1,
                          ),
                        ),
                      ),
                      title: Text(
                        barangay.name,
                        style: theme.textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: provider.selectedProduct.isNotEmpty
                          ? Text(
                              '${barangay.yieldData[provider.selectedProduct]?.toStringAsFixed(2) ?? 'N/A'} kg',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.7),
                              ),
                            )
                          : null,
                      onTap: () {
                        // SOLUTION 6: Show bottom sheet with barangay details on mobile
                        _showBarangayDetailsBottomSheet(
                            context, barangay, provider);
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // SOLUTION 7: Alternative mobile-friendly detail view
  static void _showBarangayDetailsBottomSheet(
      BuildContext context, dynamic barangay, BarangayDataProvider provider) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Barangay name
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: barangay.color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    barangay.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Details
            if (provider.selectedProduct.isNotEmpty) ...[
              _buildDetailRow(
                context,
                Icons.agriculture,
                '${provider.selectedProduct} Yield',
                '${barangay.yieldData[provider.selectedProduct]?.toStringAsFixed(1) ?? 'N/A'} kg',
              ),
              const SizedBox(height: 12),
            ],

            _buildDetailRow(
              context,
              Icons.landscape,
              'Area',
              '${barangay.area.toStringAsFixed(2)} km²',
            ),
            const SizedBox(height: 12),

            _buildDetailRow(
              context,
              Icons.people,
              'Farmers',
              barangay.farmer?.toStringAsFixed(0) ?? 'N/A',
            ),

            if (barangay.topProducts.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'Top Products:',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...barangay.topProducts.take(5).map<Widget>(
                    (product) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.circle, size: 6),
                          const SizedBox(width: 8),
                          Text(product, style: theme.textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  static Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '$label:',
            style: theme.textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
