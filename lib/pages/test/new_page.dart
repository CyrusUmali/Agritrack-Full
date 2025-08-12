import 'package:flareline/pages/farmers/farmer/farmer_bloc.dart';
import 'package:flareline/pages/products/product/product_bloc.dart';
import 'package:flareline/pages/test/map_widget/farm_service.dart';
import 'package:flutter/material.dart';
import 'package:flareline/pages/layout.dart';
import 'package:flareline/pages/test/map_widget/map_widget.dart';
import 'package:flareline/services/api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NewPage extends LayoutWidget {
  const NewPage({super.key, required this.routeObserver});

  final RouteObserver<PageRoute> routeObserver;

  @override
  String breakTabTitle(BuildContext context) {
    return "";
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    // Load data when the widget is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductBloc>().add(LoadProducts());
      context.read<FarmerBloc>().add(LoadFarmers());
    });

    final apiService = ApiService();
    final farmService = FarmService(apiService);

    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, productState) {
        return BlocBuilder<FarmerBloc, FarmerState>(
          builder: (context, farmerState) {
            // Show loading indicator if either state is still loading
            if (productState is ProductsLoading ||
                farmerState is FarmersLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Handle error cases
            if (productState is ProductsError || farmerState is FarmersError) {
              String errorMessage = '';

              if (productState is ProductsError &&
                  farmerState is FarmersError) {
                errorMessage = 'Failed to load both products and farmers';
              } else if (productState is ProductsError) {
                errorMessage =
                    'Failed to load products: ${productState.message}';
              } else if (farmerState is FarmersError) {
                errorMessage = 'Failed to load farmers: ${farmerState.message}';
              }

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(errorMessage,
                        style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Retry loading data
                        context.read<ProductBloc>().add(LoadProducts());
                        context.read<FarmerBloc>().add(LoadFarmers());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            // Both data loaded successfully
            if (productState is ProductsLoaded &&
                farmerState is FarmersLoaded) {
              return MapWidget(
                routeObserver: routeObserver,
                farmService: farmService,
                products: productState.products,
                farmers: farmerState.farmers,
              );
            }

            // Initial state - show loading indicator
            return const Center(child: CircularProgressIndicator());
          },
        );
      },
    );
  }

  @override
  EdgeInsetsGeometry? get customPadding => const EdgeInsets.only(top: 16);

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
    return const Center(child: CircularProgressIndicator());
  }
}
 