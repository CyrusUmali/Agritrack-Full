import 'package:dio/dio.dart';
import 'package:flareline/core/models/farms_model.dart';
import 'package:flareline/services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FarmRepository {
  final ApiService apiService;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  FarmRepository({required this.apiService});

  Future<Farm> getFarmById(int farmId) async {
    try {
      if (_firebaseAuth.currentUser == null) {
        throw Exception('User not authenticated');
      }

      final response = await apiService.get('/auth/farms/$farmId');

      if (response.data == null || response.data['farm'] == null) {
        throw Exception('Invalid farm data format');
      }

      return Farm.fromJson(response.data['farm']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Farm not found');
      }
      throw Exception('API Error: ${e.response?.statusCode} - ${e.message}');
    } on FirebaseAuthException catch (e) {
      throw Exception('Authentication error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load farm: $e');
    }
  }

  Future<List<Farm>> getFarmsByProductId(int productId) async {
    try {
      if (_firebaseAuth.currentUser == null) {
        throw Exception('User not authenticated');
      }

      final response =
          await apiService.get('/auth/farms/by-product/$productId');

      if (response.data == null || response.data['farms'] == null) {
        throw Exception('Invalid farm data format');
      }

      // return Farm.fromJson(response.data['farm']);

      final farmsData = response.data['farms'] as List;

      return farmsData.map((json) => Farm.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Farm not found');
      }
      throw Exception('API Error: ${e.response?.statusCode} - ${e.message}');
    } on FirebaseAuthException catch (e) {
      throw Exception('Authentication error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load farm: $e');
    }
  }

  Future<Farm> updateFarm(Farm farm) async {
    try {
      if (_firebaseAuth.currentUser == null) {
        throw Exception('User not authenticated');
      }

      final response = await apiService.put(
        '/auth/farmsProfile/${farm.id}',
        data: {
          'name': farm.name,
          'owner': farm.owner,
          'description': farm.description,
          'barangay': farm.barangay,
          'farmId': farm.id,
          'sectorId': farm.sectorId,
          'farmerId': farm.farmerId,
          'products': farm.products,
          'hectare': farm.hectare?.toString(),
        },
      );

      if (response.data == null || response.data['farm'] == null) {
        throw Exception('Invalid farm data format');
      }

      return Farm.fromJson(response.data['farm']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Farm not found');
      }
      throw Exception('API Error: ${e.response?.statusCode} - ${e.message}');
    } catch (e) {
      throw Exception('Failed to update farm: $e');
    }
  }

  Future<List<Farm>> fetchFarms() async {
    try {
      if (_firebaseAuth.currentUser == null) {
        throw Exception('User not authenticated');
      }

      final response = await apiService.get('/auth/farms');

      if (response.data == null || response.data['farms'] == null) {
        throw Exception('Invalid farms data format');
      }

      final farmsData = response.data['farms'] as List;

      return farmsData.map((json) => Farm.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('API Error: ${e.response?.statusCode} - ${e.message}');
    } on FirebaseAuthException catch (e) {
      throw Exception('Authentication error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load farms: $e');
    }
  }

  Future<void> deleteFarm(int farmId) async {
    try {
      if (_firebaseAuth.currentUser == null) {
        throw Exception('User not authenticated');
      }

      await apiService.delete('/auth/farms/$farmId');
    } on DioException catch (e) {
      throw Exception('API Error: ${e.response?.statusCode} - ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete farm: $e');
    }
  }

  // Optional: Get farms by owner (farmer) ID
  Future<List<Farm>> getFarmsByOwnerId(int ownerId) async {
    try {
      if (_firebaseAuth.currentUser == null) {
        throw Exception('User not authenticated');
      }

      final response = await apiService.get('/auth/farms/owner/$ownerId');

      if (response.data == null || response.data['farms'] == null) {
        throw Exception('Invalid farms data format');
      }

      final farmsData = response.data['farms'] as List;

      return farmsData.map((json) => Farm.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('API Error: ${e.response?.statusCode} - ${e.message}');
    } catch (e) {
      throw Exception('Failed to load farms by owner: $e');
    }
  }
}
