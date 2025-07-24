import 'package:flareline/pages/farmers/farmer/farmer_bloc.dart';
import 'package:flareline/pages/products/product/product_bloc.dart';
import 'package:flareline/pages/test/map_widget/farm_service.dart';
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
  bool get showTitle => false; // Add this line to hide the title

  @override
  String breakTabTitle(BuildContext context) {
    return "";
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    // Define the expected size of the MapWidget
    final Size mapWidgetSize = Size(
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.height -
            kToolbarHeight -
            16); // Adjust for app bar and padding

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
              return SizedBox(
                width: mapWidgetSize.width,
                height: mapWidgetSize.height,
                child: Center(
                  child: LoadingAnimationWidget.inkDrop(
                    color: Colors.blue,
                    size: 50,
                  ),
                ),
              );
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

              return SizedBox(
                width: mapWidgetSize.width,
                height: mapWidgetSize.height,
                child: Center(
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
                          // Retry loading data
                          context.read<ProductBloc>().add(LoadProducts());
                          context.read<FarmerBloc>().add(LoadFarmers());
                        },
                      ),
                    ],
                  ),
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
            return SizedBox(
              width: mapWidgetSize.width,
              height: mapWidgetSize.height,
              child: Center(
                child: LoadingAnimationWidget.inkDrop(
                  color: Colors.blue,
                  size: 50,
                ),
              ),
            );
          },
        );
      },
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
