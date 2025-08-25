import 'package:flareline/core/models/yield_model.dart';
import 'package:flareline/pages/dashboard/map/map_chart_ui.dart';
import 'package:flareline/pages/products/product/product_bloc.dart';
import 'package:flareline/pages/yields/yield_bloc/yield_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:provider/provider.dart';
import 'barangay_data_provider.dart'; 

class MapChartWidget extends StatefulWidget {
  final int selectedYear;
  final String? selectedProduct;
  
  const MapChartWidget({
    super.key, 
    required this.selectedYear, 
    this.selectedProduct,
  });

  @override
  State<MapChartWidget> createState() => _MapChartWidgetState();
}

class _MapChartWidgetState extends State<MapChartWidget> {
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    print('selectedProduct: ${widget.selectedProduct}');
    _isMounted = true;
    _loadData();
  }

  void _loadData() {
    // Load both yields and products when initializing
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

    return MultiBlocListener(
      listeners: [
        BlocListener<ProductBloc, ProductState>(
          listener: (context, state) {
            if (state is ProductsError) {
              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(content: Text(state.message)),
              // );
            }
          },
        ),
        BlocListener<YieldBloc, YieldState>(
          listener: (context, state) {
            if (state is YieldsError) {
              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(content: Text(state.message)),
              // );
            }
          },
        ),
      ],
      child: BlocBuilder<ProductBloc, ProductState>(
        builder: (productContext, productState) {
          // Handle product loading states first
          if (productState is ProductsLoading) {
            return MapChartUIComponents.buildLoadingState();
          } else if (productState is ProductsError) {
            return MapChartUIComponents.buildErrorState(
              context, 
              productState.message, 
              _loadData,
            );
          }

          // Get products list
          List<String> products = [];
          if (widget.selectedProduct != null) {
            products = [widget.selectedProduct!];
          } else if (productState is ProductsLoaded) {
            products = productState.products.map((p) => p.name).toList();
          }

          return BlocBuilder<YieldBloc, YieldState>(
            builder: (yieldContext, yieldState) {
              // Handle yield loading states
              if (yieldState is YieldsLoading) {
                return MapChartUIComponents.buildLoadingState();
              } else if (yieldState is YieldsError) {
                return MapChartUIComponents.buildErrorState(
                  context, 
                  yieldState.message, 
                  _loadData,
                );
              }

              // Get yields list
              List<Yield> yields = [];
              if (yieldState is YieldsLoaded) {
                yields = yieldState.yields;
              }

              // Only build the map when we have both products and yields data
              return _buildMapsLayout(context, products, yields);
            },
          );
        },
      ),
    );
  }

  Widget _buildMapsLayout(
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
                // color: theme.cardColor,
                color: Theme.of(context).cardTheme.color,
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
                    selectedYear: widget.selectedYear,
                  ),
                  key: ValueKey('${widget.selectedYear}_${widget.selectedProduct}'),
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
                              MapChartUIComponents.buildProductSelector(
                                  provider, context),
                              const SizedBox(height: 16),
                              Expanded(
                                flex: 3,
                                child: MapChartUIComponents.buildMap(
                                    provider, zoomPanBehavior, context),
                              ),
                              const SizedBox(height: 16),
                              MapChartUIComponents.buildBarangayList(
                                  provider, context),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            MapChartUIComponents.buildProductSelector(
                                provider, context),
                            const SizedBox(height: 16),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: MapChartUIComponents.buildMap(
                                        provider, zoomPanBehavior, context),
                                  ),
                                  const SizedBox(width: 16),
                                  MapChartUIComponents.buildBarangayList(
                                      provider, context),
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
}