import 'package:flareline/pages/dashboard/map/map_chart_widget.dart';
import 'package:flareline/core/models/farms_model.dart';
import 'package:flareline/core/models/product_model.dart';
import 'package:flareline/core/models/yield_model.dart';
import 'package:flareline/pages/yields/yield_bloc/yield_bloc.dart';
import 'package:flareline/pages/farms/farm_bloc/farm_bloc.dart';
import 'package:flareline/repositories/yield_repository.dart';
import 'package:flareline/repositories/farm_repository.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flareline_uikit/service/year_picker_provider.dart';
import 'package:flutter/material.dart';
import 'package:flareline/pages/layout.dart';
import 'package:flareline/pages/products/profile_widgets/product_header.dart';
import 'package:flareline/pages/products/profile_widgets/farms_table.dart';
import 'package:flareline/pages/products/profile_widgets/yield_history.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class ProductProfile extends LayoutWidget {
  final Product product;

  const ProductProfile({super.key, required this.product});

  @override
  String breakTabTitle(BuildContext context) {
    return 'Product Profile';
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => YieldBloc(
            yieldRepository: RepositoryProvider.of<YieldRepository>(context),
          )..add(LoadYieldsByProduct(product.id)),
        ),
        BlocProvider(
          create: (context) => FarmBloc(
            farmRepository: RepositoryProvider.of<FarmRepository>(context),
          )..add(GetFarmsByProduct(product.id)),
        ),
      ],
      child: _ProductProfileContent(product: product, isMobile: false),
    );
  }

  @override
  Widget contentMobileWidget(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => YieldBloc(
            yieldRepository: RepositoryProvider.of<YieldRepository>(context),
          )..add(LoadYieldsByProduct(product.id)),
        ),
        BlocProvider(
          create: (context) => FarmBloc(
            farmRepository: RepositoryProvider.of<FarmRepository>(context),
          )..add(GetFarmsByProduct(product.id)),
        ),
      ],
      child: _ProductProfileContent(product: product, isMobile: true),
    );
  }
}

class _ProductProfileContent extends StatefulWidget {
  final Product product;
  final bool isMobile;

  const _ProductProfileContent({required this.product, required this.isMobile});

  @override
  State<_ProductProfileContent> createState() => _ProductProfileContentState();
}

class _ProductProfileContentState extends State<_ProductProfileContent> {
  late Product _currentProduct;
  Map<String, dynamic> transformedYieldData = {
    'name': '',
    'yields': [],
  };
  List<Farm> _farms = [];
  int _selectedViewIndex = 0; // 0 for yield history, 1 for farms table, 2 for map

  @override
  void initState() {
    super.initState();
    _currentProduct = widget.product;

    print(widget.product.name);
    transformedYieldData['name'] = _currentProduct.name;
  }

  Map<String, dynamic> transformYields(List<Yield> yields) {
    // First filter out yields that don't have Accepted status
    final acceptedYields =
        yields.where((yield) => yield.status == 'Accepted').toList();

    // Group yields by year
    final yieldsByYear = <String, List<Yield>>{};

    for (final yield in acceptedYields) {
      final year = yield.harvestDate?.year.toString() ?? 'Unknown';
      yieldsByYear.putIfAbsent(year, () => []).add(yield);
    }

    // Transform to the required format
    final transformedYields = <Map<String, dynamic>>[];

    yieldsByYear.forEach((year, yearYields) {
      // Initialize monthly data with zeros (using num to handle both int and double)
      final monthlyData = List<num>.filled(12, 0);

      // Aggregate volumes by month (1-12)
      for (final yield in yearYields) {
        final month = yield.harvestDate?.month ?? 1;
        // Subtract 1 because list is 0-indexed
        monthlyData[month - 1] += yield.volume ?? 0;
      }

      transformedYields.add({
        'year': year,
        'monthly': monthlyData,
      });
    });

    return {
      'name': _currentProduct.name,
      'yields': transformedYields,
    };
  }

  Widget _buildViewToggle(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(
            context,
            label: 'Trends',
            isSelected: _selectedViewIndex == 0,
            onTap: () => setState(() => _selectedViewIndex = 0),
          ),
          _buildToggleButton(
            context,
            label: 'Farms',
            isSelected: _selectedViewIndex == 1,
            onTap: () => setState(() => _selectedViewIndex = 1),
          ),
          // Only show Map toggle on desktop
          if (!widget.isMobile)
            _buildToggleButton(
              context,
              label: 'Map',
              isSelected: _selectedViewIndex == 2,
              onTap: () => setState(() => _selectedViewIndex = 2),
            ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? colors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : colors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductHeader(
              item: _currentProduct,
              onProductUpdated: (updatedProduct) {
                setState(() {
                  _currentProduct = updatedProduct;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Toggle button
            _buildViewToggle(context),
            const SizedBox(height: 16),
            
            // Content based on selection
            if (_selectedViewIndex == 0) ...[
              BlocConsumer<YieldBloc, YieldState>(
                listener: (context, state) {
                  if (state is YieldsLoaded) {
                    setState(() {
                      transformedYieldData = transformYields(state.yields);
                    });
                  } else if (state is YieldsError) {
                    print('Error loading yields: ${state.message}');
                  }
                },
                builder: (context, state) {
                  if (state is YieldsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is YieldsLoaded) {
                    return YieldHistory( 
                      product: transformedYieldData, 
                      isMobile: widget.isMobile
                    );
                  } else if (state is YieldsError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }
                  return const SizedBox();
                },
              ),
            ] else if (_selectedViewIndex == 1) ...[
              BlocConsumer<FarmBloc, FarmState>(
                listener: (context, state) {
                  if (state is FarmsLoaded) {
                    setState(() {
                      _farms = state.farms.where((farm) => farm.volume != 0).toList();
                    });
                  }
                },
                builder: (context, state) { 
                  if (state is FarmsLoading) { 
                    return const Center(child: CircularProgressIndicator()); 
                  } else if (state is FarmsLoaded) {
                    return FarmsTable(farms: _farms);
                  } else if (state is FarmsError) {
                    return Center(
                      child: Text('Error loading farms: ${state.message}'));
                  }
                  return const SizedBox();
                },
              ),
            ] else if (_selectedViewIndex == 2 && !widget.isMobile) ...[
              // Map view - only show on desktop
              Consumer<YearPickerProvider>(
                builder: (context, yearProvider, child) {
                  return SizedBox(
                    height: 700, 
                    child: CommonCard( 
                      child: ConstrainedBox(
                        constraints: const BoxConstraints.expand(),
                        child: MapChartWidget(selectedYear: yearProvider.selectedYear ,selectedProduct:widget.product.name),
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}