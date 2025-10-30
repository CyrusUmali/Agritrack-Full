import 'package:flareline/core/theme/global_colors.dart';
import 'package:flareline/pages/dashboard/map/barangay_model.dart';
import 'package:flareline/pages/widget/network_error.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'barangay_data_provider.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

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
          NetworkErrorWidget(
            error: 'Error',
            onRetry: onRetry, // Fixed: removed unnecessary closure
          )
        ],
      ),
    );
  }

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
              initialValue: provider.selectedProduct.isNotEmpty
                  ? TextEditingValue(text: provider.selectedProduct)
                  : null,
              fieldViewBuilder: (context, textEditingController, focusNode,
                  onFieldSubmitted) {
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
                shapeTooltipBuilder: (BuildContext context, int index) {
                  final barangay = provider.data[index];
                  final theme = Theme.of(context);
                  final bool isMobile = MediaQuery.of(context).size.width < 600;

                  double? yieldPercentage;
                  double? yieldValue;
                  if (provider.selectedProduct.isNotEmpty) {
                    final yields = provider.data
                        .map((b) => b.yieldData[provider.selectedProduct] ?? 0)
                        .toList();
                    final maxYield = yields.reduce((a, b) => a > b ? a : b);
                    yieldValue =
                        barangay.yieldData[provider.selectedProduct] ?? 0;
                    yieldPercentage =
                        maxYield > 0 ? (yieldValue / maxYield * 100) : 0;
                  }

                  final totalYield = barangay.yieldData.values
                      .fold(0.0, (sum, value) => sum + value);

                  final totalFarms = provider.yields
                      .where((y) => y.barangay == barangay.name)
                      .map((y) => y.farmId)
                      .toSet()
                      .length;

                  final sortedProducts = barangay.yieldData.entries.toList()
                    ..sort((a, b) => b.value.compareTo(a.value));

                  return Container(
                    width: isMobile ? 280 : 500, // Much wider on desktop
                    constraints: BoxConstraints(
                      maxHeight:
                          isMobile ? 450 : 400, // Slightly shorter on desktop
                    ),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).cardTheme.color?.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.black.withOpacity(0.8),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 16,
                          spreadRadius: 1,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with barangay name
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(isMobile ? 12 : 16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.location_on,
                                  size: isMobile ? 18 : 20,
                                  color: Colors.white),
                              SizedBox(width: isMobile ? 6 : 8),
                              Expanded(
                                child: Text(
                                  barangay.name,
                                  style: TextStyle(
                                    fontSize: isMobile ? 16 : 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Content
                        Padding(
                          padding: EdgeInsets.all(isMobile ? 12 : 16),
                          child: isMobile
                              ? _buildMobileLayout(
                                  barangay,
                                  provider,
                                  theme,
                                  yieldValue,
                                  yieldPercentage,
                                  totalYield,
                                  totalFarms,
                                  sortedProducts)
                              : _buildDesktopLayout(
                                  barangay,
                                  provider,
                                  theme,
                                  yieldValue,
                                  yieldPercentage,
                                  totalYield,
                                  totalFarms,
                                  sortedProducts),
                        ),
                      ],
                    ),
                  );
                },
                tooltipSettings: const MapTooltipSettings(
                  hideDelay: 10,
                  color: Colors.transparent,
                  strokeColor: Colors.transparent,
                  strokeWidth: 0,
                ),
                onSelectionChanged: (int index) {
                  // This will trigger on mobile tap
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
                selectionSettings: const MapSelectionSettings(
                  strokeColor: Colors.blue,
                  strokeWidth: 3,
                ),
              ),
            ],
          ),
          if (!kIsWeb)
            Positioned(
              top: 16,
              right: 16,
              child: Column(
                children: [
                  // Zoom In Button
                  Container(
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).cardTheme.color?.withOpacity(0.95),
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
                      color:
                          Theme.of(context).cardTheme.color?.withOpacity(0.95),
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
              child: _LegendWidget(provider: provider), // Use stateful widget
            ),
        ],
      ),
    );
  }

// Mobile layout (single column)
  static Widget _buildMobileLayout(
      BarangayModel barangay,
      BarangayDataProvider provider,
      ThemeData theme,
      double? yieldValue,
      double? yieldPercentage,
      double totalYield,
      int totalFarms,
      List<MapEntry<String, double>> sortedProducts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (provider.selectedProduct.isNotEmpty) ...[
          _buildSelectedProductSection(
              barangay, provider, theme, yieldValue, yieldPercentage, true),
          const SizedBox(height: 12),
        ],

        // General Information - Single column for mobile
        _buildInfoRow(
          icon: Icons.landscape,
          label: 'Total Area',
          value: '${barangay.area.toStringAsFixed(2)} hectares',
          theme: theme,
          isMobile: true,
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          icon: Icons.home_work,
          label: 'Total Farms',
          value: '$totalFarms',
          theme: theme,
          isMobile: true,
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          icon: Icons.people,
          label: 'Farmers',
          value: barangay.farmer?.toStringAsFixed(0) ?? 'N/A',
          theme: theme,
          isMobile: true,
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          icon: Icons.inventory,
          label: 'Total Yield',
          value: '${totalYield.toStringAsFixed(2)} kg',
          theme: theme,
          isMobile: true,
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          icon: Icons.category,
          label: 'Products',
          value: '${barangay.yieldData.length} types',
          theme: theme,
          isMobile: true,
        ),

        // Top Products Section
        if (sortedProducts.isNotEmpty && totalYield > 0) ...[
          const SizedBox(height: 16),
          _buildTopProductsSection(sortedProducts, totalYield, theme, true),
        ],
      ],
    );
  }

// Desktop layout (multi-column)
  static Widget _buildDesktopLayout(
      BarangayModel barangay,
      BarangayDataProvider provider,
      ThemeData theme,
      double? yieldValue,
      double? yieldPercentage,
      double totalYield,
      int totalFarms,
      List<MapEntry<String, double>> sortedProducts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (provider.selectedProduct.isNotEmpty) ...[
          _buildSelectedProductSection(
              barangay, provider, theme, yieldValue, yieldPercentage, false),
          const SizedBox(height: 16),
        ],

        // Two-column layout for general information
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column - Basic Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    icon: Icons.landscape,
                    label: 'Total Area',
                    value: '${barangay.area.toStringAsFixed(2)} hectares',
                    theme: theme,
                    isMobile: false,
                  ),
                  const SizedBox(height: 10),
                  _buildInfoRow(
                    icon: Icons.home_work,
                    label: 'Total Farms',
                    value: '$totalFarms',
                    theme: theme,
                    isMobile: false,
                  ),
                  const SizedBox(height: 10),
                  _buildInfoRow(
                    icon: Icons.people,
                    label: 'Farmers',
                    value: barangay.farmer?.toStringAsFixed(0) ?? 'N/A',
                    theme: theme,
                    isMobile: false,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 20),

            // Right Column - Yield Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    icon: Icons.inventory,
                    label: 'Total Yield',
                    value: '${totalYield.toStringAsFixed(2)} kg',
                    theme: theme,
                    isMobile: false,
                  ),
                  const SizedBox(height: 10),
                  _buildInfoRow(
                    icon: Icons.category,
                    label: 'Products',
                    value: '${barangay.yieldData.length} types',
                    theme: theme,
                    isMobile: false,
                  ),
                  if (barangay.yieldData.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      icon: Icons.analytics,
                      label: 'Avg Yield/Product',
                      value:
                          '${(totalYield / barangay.yieldData.length).toStringAsFixed(1)} kg',
                      theme: theme,
                      isMobile: false,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),

        // Top Products Section - Full width below
        if (sortedProducts.isNotEmpty && totalYield > 0) ...[
          const SizedBox(height: 16),
          _buildTopProductsSection(sortedProducts, totalYield, theme, false),
        ],
      ],
    );
  }

// Selected Product Section
  static Widget _buildSelectedProductSection(
      BarangayModel barangay,
      BarangayDataProvider provider,
      ThemeData theme,
      double? yieldValue,
      double? yieldPercentage,
      bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 10 : 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.agriculture,
                size: isMobile ? 14 : 16,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: isMobile ? 4 : 6),
              Expanded(
                child: Text(
                  provider.selectedProduct,
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 6 : 8),

          // Two-column layout for yield data on desktop
          if (!isMobile)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Yield:',
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                      Text(
                        '${yieldValue?.toStringAsFixed(2) ?? 'N/A'} kg',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (yieldPercentage != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Percentage:',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                        Text(
                          '${yieldPercentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Yield:',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${yieldValue?.toStringAsFixed(2) ?? 'N/A'} kg',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (yieldPercentage != null) ...[
                  SizedBox(height: 3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Percentage:',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${yieldPercentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

// Top Products Section
  static Widget _buildTopProductsSection(
      List<MapEntry<String, double>> sortedProducts,
      double totalYield,
      ThemeData theme,
      bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 10 : 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.stars,
                size: isMobile ? 14 : 16,
                color: Colors.amber[700],
              ),
              SizedBox(width: isMobile ? 4 : 6),
              Text(
                'Top Products by Yield',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 6 : 8),

          // Two-column layout for top products on desktop
          if (!isMobile && sortedProducts.length > 5)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: sortedProducts
                        .take(5)
                        .map((entry) =>
                            _buildProductRow(entry, totalYield, theme, false))
                        .toList(),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: sortedProducts
                        .skip(5)
                        .take(5)
                        .map((entry) =>
                            _buildProductRow(entry, totalYield, theme, false))
                        .toList(),
                  ),
                ),
              ],
            )
          else
            Column(
              children: sortedProducts
                  .take(isMobile ? 3 : 10) // Show more on desktop
                  .map((entry) =>
                      _buildProductRow(entry, totalYield, theme, isMobile))
                  .toList(),
            ),
        ],
      ),
    );
  }

// Product row helper
  static Widget _buildProductRow(MapEntry<String, double> entry,
      double totalYield, ThemeData theme, bool isMobile) {
    final percentage = totalYield > 0 ? (entry.value / totalYield * 100) : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: isMobile ? 4 : 6,
            height: isMobile ? 4 : 6,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: isMobile ? 6 : 8),
          Expanded(
            child: Text(
              entry.key,
              style: TextStyle(
                fontSize: isMobile ? 11 : 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: isMobile ? 6 : 8),
          Text(
            '${entry.value.toStringAsFixed(1)} kg',
            style: TextStyle(
              fontSize: isMobile ? 10 : 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: isMobile ? 2 : 4),
          Text(
            '(${percentage.toStringAsFixed(1)}%)',
            style: TextStyle(
              fontSize: isMobile ? 9 : 10,
            ),
          ),
        ],
      ),
    );
  }

// Updated helper method to accept isMobile parameter
  static Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
    bool isMobile = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: isMobile ? 14 : 16,
          color: theme.colorScheme.primary.withOpacity(0.8),
        ),
        SizedBox(width: isMobile ? 6 : 8),
        Expanded(
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: isMobile ? 12 : 13,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isMobile ? 12 : 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  static Widget buildBarangayList(
      BarangayDataProvider provider, BuildContext context) {
    final theme = Theme.of(context);
    final ScrollController scrollController = ScrollController();

    // Use the provider's filtered and sorted list
    final filteredBarangays = provider.sortedBarangays;

    return Container(
      width: 200,
      height: 400,
      constraints: const BoxConstraints(
        maxWidth: 250,
        maxHeight: 600,
        minHeight: 200,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Barangay List',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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
                child: filteredBarangays.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            provider.selectedProduct.isNotEmpty
                                ? 'No yield data for ${provider.selectedProduct}'
                                : 'No barangay data available',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: EdgeInsets.zero,
                        itemCount: filteredBarangays.length,
                        itemBuilder: (context, index) {
                          final barangay = filteredBarangays[index];
                          final yieldValue = provider.selectedProduct.isNotEmpty
                              ? barangay.yieldData[provider.selectedProduct] ??
                                  0
                              : null;

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
                            subtitle: provider.selectedProduct.isNotEmpty &&
                                    yieldValue != null
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${yieldValue.toStringAsFixed(2)} kg',
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurface
                                              .withOpacity(0.7),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (barangay.area > 0)
                                        Text(
                                          '${(yieldValue / barangay.area).toStringAsFixed(2)} kg/ha',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: theme.colorScheme.onSurface
                                                .withOpacity(0.6),
                                            fontSize: 10,
                                          ),
                                        ),
                                    ],
                                  )
                                : null,
                            onTap: () {
                              // You can add tap functionality here if needed
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
}

// Separate stateful widget for the legend to maintain state
class _LegendWidget extends StatefulWidget {
  final BarangayDataProvider provider;

  const _LegendWidget({required this.provider});

  @override
  State<_LegendWidget> createState() => _LegendWidgetState();
}

class _LegendWidgetState extends State<_LegendWidget> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final yields = widget.provider.data
        .map((b) => b.yieldData[widget.provider.selectedProduct] ?? 0)
        .toList();
    final maxYield =
        yields.isNotEmpty ? yields.reduce((a, b) => a > b ? a : b) : 1;
    final minYield =
        yields.isNotEmpty ? yields.reduce((a, b) => a < b ? a : b) : 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.provider.selectedProduct} Yield (kg)',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    _isVisible = !_isVisible;
                  });
                },
                child: Icon(
                  _isVisible ? Icons.visibility_off : Icons.visibility,
                  size: 18,
                  color: theme.iconTheme.color,
                ),
              ),
            ],
          ),
          if (_isVisible) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                _buildLegendItem(
                  Colors.red[700]!,
                  'High (${maxYield.toStringAsFixed(1)})',
                  context,
                ),
                const SizedBox(width: 8),
                _buildLegendItem(
                  const Color.fromARGB(255, 255, 98, 0),
                  'Medium (${(maxYield * 0.66).toStringAsFixed(1)})',
                  context,
                ),
                const SizedBox(width: 8),
                _buildLegendItem(
                  const Color.fromARGB(255, 245, 192, 112),
                  'Low (${minYield.toStringAsFixed(1)})',
                  context,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text, BuildContext context) {
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
}
