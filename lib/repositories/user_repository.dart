import 'package:dio/dio.dart';
import 'package:flareline/core/models/user_model.dart';
import 'package:flareline/services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRepository {
  final ApiService apiService;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  UserRepository({required this.apiService});

  Future<UserModel> getUserById(int userId) async {
    try {
      if (_firebaseAuth.currentUser == null) {
        throw Exception('User not authenticated');
      }

      final response = await apiService.get('/auth/users/$userId');

      if (response.data == null || response.data['user'] == null) {
        throw Exception('Invalid user data format');
      }

      return UserModel.fromJson(response.data['user']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('User not found');
      }
      throw Exception('API Error: ${e.response?.statusCode} - ${e.message}');
    } on FirebaseAuthException catch (e) {
      throw Exception('Authentication error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load user: $e');
    }
  }

  Future<UserModel> updateUser(UserModel user) async {
    try {
      if (_firebaseAuth.currentUser == null) {
        throw Exception('User not authenticated');
      }

      final response = await apiService.put(
        '/auth/users/${user.id}',
        data: {
          'email': user.email,
          'name': user.name,
          'photoUrl': user.photoUrl,
          'role': user.role,
          'fname': user.fname,
          'lname': user.lname,
          'sector': user.sector,
          'phone': user.phone,
          'password': user.password,
          'newPassword': user.newPassword
        },
      );

      if (response.data == null || response.data['user'] == null) {
        throw Exception('Invalid user data format');
      }

      return UserModel.fromJson(response.data['user']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('User not found');
      } else if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        if (errorData != null &&
            errorData['message'] == 'Email already in use by another user') {
          throw Exception('Email already in use by another user');
        }
        throw Exception(errorData['message'] ?? 'Invalid request');
      }
      throw Exception('API Error: ${e.response?.statusCode} - ${e.message}');
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<List<UserModel>> fetchUsers() async {
    try {
      if (_firebaseAuth.currentUser == null) {
        throw Exception('User not authenticated');
      }

      final response = await apiService.get('/auth/users');

      if (response.data == null || response.data['users'] == null) {
        throw Exception('Invalid users data format');
      }

      final usersData = response.data['users'] as List;

      return usersData.map((json) => UserModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('API Error: ${e.response?.statusCode} - ${e.message}');
    } on FirebaseAuthException catch (e) {
      throw Exception('Authentication error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }

  int _getSectorId(String? sectorName) {
    const sectorMap = {
      'Fishery': 2,
      'Livestock': 5,
      'Organic': 4,
      'HVC': 1,
      'Corn': 6,
      'Rice': 3,
    };

    // Handle null case and invalid values
    if (sectorName == null || !sectorMap.containsKey(sectorName)) {
      return 1; // Default to HVC (1) which might be more appropriate
    }

    return sectorMap[sectorName]!;
  }

  Future<UserModel> addUser(UserModel user) async {
    try {
      if (_firebaseAuth.currentUser == null) {
        throw Exception('User not authenticated. Please sign in first.');
      }

      // Validate required fields
      if (user.email.isEmpty) {
        throw Exception('Email is required');
      }
      if (user.name.isEmpty) {
        throw Exception('Name is required');
      }
      if (user.role.isEmpty) {
        throw Exception('Role is required');
      }

      final requestData = {
        'email': user.email,
        'name': user.name,
        'photoUrl': user.photoUrl ?? "---",
        'role': user.role,
        'fname': user.fname,
        'lname': user.lname,
        'sectorId': _getSectorId(user.sector ?? 'N/A'),
        // print('sector${user.sector ?? 'N/A'}');
        // 'sectorId': 1,
        'barangay': user.barangay,
        'phone': user.phone,
        'password': user.password,
        'idToken': user.idToken,
        'farmerId': user.farmerId
      };

      final response = await apiService.post(
        '/auth/users',
        data: requestData,
      );

      if (response.data == null) {
        throw Exception('Server returned empty response');
      }
      if (response.data['user'] == null) {
        throw Exception(
            'Server response missing user data. Full response: ${response.data}');
      }

      return UserModel.fromJson(response.data['user']);
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
      Failed to add user:
      - Error Type: ${e.runtimeType}
      - Error Details: $e
      - Stack Trace: ${e is Error ? e.stackTrace : ''}
      ''');
    }
  }

  Future<void> deleteUser(int userId) async {
    try {
      if (_firebaseAuth.currentUser == null) {
        throw Exception('User not authenticated');
      }

      await apiService.delete('/auth/users/$userId');
    } on DioException catch (e) {
      throw Exception('API Error: ${e.response?.statusCode} - ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  // Optional: Add user-specific methods like changePassword, updateProfile, etc.
  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Reauthenticate first
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Then update password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw Exception('Password change failed: ${e.message}');
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }
}
