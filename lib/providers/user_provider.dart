// providers/user_provider.dart
import 'package:flareline/core/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this import

class UserProvider extends ChangeNotifier {
  final GetStorage _storage = GetStorage();
  final FirebaseAuth _auth =
      FirebaseAuth.instance; // Add Firebase Auth instance
  UserModel? _user;

  UserModel? get user => _user;

  UserProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final userData = _storage.read('userData');
    if (userData != null) {
      print(userData);
      _user = UserModel.fromMap(userData);
      notifyListeners();
    }
  }

  Future<void> setUser(UserModel user) async {
    _user = user;
    await _storage.write('userData', user.toMap());
    notifyListeners();
  }

  Future<void> clearUser() async {
    _user = null;
    await _storage.remove('userData');
    notifyListeners();
  }

  // Add this new method for signing out
  Future<void> signOut() async {
    try {
      await _auth.signOut(); // Sign out from Firebase
      await clearUser(); // Clear local user data
    } catch (e) {
      print('Error signing out: $e');
      rethrow; // Re-throw the error so it can be handled by the caller
    }
  }
}
