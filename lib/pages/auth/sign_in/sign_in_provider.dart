import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flareline/core/models/user_model.dart';
import 'package:flareline/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flareline_uikit/core/mvvm/base_viewmodel.dart';
import 'package:flareline_uikit/utils/snackbar_util.dart';
import 'package:provider/provider.dart';

import 'package:toastification/toastification.dart';

class SignInProvider extends BaseViewModel {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth;
  final Dio _dio;
  final GoogleSignIn _googleSignIn;

  bool _testLoading = false;

  SignInProvider(super.ctx,
      {FirebaseAuth? auth, Dio? dio, GoogleSignIn? googleSignIn})
      : _auth = auth ?? FirebaseAuth.instance,
        _dio = dio ?? Dio(),
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              // clientId: only include if NOT using Firebase Auth JS SDK in index.html
              scopes: ['email', 'profile'],
            ) {
    _dio.options.baseUrl = 'http://localhost:3001';
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 5);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignInResponse(
      UserCredential userCredential, BuildContext context) async {
    try {
      final idToken = await userCredential.user?.getIdToken();
      if (idToken == null) throw Exception('Failed to get ID token');

      final response = await _dio.post(
        '/auth/login',
        data: {'firebaseToken': idToken},
        options: Options(contentType: Headers.jsonContentType),
      );

      final userData = response.data['user'];
      print('userData');
      print(userData);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.setUser(UserModel.fromMap(userData));

      if (!_testLoading) {
        setLoading(false);
      }

      Navigator.of(context).pushReplacementNamed('/');
    } on DioException catch (e) {
      setLoading(false);
      final errorMsg =
          e.response?.data?['message'] ?? 'Backend verification failed';
      _showErrorToast(context, errorMsg);
      await _auth.signOut();
      await _googleSignIn.signOut();

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.clearUser();
    } catch (e) {
      setLoading(false);
      _showErrorToast(context, 'Error: ${e.toString()}');

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.clearUser();
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      setLoading(true);

      GoogleSignInAccount? googleUser;

      if (_isWeb()) {
        googleUser = await _googleSignIn.signInSilently();
        if (googleUser == null) {
          googleUser = await _googleSignIn.signIn();
        }
      } else {
        googleUser = await _googleSignIn.signIn();
      }

      if (googleUser == null) {
        setLoading(false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      await _handleSignInResponse(userCredential, context);
    } on FirebaseAuthException catch (e) {
      setLoading(false);
      _showErrorToast(context, 'Google Sign-In failed: ${e.message}');
    } catch (e) {
      setLoading(false);
      _showErrorToast(context, 'Google Sign-In error: ${e.toString()}');
    } finally {
      if (!_testLoading) {
        setLoading(false);
      }
    }
  }

  bool _isWeb() {
    return identical(0, 0.0); // Simple way to check for web platform
  }

  // Helper method to show error toast
  void _showErrorToast(BuildContext context, String message) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.fillColored,
      title: Text('Error'),
      description: Text(message),
      alignment: Alignment.topRight,
      autoCloseDuration: const Duration(seconds: 5), // Show for 5 seconds
      animationDuration: const Duration(milliseconds: 300),
      icon: const Icon(Icons.error),
      showProgressBar: true,
      closeButtonShowType: CloseButtonShowType.always,
      closeOnClick: false,
      pauseOnHover: true,
      dragToClose: true,
      applyBlurEffect: true,
    );
  }

  Future<void> signIn(BuildContext context) async {
    try {
      setLoading(true);
      print('Attempting sign in with email: ${emailController.text.trim()}');

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      print('Firebase auth successful, proceeding to backend verification');
      await _handleSignInResponse(userCredential, context);
    } on FirebaseAuthException catch (e) {
      setLoading(false);
      _showErrorToast(context, _mapAuthError(e.code));
      print('Firebase Auth Error: ${e.code} - ${_mapAuthError(e.code)}');
    } catch (e) {
      setLoading(false);
      _showErrorToast(
          context, 'Unexpected error during sign in: ${e.toString()}');
      print('Unexpected error during sign in: ${e.toString()}');
    }
  }

  String _mapAuthError(String code) {
    return switch (code) {
      'user-not-found' => 'No account found with this email',
      'wrong-password' => 'Incorrect password',
      'invalid-email' => 'Invalid email format',
      'user-disabled' => 'This account has been disabled',
      _ => 'Authentication failed',
    };
  }

  void toggleTestLoading() {
    _testLoading = !_testLoading;
    if (_testLoading) {
      setLoading(true);
    } else {
      setLoading(false);
    }
    notifyListeners();
  }
}
