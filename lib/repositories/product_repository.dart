import 'package:dio/dio.dart';
import 'package:flareline/core/models/product_model.dart';
import 'package:flareline/services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductRepository {
  final ApiService apiService;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  ProductRepository({required this.apiService});

  Future<List<Product>> fetchProducts() async {
    try {
      if (_firebaseAuth.currentUser == null) {
        throw Exception('User not authenticated');
      }

      final response = await apiService.get('/auth/products');

      if (response.data == null || response.data['products'] == null) {
        throw Exception('Invalid products data format');
      }

      final productsData = response.data['products'] as List;
      return productsData.map((json) => Product.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('API Error: ${e.response?.statusCode} - ${e.message}');
    } on FirebaseAuthException catch (e) {
      throw Exception('Authentication error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  Future<Product> addProduct(Product product) async {
    try {
      if (_firebaseAuth.currentUser == null) {
        throw Exception('User not authenticated');
      }

      final response = await apiService.post(
        '/auth/products',
        data: {
          'name': product.name,
          'description': product.description,
          'sector_id': _getSectorId(product.sector),
          'imageUrl': product.imageUrl,
        },
      );

      if (response.data == null || response.data['product'] == null) {
        throw Exception('Invalid product data format');
      }

      return Product.fromJson(response.data['product']);
    } on DioException catch (e) {
      throw Exception('API Error: ${e.response?.statusCode} - ${e.message}');
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  Future<Product> updateProduct(Product product) async {
    try {
      if (_firebaseAuth.currentUser == null) {
        throw Exception('User not authenticated');
      }

      final response = await apiService.put(
        '/auth/products/${product.id}',
        data: {
          'name': product.name,
          'description': product.description,
          'sector_id': _getSectorId(product.sector),
          'imageUrl': product.imageUrl,
        },
      );

      if (response.data == null || response.data['product'] == null) {
        throw Exception('Invalid product data format');
      }

      return Product.fromJson(response.data['product']);
    } on DioException catch (e) {
      throw Exception('API Error: ${e.response?.statusCode} - ${e.message}');
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

// Helper method to map sector names to IDs
  int _getSectorId(String sectorName) {
    // Implement your mapping logic here
    // Example:
    const sectorMap = {
      'Fishery': 5,
      'Livestock': 4,
      'Organic': 6,
      'HVC': 3,
      'Corn': 2,
      'Rice': 1,
    };
    return sectorMap[sectorName] ?? 4; // Default to HVC if not found
  }

  Future<void> deleteProduct(int productId) async {
    try {
      if (_firebaseAuth.currentUser == null) {
        throw Exception('User not authenticated');
      }

      await apiService.delete('/auth/products/$productId');
    } on DioException catch (e) {
      throw Exception('API Error: ${e.response?.statusCode} - ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }
}
