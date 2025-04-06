import 'package:flutter/material.dart';
import 'package:flareline/pages/layout.dart';
import 'package:flareline/pages/products/profile_widgets/product_header.dart';
import 'package:flareline/pages/products/profile_widgets/key_details_card.dart';
import 'package:flareline/pages/products/profile_widgets/farms_table.dart';
import 'package:flareline/pages/products/profile_widgets/yield_history.dart';

class ProductProfile extends LayoutWidget {
  final Map<String, dynamic> product;

  const ProductProfile({super.key, required this.product});

  @override
  String breakTabTitle(BuildContext context) {
    return 'Product Profile';
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductHeader(product: product),
            const SizedBox(height: 24),
            KeyDetailsCard(product: product),
            const SizedBox(height: 16),
            FarmsTable(farms: dummyFarms),
            const SizedBox(height: 16),
            YieldHistory(
              yearlyYield: product['yearlyYield'] as List<dynamic>? ?? [],
              monthlyYield: product['monthlyYield'] as List<dynamic>? ?? [],
            ),
          ],
        ),
      ),
    );
  }
}

final List<Map<String, dynamic>> dummyFarms = [
  {
    'name': 'Mountain View Orchards',
    'location': 'Colorado, USA',
    'area': 210,
    'yield': 7800,
    'status': 'Active',
  },
  {
    'name': 'Riverbend Farm',
    'location': 'Oregon, USA',
    'area': 65,
    'yield': 2400,
    'status': 'active',
  },
  {
    'name': 'Golden Harvest',
    'location': 'Iowa, USA',
    'area': 350,
    'yield': 12500,
    'status': 'Active',
  },
  {
    'name': 'Old Mill Farm',
    'location': 'Vermont, USA',
    'area': 42,
    'yield': 1500,
    'status': 'Inactive',
  },
  {
    'name': 'Prairie Winds',
    'location': 'Nebraska, USA',
    'area': 180,
    'yield': 6700,
    'status': 'Active',
  },
  {
    'name': 'Blue Sky Farms',
    'location': 'Washington, USA',
    'area': 95,
    'yield': 3800,
    'status': 'active',
  },
];
