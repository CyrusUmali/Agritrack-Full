import 'package:dio/dio.dart';

class InvoiceService {
  final Dio _dio = Dio();

  Future<String> fetchInvoiceData() async {
    try {
      final response = await _dio.get('http://192.168.254.196:3001/api');
      return response.data.toString();
    } catch (e) {
      return "Error: $e";
    }
  }
}
