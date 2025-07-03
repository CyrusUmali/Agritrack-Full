// report_service.dart
import 'package:dio/dio.dart';
import 'package:flareline/services/api_service.dart';

class ReportService {
  final ApiService _apiService;

  ReportService(this._apiService);

  Future<List<Map<String, dynamic>>> fetchSectorYields({
    String? viewBy,
    String? sectorId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};

      if (viewBy != null && viewBy.isNotEmpty) {
        queryParams['viewBy'] = viewBy;
      }

      if (sectorId != null && sectorId.isNotEmpty) {
        queryParams['sectorId'] = sectorId;
      }

      if (startDate != null && startDate.isNotEmpty) {
        queryParams['startDate'] = startDate;
      }

      if (endDate != null && endDate.isNotEmpty) {
        queryParams['endDate'] = endDate;
      }

      final response = await _apiService.get(
        '/auth/sector-yields-report',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['yields']);
      }

      throw Exception('Failed to load product yields: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('Failed to fetch product yields: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch product yields: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> fetchBarangayYields({
    String? viewBy,
    String? productId,
    String? sectorId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};

      if (viewBy != null && viewBy.isNotEmpty) {
        queryParams['viewBy'] = viewBy;
      }

      if (productId != null && productId.isNotEmpty) {
        queryParams['productId'] = productId;
      }

      if (sectorId != null && sectorId.isNotEmpty) {
        queryParams['sectorId'] = sectorId;
      }

      if (startDate != null && startDate.isNotEmpty) {
        queryParams['startDate'] = startDate;
      }

      if (endDate != null && endDate.isNotEmpty) {
        queryParams['endDate'] = endDate;
      }

      final response = await _apiService.get(
        '/auth/barangay-yields-report',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['yields']);
      }

      throw Exception('Failed to load product yields: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('Failed to fetch product yields: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch product yields: ${e.toString()}');
    }
  }

// Add this to your report_service.dart file
  Future<List<Map<String, dynamic>>> fetchProductYields({
    String? viewBy,
    String? productId,
    String? sectorId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};

      if (viewBy != null && viewBy.isNotEmpty) {
        queryParams['viewBy'] = viewBy;
      }

      if (productId != null && productId.isNotEmpty) {
        queryParams['productId'] = productId;
      }

      if (sectorId != null && sectorId.isNotEmpty) {
        queryParams['sectorId'] = sectorId;
      }

      if (startDate != null && startDate.isNotEmpty) {
        queryParams['startDate'] = startDate;
      }

      if (endDate != null && endDate.isNotEmpty) {
        queryParams['endDate'] = endDate;
      }

      final response = await _apiService.get(
        '/auth/product-yields-report',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['yields']);
      }

      throw Exception('Failed to load product yields: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('Failed to fetch product yields: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch product yields: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> fetchFarmers({
    String? barangay,
    String? sector,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};

      if (barangay != null && barangay.isNotEmpty) {
        queryParams['barangay'] = barangay;
      }

      if (sector != null && sector.isNotEmpty) {
        queryParams['sector'] = sector;
      }

      final response = await _apiService.get(
        '/auth/farmers-report',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['farmers']);
      }

      throw Exception('Failed to load farmers: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to fetch farmers: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> fetchYields({
    String? farmerId,
    String? productId,
    String? farmId,
    String? startDate,
    String? endDate,
    String? viewBy,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};

      if (farmerId != null && farmerId.isNotEmpty) {
        queryParams['farmerId'] = farmerId;
      }

      if (productId != null && productId.isNotEmpty) {
        queryParams['productId'] = productId;
      }

      if (farmId != null && farmId.isNotEmpty) {
        queryParams['farmId'] = farmId;
      }

      if (startDate != null && startDate.isNotEmpty) {
        queryParams['startDate'] = startDate;
      }

      if (endDate != null && endDate.isNotEmpty) {
        queryParams['endDate'] = endDate;
      }

      if (viewBy != null && viewBy.isNotEmpty) {
        queryParams['viewBy'] = viewBy;
      }

      final response = await _apiService.get(
        '/auth/yields-report',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['yields']);
      }

      throw Exception('Failed to load yields: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to fetch yields: ${e.toString()}');
    }
  }
}
