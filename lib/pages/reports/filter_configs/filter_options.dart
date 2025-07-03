import 'package:flareline/pages/farmers/farmer/farmer_bloc.dart';
import 'package:flareline/pages/farmers/farmer_data.dart';
import 'package:flareline/pages/farms/farm_bloc/farm_bloc.dart';
import 'package:flareline/pages/products/product/product_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FilterOptions {
  static const Map<String, String> reportTypes = {
    'farmers': 'Farmers List',
    'farmer': 'Farmer Record',
    // 'farms': 'Farms List',
    'products': 'Products & Yield',
    'barangay': 'Barangay Data',
    'sectors': 'Sector Performance',
  };

  //  static List<String> get farmerNames => FarmerData.farmers
  //     .map((farmer) => farmer['farmerName'] as String)
  //     .toList();

  // Replace the const list with a getter
  static List<String> get products {
    // Note: This approach requires context which isn't available in static methods
    // So we'll need to use a different approach (see Option 2 below)
    throw FlutterError('Use getProducts(context) instead of products');
  }

  // Add this new method
  static List<String> getProducts(BuildContext context) {
    final productState = context.read<ProductBloc>().state;

    if (productState is ProductsLoaded) {
      return productState.products
          .map((product) => '${product.id}: ${product.name}')
          .toList();
    }

    // Fallback to empty list if products aren't loaded yet
    return ['error'];
  }

  static List<String> getFarmers(BuildContext context) {
    final farmersState = context.read<FarmerBloc>().state;

    if (farmersState is FarmersLoaded) {
      return farmersState
          .farmers // Note: changed from 'farmer' to 'farmers' (assuming this is a list)
          .map((farmer) => '${farmer.id}: ${farmer.name}')
          .toList();
    }

    // Fallback to empty list if products aren't loaded yet
    return ['error'];
  }

  static List<String> get barangays => FarmerData.barangays;
  // static List<Map<String, dynamic>> get farmers => FarmerData.farmers;

  static const List<String> sectors = [
    '1:Rice',
    '2:Corn',
    '3:HVC',
    '4:Livestock',
    '5:Fishery',
    '6:Organic'
  ];

  static const List<String> viewBy = [
    'Individual entries',
    'Monthly',
    'Yearly',
  ];

  static List<String> getFarms(BuildContext context) {
    final farmsState = context.read<FarmBloc>().state;

    if (farmsState is FarmsLoaded) {
      return farmsState
          .farms // Note: changed from 'farmer' to 'farmers' (assuming this is a list)
          .map((farm) => '${farm.id}: ${farm.name}')
          .toList();
    }

    // Fallback to empty list if products aren't loaded yet
    return ['error'];
  }

  // static const List<String> farms = ['Farm A', 'Farm B', 'Farm C', 'Farm D'];
}
