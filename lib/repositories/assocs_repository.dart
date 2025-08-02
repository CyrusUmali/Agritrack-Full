import 'package:dio/dio.dart';
import 'package:flareline/core/models/assocs_model.dart';
import 'package:flareline/services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AssociationRepository {
  final ApiService apiService;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AssociationRepository({required this.apiService});

  Future<Association> getAssociationById(int associationId) async {
    try {
      if (_firebaseAuth.currentUser == null) {
        throw Exception('User not authenticated');
      }

      final response =
          await apiService.get('/auth/associations/$associationId');

      if (response.data == null || response.data['association'] == null) {
        throw Exception('Invalid association data format');
      }

      return Association.fromJson(response.data['association']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Association not found');
      }
      throw Exception('API Error: ${e.response?.statusCode} - ${e.message}');
    } on FirebaseAuthException catch (e) {
      throw Exception('Authentication error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load association: $e');
    }
  }

  Future<Association> updateAssociation(Association association) async {
    try {
      if (_firebaseAuth.currentUser == null) {
        throw Exception('User not authenticated');
      }

      final response = await apiService.put(
        '/auth/associations/${association.id}',
        data: {
          'name': association.name,
          'description': association.description,
        },
      );

      if (response.data == null || response.data['association'] == null) {
        throw Exception('Invalid association data format');
      }

      return Association.fromJson(response.data['association']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Association not found');
      }
      throw Exception('API Error: ${e.response?.statusCode} - ${e.message}');
    } catch (e) {
      throw Exception('Failed to update association: $e');
    }
  }

  Future<List<Association>> fetchAssociations() async {
    try {
      // if (_firebaseAuth.currentUser == null) {
      //   throw Exception('User not authenticated');
      // }

      final response = await apiService.get('/auth/associations');

      if (response.data == null || response.data['associations'] == null) {
        throw Exception('Invalid associations data format');
      }

      final associationsData = response.data['associations'] as List;
      return associationsData
          .map((json) => Association.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception('API Error: ${e.response?.statusCode} - ${e.message}');
    } on FirebaseAuthException catch (e) {
      throw Exception('Authentication error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load associations: $e');
    }
  }

  Future<void> deleteAssociation(int associationId) async {
    try {
      if (_firebaseAuth.currentUser == null) {
        throw Exception('User not authenticated');
      }

      await apiService.delete('/auth/associations/$associationId');
    } on DioException catch (e) {
      throw Exception('API Error: ${e.response?.statusCode} - ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete association: $e');
    }
  }

  Future<Association> createAssociation({
    required String name,
    required String description,
  }) async {
    try {
      if (_firebaseAuth.currentUser == null) {
        throw Exception('User not authenticated');
      }

      final response = await apiService.post(
        '/auth/associations',
        data: {
          'name': name,
          'description': description,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
      );

      if (response.data == null || response.data['association'] == null) {
        throw Exception('Invalid association data format');
      }

      return Association.fromJson(response.data['association']);
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ??
          e.message ??
          'Failed to create association';
      throw Exception('API Error: $errorMessage');
    } catch (e) {
      throw Exception('Failed to create association: ${e.toString()}');
    }
  }
}
