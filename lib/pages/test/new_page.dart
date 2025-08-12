import 'package:flareline/pages/farmers/farmer/farmer_bloc.dart';
import 'package:flareline/pages/products/product/product_bloc.dart';
import 'package:flareline/pages/test/map_widget/farm_service.dart';
import 'package:flareline/repositories/farmer_repository.dart';
import 'package:flareline/repositories/product_repository.dart';
import 'package:flutter/material.dart';
import 'package:flareline/pages/layout.dart';
import 'package:flareline/pages/test/map_widget/map_widget.dart';
import 'package:flareline/services/api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class NewPage extends LayoutWidget {
  const NewPage({super.key, required this.routeObserver});

  final RouteObserver<PageRoute> routeObserver;

  @override
  bool get showTitle => false;

  @override
  String breakTabTitle(BuildContext context) {
    return "";
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => ApiService()),
        RepositoryProvider(
            create: (_) => FarmService(RepositoryProvider.of<ApiService>(_))),
        RepositoryProvider(
            create: (_) => ProductRepository(
                apiService: RepositoryProvider.of<ApiService>(_))),
        RepositoryProvider(
            create: (_) => FarmerRepository(
                apiService: RepositoryProvider.of<ApiService>(_))),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ProductBloc(
              productRepository:
                  RepositoryProvider.of<ProductRepository>(context),
            )..add(LoadProducts()),
          ),
          BlocProvider(
            create: (context) => FarmerBloc(
              farmerRepository:
                  RepositoryProvider.of<FarmerRepository>(context),
            )..add(LoadFarmers()),
          ),
        ],
        child: Builder(
          builder: (context) {
            final farmService = RepositoryProvider.of<FarmService>(context);

            return BlocBuilder<ProductBloc, ProductState>(
              builder: (context, productState) {
                return BlocBuilder<FarmerBloc, FarmerState>(
                  builder: (context, farmerState) {
// Solution 2: Use SizedBox with full height and Center
                    if (productState is ProductsLoading &&
                        farmerState is FarmersLoading) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height,
                        child: Center(
                          child: LoadingAnimationWidget.inkDrop(
                            color: Colors.blue,
                            size: 50,
                          ),
                        ),
                      );
                    }

                    // Handle error cases
                    if (productState is ProductsError ||
                        farmerState is FarmersError) {
                      String errorMessage = '';

                      if (productState is ProductsError &&
                          farmerState is FarmersError) {
                        errorMessage =
                            'Failed to load both products and farmers';
                      } else if (productState is ProductsError) {
                        errorMessage =
                            'Failed to load products: ${productState.message}';
                      } else if (farmerState is FarmersError) {
                        errorMessage =
                            'Failed to load farmers: ${farmerState.message}';
                      }

                      return 
                      
                       SizedBox(
    height: MediaQuery.of(context).size.height,
    child: 
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 50,
                            ),
                            const SizedBox(height: 16),
                            Text(errorMessage,
                                style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 16),
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              color: Colors.grey,
                              iconSize: 40,
                              onPressed: () {
                                context.read<ProductBloc>().add(LoadProducts());
                                context.read<FarmerBloc>().add(LoadFarmers());
                              },
                            ),
                          ],
                        ),
                      )
                  
                  
                       );
                  
                  
                    }

                    // Both data loaded successfully
                    if (productState is ProductsLoaded &&
                        farmerState is FarmersLoaded) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          return MapWidget(
                            routeObserver: routeObserver,
                            farmService: farmService,
                            products: productState.products,
                            farmers: farmerState.farmers,
                          );
                        },
                      );
                    }

                    // If we have partial data, show what we have
                    if (productState is ProductsLoaded ||
                        farmerState is FarmersLoaded) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          return MapWidget(
                            routeObserver: routeObserver,
                            farmService: farmService,
                            products: productState is ProductsLoaded
                                ? productState.products
                                : [],
                            farmers: farmerState is FarmersLoaded
                                ? farmerState.farmers
                                : [],
                          );
                        },
                      );
                    }

                    // Fallback - should theoretically never reach here
                    return const Center(child: Text('Unexpected state'));
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  EdgeInsetsGeometry? get customPadding => const EdgeInsets.only(top: 0);

  @override
  PreferredSizeWidget? appBarWidget(BuildContext context) {
    return AppBar(
      title: Text(breakTabTitle(context)),
      centerTitle: true,
      elevation: 0,
    );
  }

  @override
  Widget loadingWidget(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.inkDrop(
        color: Colors.blue,
        size: 50,
      ),
    );
  }
}
