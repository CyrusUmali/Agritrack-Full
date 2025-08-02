import 'package:dio/dio.dart';
import 'package:flareline/core/models/farmer_model.dart';
import 'package:flareline/services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FarmerRepository {
  final ApiService apiService;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  FarmerRepository({required this.apiService});

  Future<Farmer> getFarmerById(int farmerId) async {
    try {
      if (_firebaseAuth.currentUser == null) {
        throw Exception('User not authenticated');
      }

      final response = await apiService.get('/auth/farmers/$farmerId');

      if (response.data == null || response.data['farmer'] == null) {
        throw Exception('Invalid farmer data format');
      }

      return Farmer.fromJson(response.data['farmer']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Farmer not found');
      }
      throw Exception('API Error: ${e.response?.statusCode} - ${e.message}');
    } on FirebaseAuthException catch (e) {
      throw Exception('Authentication error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load farmer: $e');
    }
  }

  Future<Farmer> updateFarmer(Farmer farmer) async {
    try {
      if (_firebaseAuth.currentUser == null) {
        throw Exception('User not authenticated');
      }

      final response = await apiService.put(
        '/auth/farmers/${farmer.id}',
        data: {
          'name': farmer.name,
          'firstname': farmer.firstname,
          'middlename': farmer.middlename,
          'surname': farmer.surname,
          'extension': farmer.extension,
          'email': farmer.email,
          'phone': farmer.phone,
          'address': farmer.address,
          'sex': farmer.sex,
          'barangay': farmer.barangay,
          'sectorId': _getSectorId(farmer.sector!),
          'imageUrl': farmer.imageUrl,
          'farm_name': farmer.farmName,
          'association': farmer.association,
          'total_land_area': farmer.hectare?.toString(),
          // New fields
          'house_hold_head': farmer.house_hold_head,
          'civil_status': farmer.civilStatus,
          'spouse_name': farmer.spouseName,
          'religion': farmer.religion,
          'household_num': farmer.householdNum,
          'male_members_num': farmer.maleMembersNum,
          'female_members_num': farmer.femaleMembersNum,
          'mother_maiden_name': farmer.motherMaidenName,
          'person_to_notify': farmer.personToNotify,
          'ptn_contact': farmer.ptnContact,
          'ptn_relationship': farmer.ptnRelationship,
          'accountStatus': farmer.accountStatus
        },
      );

      if (response.data == null || response.data['farmer'] == null) {
        throw Exception('Invalid farmer data format');
      }

      return Farmer.fromJson(response.data['farmer']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Farmer not found');
      } else if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        if (errorData != null &&
            errorData['message'] == 'Email already in use by another farmer') {
          throw Exception('Email already in use by another farmer');
        }
        throw Exception(errorData['message'] ?? 'Invalid request');
      }
      throw Exception('API Error: ${e.response?.statusCode} - ${e.message}');
    } catch (e) {
      throw Exception('Failed to update farmer: $e');
    }
  }

  Future<List<Farmer>> fetchFarmers() async {
    try {
      if (_firebaseAuth.currentUser == null) {
        throw Exception('User not authenticated');
      }

      final response = await apiService.get('/auth/farmers');

      // Debug print: Print the entire raw response
      // print('Raw API response: ${response.data}');

      if (response.data == null || response.data['farmers'] == null) {
        throw Exception('Invalid farmers data format');
      }

      final farmersData = response.data['farmers'] as List;

      return farmersData.map((json) => Farmer.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('API Error: ${e.response?.statusCode} - ${e.message}');
    } on FirebaseAuthException catch (e) {
      throw Exception('Authentication error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load farmers: $e');
    }
  }

  Future<Farmer> addFarmer(Farmer farmer) async {
    try {
      // Validate authentication
      if (_firebaseAuth.currentUser == null) {
        throw Exception('User not authenticated. Please sign in first.');
      }

      // Validate required fields
      if (farmer.name == null || farmer.name!.isEmpty) {
        throw Exception('Farmer name is required');
      }
      if (farmer.barangay == null || farmer.barangay!.isEmpty) {
        throw Exception('Barangay is required');
      }
      if (farmer.sector == null) {
        throw Exception('Sector is required');
      }

      // Prepare the request data with explicit null checks
      final requestData = {
        'name': farmer.name!,
        'email': farmer.email ?? "---",
        'phone': farmer.phone ?? "---",
        'barangay': farmer.barangay!,
        'sectorId': _getSectorId(farmer.sector!),
        'imageUrl':
            farmer.imageUrl ?? "---", // Assuming imageUrl can be optional
      };

      // Log the request data for debugging
      print('Sending farmer data: $requestData');

      final response = await apiService.post(
        '/auth/farmers',
        data: requestData,
      );

      // Validate response format
      if (response.data == null) {
        throw Exception('Server returned empty response');
      }
      if (response.data['farmer'] == null) {
        throw Exception(
            'Server response missing farmer data. Full response: ${response.data}');
      }

      return Farmer.fromJson(response.data['farmer']);
    } on DioException catch (e) {
      // Enhanced Dio error handling
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
      // More detailed error message for other exceptions
      throw Exception('''
Failed to add farmer:
- Error Type: ${e.runtimeType}
- Error Details: $e
- Stack Trace: ${e is Error ? e.stackTrace : ''}
''');
    }
  }

  Future<void> deleteFarmer(int farmerId) async {
    try {
      if (_firebaseAuth.currentUser == null) {
        throw Exception('User not authenticated');
      }

      await apiService.delete('/auth/farmers/$farmerId');
    } on DioException catch (e) {
      throw Exception('API Error: ${e.response?.statusCode} - ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete farmer: $e');
    }
  }

  // Reusing the same sector mapping as in ProductRepository
  int _getSectorId(String sectorName) {
    const sectorMap = {
      'Fishery': 2,
      'Livestock': 5,
      'Organic': 4,
      'HVC': 1,
      'Corn': 6,
      'Rice': 3,
    };
    return sectorMap[sectorName] ?? 4; // Default to HVC if not found
  }
}
