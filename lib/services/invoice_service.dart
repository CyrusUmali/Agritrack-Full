import 'package:dio/dio.dart';

class InvoiceService {
  final Dio _dio = Dio();

  Future<String> fetchInvoiceData() async {
    try {
      final response = await _dio.get(
        'http://192.168.56.1:3001/api',
        options: Options(
          // For web compatibility, only use receiveTimeout
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      return response.data.toString();
    } on DioException catch (e) {
      if (e.response != null) {
        return "Server error: ${e.response?.statusCode} - ${e.response?.data}";
      } else {
        return "Network error: ${e.message}";
      }
    } catch (e) {
      return "Unexpected error: $e";
    }
  }
}
