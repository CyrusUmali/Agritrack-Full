import 'package:flareline/pages/products/products_table.dart';
import 'package:flutter/material.dart';
import 'package:flareline/pages/layout.dart';

class ProductsPage extends LayoutWidget {
  const ProductsPage({super.key});

  @override
  String breakTabTitle(BuildContext context) {
    return 'Products';
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    // State to hold the selected year
    int selectedYear = DateTime.now().year;

    return Column(
      children: [
        const SizedBox(height: 16),
        const ProductsTable(),
      ],
    );
  }
}
