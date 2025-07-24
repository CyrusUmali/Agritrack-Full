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

    // Add interceptors for auth if needed
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token if user is logged in
        final token = await FirebaseAuth.instance.currentUser?.getIdToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
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
