import 'package:flareline/core/models/yield_model.dart';
import 'package:flareline/pages/products/product/product_bloc.dart';
import 'package:flareline/pages/yields/yield_bloc/yield_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:provider/provider.dart';
import 'barangay_data_provider.dart';

class MapChartWidget extends StatefulWidget {
  final int selectedYear;
  const MapChartWidget(
      {super.key, required this.selectedYear}); // Update constructor

  @override
  State<MapChartWidget> createState() => _MapChartWidgetState();
}

class _MapChartWidgetState extends State<MapChartWidget> {
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    // Load data when widget initializes
    _loadData();
  }

  void _loadData() {
    context.read<YieldBloc>().add(LoadYields());
    context.read<ProductBloc>().add(LoadProducts());
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<ProductBloc, ProductState>(
      builder: (productContext, productState) {
        List<String> products = [];

        // print('productState');
        // print(productState);

        if (productState is ProductsLoaded) {
//  yields = yieldState.yields;

          print('products Data Loaded:');
          // for (var products in productState.products) {
          //   print(products.toJson());
          // }

          products = productState.products.map((p) => p.name).toList();
        } else if (productState is ProductsError) {
          // Show error and retry button for products
          return _buildErrorState(productState.message, _loadData);
        }

        return BlocBuilder<YieldBloc, YieldState>(
          builder: (yieldContext, yieldState) {
            List<Yield> yields = [];

            if (yieldState is YieldsLoaded) {
              yields = yieldState.yields;
            } else if (yieldState is YieldsError) {
              // Show error and retry button for yields
              return _buildErrorState(yieldState.message, _loadData);
            } else if (yieldState is YieldsLoading) {
              // Show loading state
              return _buildLoadingState();
            }

            return _maps(context, products, yields);
          },
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(String errorMessage, VoidCallback onRetry) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text('Error', style: TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _maps(
      BuildContext context, List<String> products, List<Yield> yields) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Barangay Map',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.normal,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.refresh,
                  color: theme.iconTheme.color,
                ),
                onPressed: _loadData,
                tooltip: 'Reload Data',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.dividerColor,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: ChangeNotifierProvider(
                  create: (context) => BarangayDataProvider(
                    initialProducts: products,
                    yields: yields,
                    selectedYear: widget.selectedYear, // Pass the selected year
                  ),
                  key: ValueKey(widget.selectedYear),
                  builder: (ctx, child) {
                    final provider = ctx.watch<BarangayDataProvider>();

                    if (provider.isLoading) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                      );
                    }

                    final MapZoomPanBehavior zoomPanBehavior =
                        MapZoomPanBehavior(
                      enableDoubleTapZooming: true,
                      enableMouseWheelZooming: true,
                      enablePinching: true,
                      zoomLevel: 1,
                      minZoomLevel: 1,
                      maxZoomLevel: 15,
                      enablePanning: true,
                    );

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 800) {
                          return Column(
                            children: [
                              _buildProductSelector(provider, context),
                              const SizedBox(height: 16),
                              Expanded(
                                flex: 3,
                                child: _buildMap(provider, zoomPanBehavior),
                              ),
                              const SizedBox(height: 16),
                              _buildBarangayList(provider, context),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            _buildProductSelector(provider, context),
                            const SizedBox(height: 16),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: _buildMap(provider, zoomPanBehavior),
                                  ),
                                  const SizedBox(width: 16),
                                  _buildBarangayList(provider, context),
                                ],
                              ),
                            ),
                          ],
                        );
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

  Widget _buildProductSelector(
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
              fieldViewBuilder: (context, textEditingController, focusNode,
                  onFieldSubmitted) {
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
              initialValue: provider.selectedProduct.isNotEmpty
                  ? TextEditingValue(text: provider.selectedProduct)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTooltipRow({
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

  Widget _buildMap(
      BarangayDataProvider provider, MapZoomPanBehavior zoomPanBehavior) {
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
                      color: barangay.color.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
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
                            Text(
                              barangay.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (provider.selectedProduct.isNotEmpty) ...[
                          _buildTooltipRow(
                            icon: Icons.agriculture,
                            label: '${provider.selectedProduct} Yield',
                            value:
                                '${barangay.yieldData[provider.selectedProduct]?.toStringAsFixed(1) ?? 'N/A'} tons',
                            textColor: textColor,
                          ),
                          if (yieldPercentage != null)
                            _buildTooltipRow(
                              icon: Icons.trending_up,
                              label: 'Yield Percentage',
                              value: '${yieldPercentage.toStringAsFixed(1)}%',
                              textColor: textColor,
                            ),
                          const SizedBox(height: 4),
                        ],
                        _buildTooltipRow(
                          icon: Icons.landscape,
                          label: 'Area',
                          value: '${barangay.area.toStringAsFixed(2)} km²',
                          textColor: textColor,
                        ),
                        _buildTooltipRow(
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
                tooltipSettings: const MapTooltipSettings(
                  hideDelay: 0,
                ),
                strokeColor: Colors.white,
                strokeWidth: 0.8,
                dataLabelSettings: const MapDataLabelSettings(
                  textStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          if (provider.selectedProduct.isNotEmpty)
            Positioned(
              bottom: 16,
              left: 16,
              child: _buildLegend(provider),
            ),
        ],
      ),
    );
  }

  Widget _buildLegend(BarangayDataProvider provider) {
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
            '${provider.selectedProduct} Yield (tons)',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildLegendItem(
                Colors.red[700]!,
                'High (${maxYield.toStringAsFixed(1)})',
              ),
              const SizedBox(width: 8),
              _buildLegendItem(
                Colors.orange[400]!,
                'Medium (${(maxYield * 0.66).toStringAsFixed(1)})',
              ),
              const SizedBox(width: 8),
              _buildLegendItem(
                Colors.green[400]!,
                'Low (${minYield.toStringAsFixed(1)})',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
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

  Widget _buildBarangayList(
      BarangayDataProvider provider, BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 200,
      constraints: const BoxConstraints(maxWidth: 250),
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
                  thumbColor: MaterialStateProperty.all(
                    theme.colorScheme.outline.withOpacity(0.5),
                  ),
                  trackColor: MaterialStateProperty.all(
                    theme.colorScheme.outline.withOpacity(0.1),
                  ),
                ),
              ),
              child: Scrollbar(
                controller: PrimaryScrollController.of(context),
                thumbVisibility: true,
                child: ListView.builder(
                  primary: true,
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
                              '${barangay.yieldData[provider.selectedProduct]?.toStringAsFixed(2) ?? 'N/A'} tons',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.7),
                              ),
                            )
                          : null,
                      onTap: () {},
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
