import 'package:flutter/material.dart';
import 'package:flareline/pages/products/profile_widgets/info_chip.dart';

class ProductHeader extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductHeader({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImage(context),
            const SizedBox(width: 16),
            _buildProductInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceVariant,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/product/product-01.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildProductInfo(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product['productName'] ?? 'Unknown Product',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            product['description'] ?? 'No description available',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              InfoChip(label: 'Category', value: product['category']),
              InfoChip(label: 'Sector', value: product['sector']),
              InfoChip(label: 'Market Value', value: product['marketValue']),
            ],
          ),
        ],
      ),
    );
  }
}
