// lib/core/services/api_service.dart
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ApiService {
  final Dio _dio;

  ApiService() : _dio = Dio() {
    _dio.options.baseUrl = 'https://agritrack-server.onrender.com';
    // _dio.options.baseUrl = 'http://localhost:3001';
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

 _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
       
        final token = await FirebaseAuth.instance.currentUser?.getIdToken();
        if (token != null) { 
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }



   // Ping the server to wake it up (retry if needed)
  Future<void> wakeUpServer() async {
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 2);

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        await _dio.get('/wakeup').timeout(const Duration(seconds: 5));
        return; // Success, server is awake
      } catch (e) {
        if (attempt < maxRetries) {
          await Future.delayed(retryDelay);
        }
      }
    }
    print("Warning: Server wake-up failed after $maxRetries attempts");
  }

  Future<Response> get(String path,
          {Map<String, dynamic>? queryParameters}) async =>
      await _dio.get(path, queryParameters: queryParameters);

  Future<Response> post(String path, {dynamic data}) async =>
      await _dio.post(path, data: data);

  Future<Response> put(String path, {dynamic data}) async =>
      await _dio.put(path, data: data);

  Future<Response> delete(String path) async => await _dio.delete(path);
}
