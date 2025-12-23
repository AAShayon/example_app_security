import '../models/restroom.dart';
import '../services/api_service.dart';
import '../security/network_security.dart';

class RestroomService {
  final ApiService _apiService = ApiService();

  RestroomService() {
    // Set the base URL for the restroom API
    NetworkSecurity.setBaseUrl('https://www.refugerestrooms.org');
  }

  Future<List<Restroom>> searchRestrooms({
    String query = '',
    int page = 1,
    int perPage = 10,
    int offset = 0,
  }) async {
    try {
      // Create search parameters
      final params = <String, dynamic>{
        'page': page,
        'per_page': perPage,
        'offset': offset,
      };

      if (query.isNotEmpty) {
        params['query'] = query;
      }

      // Use the generic request method with security features
      final response = await _apiService.makeRequest(
        method: 'GET',
        endpoint: 'restrooms_search', // This will be resolved by dynamic endpoint manager
        params: params,
      );

      if (response is List) {
        return response
            .map((item) => Restroom.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (response is Map && response.containsKey('restrooms')) {
        final restroomsList = response['restrooms'] as List;
        return restroomsList
            .map((item) => Restroom.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Failed to search restrooms: $e');
    }
  }

  Future<List<Restroom>> getRestroomsByLocation({
    required double latitude,
    required double longitude,
    int radius = 1000, // in meters
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final params = <String, dynamic>{
        'lat': latitude,
        'lng': longitude,
        'radius': radius,
        'page': page,
        'per_page': perPage,
      };

      final response = await _apiService.makeRequest(
        method: 'GET',
        endpoint: '/restrooms/by_location', // This will be combined with base URL
        params: params,
      );

      if (response is List) {
        return response
            .map((item) => Restroom.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Failed to get restrooms by location: $e');
    }
  }
}