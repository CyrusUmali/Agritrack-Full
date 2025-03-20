import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flutter/material.dart';
import 'package:flareline/pages/layout.dart';

class ProductProfile extends LayoutWidget {
  final Map<String, dynamic> product;

  const ProductProfile({super.key, required this.product});

  @override
  String breakTabTitle(BuildContext context) {
    return 'Product Profile';
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return CommonCard(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          Stack(
            children: [
              SizedBox(
                height: 280,
                child: Image.asset(
                  'assets/cover/cover-01.png',
                  height: 280,
                  width: double.maxFinite,
                  fit: BoxFit.cover,
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  margin: const EdgeInsets.all(10),
                  color: Colors.blueAccent,
                  child: TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.camera, color: Colors.white),
                    label: const Text('Edit',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 72,
            backgroundColor: Colors.greenAccent,
            child:
                Image.asset('assets/product/product-01.png'), // Product image
          ),
          const SizedBox(height: 10),
          Text(
            product['productName'] ?? 'Unknown Product',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ProductDetailsCard(product: product),
          ProductSpecificationsCard(product: product),
          ProductPricingCard(product: product),
        ],
      ),
    );
  }
}

class ProductDetailsCard extends StatelessWidget {
  final Map<String, dynamic> product;
  const ProductDetailsCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildDetailField(
              'Product Name', product['productName'] ?? 'Not specified'),
          _buildDetailField('Type', product['type'] ?? 'Not specified'),
          _buildDetailField(
              'Description', product['description'] ?? 'Not specified'),
          _buildDetailField('Category', product['category'] ?? 'Not specified'),
          _buildDetailField(
              'Manufacturer', product['manufacturer'] ?? 'Not specified'),
        ],
      ),
    );
  }

  Widget _buildDetailField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}

class ProductSpecificationsCard extends StatelessWidget {
  final Map<String, dynamic> product;
  const ProductSpecificationsCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Specifications',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildDetailField('Weight', '${product['weight']} kg'),
          _buildDetailField(
              'Dimensions', product['dimensions'] ?? 'Not specified'),
          _buildDetailField('Material', product['material'] ?? 'Not specified'),
          _buildDetailField('Color', product['color'] ?? 'Not specified'),
        ],
      ),
    );
  }

  Widget _buildDetailField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}

class ProductPricingCard extends StatelessWidget {
  final Map<String, dynamic> product;
  const ProductPricingCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pricing & Availability',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildDetailField('Price', product['price'] ?? 'Not specified'),
          _buildDetailField(
              'Quantity Available', '${product['quantity']} units'),
          _buildDetailField('Discount', '${product['discount']}%'),
          _buildDetailField(
              'Stock Status', product['stockStatus'] ?? 'Not specified'),
        ],
      ),
    );
  }

  Widget _buildDetailField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
