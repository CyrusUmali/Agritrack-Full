import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flareline/pages/products/add_product_modal.dart';
import 'package:flareline/pages/products/product/product_bloc.dart';
import 'package:flareline/core/theme/global_colors.dart';

import '../products_page.dart';

class ProductFilterWidget extends StatelessWidget {
  const ProductFilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (query) {
                context.read<ProductBloc>().add(SearchProducts(query));
              },
            ),
          ),
          const VerticalDivider(thickness: 1, indent: 8, endIndent: 8),
          BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              // Get the current filter from the bloc
              final sectorFilter = context.read<ProductBloc>().sectorFilter;
              return DropdownButton<String>(
                value: sectorFilter, // Use the current filter from bloc
                underline: Container(), // Remove default underline
                icon: const Icon(Icons.arrow_drop_down, size: 24),
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
                items: const [
                  DropdownMenuItem(value: "All", child: Text("All Sectors")),
                  DropdownMenuItem(value: "Rice", child: Text("Rice")),
                  DropdownMenuItem(
                      value: "Livestock", child: Text("Livestock")),
                  DropdownMenuItem(value: "Fishery", child: Text("Fishery")),
                  DropdownMenuItem(value: "Corn", child: Text("Corn")),
                  DropdownMenuItem(value: "HVC", child: Text("HVC")),
                  DropdownMenuItem(value: "Organic", child: Text("Organic")),
                  DropdownMenuItem(value: "Other", child: Text("Other")),
                ],
                onChanged: (value) {
                  print('Selected sector: $value');
                  context.read<ProductBloc>().add(FilterProducts(value!));
                },
              );
            },
          ),
          const VerticalDivider(thickness: 1, indent: 8, endIndent: 8),
          IconButton(
            icon: const Icon(Icons.add),
            color: GlobalColors.normal,
            onPressed: () {
              AddProductModal.show(context);

              // AddProductModal.show(Navigator.of(context).context);
            },
            tooltip: 'Add Product',
          ),
        ],
      ),
    );
  }
}
