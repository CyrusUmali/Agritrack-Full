import 'package:flareline/core/models/farms_model.dart';
import 'package:flareline/core/models/product_model.dart';
import 'package:flareline/core/models/yield_model.dart';
import 'package:flareline/pages/yields/yield_bloc/yield_bloc.dart';
import 'package:flareline/pages/farms/farm_bloc/farm_bloc.dart';
import 'package:flareline/repositories/yield_repository.dart';
import 'package:flareline/repositories/farm_repository.dart';
import 'package:flutter/material.dart';
import 'package:flareline/pages/layout.dart';
import 'package:flareline/pages/products/profile_widgets/product_header.dart';
import 'package:flareline/pages/products/profile_widgets/farms_table.dart';
import 'package:flareline/pages/products/profile_widgets/yield_history.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      child: _ProductProfileContent(product: product),
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
      child: _ProductProfileContent(product: product),
    );
  }
}

class _ProductProfileContent extends StatefulWidget {
  final Product product;

  const _ProductProfileContent({required this.product});

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

  @override
  void initState() {
    super.initState();
    _currentProduct = widget.product;
    transformedYieldData['name'] = _currentProduct.name;
    // print('Product ID: ${_currentProduct.id}');
  }

  Map<String, dynamic> transformYields(List<Yield> yields) {
    // Group yields by year
    final yieldsByYear = <String, List<Yield>>{};

    for (final yield in yields) {
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
                // print(updatedProduct);
              },
            ),
            const SizedBox(height: 16),
            BlocConsumer<YieldBloc, YieldState>(
              listener: (context, state) {
                if (state is YieldsLoaded) {
                  // print('Yield Data Loaded:');
                  // for (var yield in state.yields) {
                  //   print(yield.toJson());
                  // }
                  // Transform the data when it's loaded
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
                  return Column(
                    children: [
                      YieldHistory(
                          product: transformedYieldData, isMobile: false),
                      const SizedBox(height: 16),
                    ],
                  );
                } else if (state is YieldsError) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                return const SizedBox();
              },
            ),
            const SizedBox(height: 16),
            BlocConsumer<FarmBloc, FarmState>(
              listener: (context, state) {
                if (state is FarmsLoaded) {
                  print('Farms  Loaded:');
                  for (var farm in state.farms) {
                    print(farm.toJson());
                  }
                  // Transform the data when it's loaded

                  setState(() {
                    _farms = state.farms;
                  });
                }
              },
              builder: (context, state) {
                if (state is FarmsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is FarmsLoaded) {
                  return
                      // FarmsTable(farms: dummyFarms);
                      FarmsTable(farms: _farms);
                } else if (state is FarmsError) {
                  return Center(
                      child: Text('Error loading farms: ${state.message}'));
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }
}
