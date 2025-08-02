import 'package:dio/dio.dart';
import 'package:flareline/core/models/yield_model.dart';
import 'package:flareline/services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class YieldRepository {
  final ApiService apiService;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  YieldRepository({required this.apiService});

  Future<Yield> getYieldById(int yieldId) async {
    try {
      if (_firebaseAuth.currentUser == null) {
        throw Exception('User not authenticated');
      }

      final response = await apiService.get('/yields/yields/$yieldId');

      if (response.data == null || response.data['yieldRecord'] == null) {
        throw Exception('Invalid yieldRecord data format');
      }

      return Yield.fromJson(response.data['yieldRecord']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Yield record not found');
      }
      throw Exception('API Error: ${e.response?.statusCode} - ${e.message}');
    } on FirebaseAuthException catch (e) {
      throw Exception('Authentication error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load yieldRecord: $e');
    }
  }

  Future<List<Yield>> getYieldByFarmId(int farmId) async {
    try {
      if (_firebaseAuth.currentUser == null) {
        throw Exception('User not authenticated');
      }

      final response = await apiService.get('/yields/yields/farm/$farmId');

      if (response.data == null || response.data['yields'] == null) {
        throw Exception('Invalid yield data format');
      }

      // final yieldData = response.data['yields'];
      // return Yield.fromJson(yieldData);

      final yieldsData = response.data['yields'] as List;

      return yieldsData.map((json) => Yield.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Yield record not found');
      }
      throw Exception('API Error: ${e.response?.statusCode} - ${e.message}');
    } on FirebaseAuthException catch (e) {
      throw Exception('Authentication error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load yield: $e');
    }
  }

  Future<List<Yield>> fetchYields() async {
    try {
      if (_firebaseAuth.currentUser == null) {
        throw Exception('User not authenticated');
      }

      final response = await apiService.get('/yields/yields');

      if (response.data == null || response.data['yields'] == null) {
        throw Exception('Invalid yields data format');
      }

      final yieldsData = response.data['yields'] as List;

      return yieldsData.map((json) => Yield.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('API Error: ${e.response?.statusCode} - ${e.message}');
    } on FirebaseAuthException catch (e) {
      throw Exception('Authentication error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load yields: $e');
    }
  }

  Future<Yield> updateYield(Yield yieldRecord) async {
    try {
      if (_firebaseAuth.currentUser == null) {
        throw Exception('User not authenticated');
      }

      final response = await apiService.put(
        '/yields/yields/${yieldRecord.id}',
        data: {
          'farmer_id': yieldRecord.farmerId,
          'product_id': yieldRecord.productId,
          'harvest_date': yieldRecord.harvestDate!.toIso8601String(),
          'status': yieldRecord.status,
          'farm_id': yieldRecord.farmId,
          'volume': yieldRecord.volume,
          'notes': yieldRecord.notes,
          'value': yieldRecord.value,
          'images': yieldRecord.images,
        },
      );

      if (response.data == null || response.data['yield'] == null) {
        throw Exception('Invalid yield data format');
      }

      return Yield.fromJson(response.data['yield']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Yield record not found');
      } else if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        throw Exception(errorData['message'] ?? 'Invalid request');
      }
      throw Exception('API Error: ${e.response?.statusCode} - ${e.message}');
    } catch (e) {
      throw Exception('Failed to update yield: $e');
    }
  }

  Future<List<Yield>> fetchYieldsByFarmer(int farmerId) async {
    try {
      if (_firebaseAuth.currentUser == null) {
        throw Exception('User not authenticated');
      }

      final response = await apiService.get('/yields/yields/$farmerId');

      if (response.data == null || response.data['yields'] == null) {
        throw Exception('Invalid yields data format');
      }

      final yieldsData = response.data['yields'] as List;

      return yieldsData.map((json) => Yield.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('API Error: ${e.response?.statusCode} - ${e.message}');
    } on FirebaseAuthException catch (e) {
      throw Exception('Authentication error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load farmer yields: $e');
    }
  }

  Future<List<Yield>> fetchYieldsByProduct(int productId) async {
    try {
      if (_firebaseAuth.currentUser == null) {
        throw Exception('User not authenticated');
      }

      // final response = await apiService.get('/products/$productId/yields');
      final response =
          await apiService.get('/yields/yields/product/$productId');

      if (response.data == null || response.data['yields'] == null) {
        throw Exception('Invalid yields data format');
      }

      final yieldsData = response.data['yields'] as List;

      return yieldsData.map((json) => Yield.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('API Error: ${e.response?.statusCode} - ${e.message}');
    } on FirebaseAuthException catch (e) {
      throw Exception('Authentication error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load product yields: $e');
    }
  }

  Future<Yield> addYield(Yield yieldRecord) async {
    try {
      if (_firebaseAuth.currentUser == null) {
        throw Exception('User not authenticated. Please sign in first.');
      }

      // Validate required fields
      if (yieldRecord.farmerId == null) {
        throw Exception('Farmer ID is required');
      }
      if (yieldRecord.productId == null) {
        throw Exception('Product ID is required');
      }
      if (yieldRecord.harvestDate == null) {
        throw Exception('Harvest date is required');
      }
      if (yieldRecord.volume == null) {
        throw Exception('Volume is required');
      }

      final response = await apiService.post(
        '/yields/yields',
        data: {
          'farmer_id': yieldRecord.farmerId,
          'product_id': yieldRecord.productId,
          'harvest_date': yieldRecord.harvestDate!.toIso8601String(),
          'farm_id': yieldRecord.farmId,
          'volume': yieldRecord.volume,
          'notes': yieldRecord.notes,
          'value': yieldRecord.value,
          'images': yieldRecord.images,
          'status': yieldRecord.status
        },
      );

      if (response.data == null || response.data['yield'] == null) {
        throw Exception('Invalid yield data format');
      }

      return Yield.fromJson(response.data['yield']);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final errorMessage = e.response?.data?['message'] ?? e.message;
      final requestUrl = e.requestOptions.uri;

      throw Exception('''
API Request Failed:
- URL: $requestUrl
- Status: $statusCode
- Error: $errorMessage
- Details: ${e.response?.data}
''');
    } catch (e) {
      throw Exception('''
Failed to add yieldRecord:
- Error Type: ${e.runtimeType}
- Error Details: $e
- Stack Trace: ${e is Error ? e.stackTrace : ''}
''');
    }
  }

  Future<void> deleteYield(int yieldId) async {
    try {
      if (_firebaseAuth.currentUser == null) {
        throw Exception('User not authenticated');
      }

      await apiService.delete('/yields/yields/$yieldId');
    } on DioException catch (e) {
      throw Exception('API Error: ${e.response?.statusCode} - ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete yieldRecord: $e');
    }
  }
}
