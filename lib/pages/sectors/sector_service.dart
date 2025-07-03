import 'package:dio/dio.dart';
import 'package:flareline/pages/test/map_widget/pin_style.dart';
import 'package:flareline/services/api_service.dart';

class SectorService {
  final ApiService _apiService;

  SectorService(this._apiService);

  Future<Map<String, dynamic>> fetchYieldStatistics({int? year}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (year != null) {
        queryParams['year'] = year.toString();
      }

      final response = await _apiService.get(
        '/auth/yield-statistics',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data['statistics']);
      } else {
        throw Exception(
            'Failed to load yield statistics: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch yield statistics: ${e.toString()}');
    } catch (e) {
      throw Exception('Failed to fetch yield statistics: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> fetchFarmerStatistics({int? year}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (year != null) {
        queryParams['year'] = year.toString();
      }

      final response = await _apiService.get(
        '/auth/farmer-statistics',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data['statistics']);
      } else {
        throw Exception(
            'Failed to load farmer statistics: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch farmer statistics: ${e.toString()}');
    } catch (e) {
      throw Exception('Failed to fetch farmer statistics: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> fetchUserStatistics({int? year}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (year != null) {
        queryParams['year'] = year.toString();
      }

      final response = await _apiService.get(
        '/auth/user-statistics',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data['statistics']);
      } else {
        throw Exception(
            'Failed to load user statistics: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch user statistics: ${e.toString()}');
    } catch (e) {
      throw Exception('Failed to fetch user statistics: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> fetchFarmStatistics({int? year}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (year != null) {
        queryParams['year'] = year.toString();
      }

      final response = await _apiService.get(
        '/auth/farm-statistics',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data['statistics']);
      } else {
        throw Exception(
            'Failed to load farm statistics: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch farm statistics: ${e.toString()}');
    } catch (e) {
      throw Exception('Failed to fetch farm statistics: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> fetchShiValues({int? year}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (year != null) {
        queryParams['year'] = year.toString();
      }

      final response = await _apiService.get(
        '/auth/shi-values',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data['data']);
      } else {
        throw Exception('Failed to load SHI values: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch SHI values: ${e.toString()}');
    } catch (e) {
      throw Exception('Failed to fetch SHI values: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> fetchSectors({int? year}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (year != null) {
        queryParams['year'] = year.toString();
      }

      final response =
          await _apiService.get('/auth/sectors', queryParameters: queryParams);

      if (response.statusCode == 200) {
        // Extract just the sectors list from the response to maintain compatibility
        return List<Map<String, dynamic>>.from(response.data['sectors']);
      }

      throw Exception('Failed to load sectors: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to fetch sectors: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> fetchSectorDetails(
      {required int sectorId, int? year}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (year != null) {
        queryParams['year'] = year.toString();
      }

      final response = await _apiService.get(
        '/auth/sectors/$sectorId',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data['sector']);
      } else if (response.statusCode == 404) {
        throw Exception('Sector not found');
      } else {
        throw Exception(
            'Failed to load sector details: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Sector not found');
      }
      throw Exception('Failed to fetch sector details: ${e.toString()}');
    } catch (e) {
      throw Exception('Failed to fetch sector details: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> fetchYieldDistribution({
    int? sectorId,
    int? year,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};

      if (sectorId != null) {
        queryParams['sectorId'] = sectorId.toString();
      }

      if (year != null) {
        queryParams['year'] = year.toString();
      }

      final response = await _apiService.get(
        '/auth/yield-distribution',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data
            .map<Map<String, dynamic>>(
                (item) => Map<String, dynamic>.from(item))
            .toList();
      } else if (response.statusCode == 400) {
        throw Exception(
            response.data['message'] ?? 'Invalid request parameters');
      } else {
        throw Exception(
            'Failed to load yield distribution: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception(
            e.response?.data['message'] ?? 'Invalid request parameters');
      }
      throw Exception('Failed to fetch yield distribution: ${e.toString()}');
    } catch (e) {
      throw Exception('Failed to fetch yield distribution: ${e.toString()}');
    }
  }
}
