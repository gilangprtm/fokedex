import '../../../../core/base/base_network.dart';
import '../../../../core/env/app_environment.dart';
import '../../../datasource/models/api_response_model.dart';
import '../db/dio_service.dart';

class LocationService extends BaseService {
  final DioService _dioService = DioService();

  /// Get list of locations with pagination
  Future<PaginatedApiResponse<ResourceListItem>> getLocationList({
    int offset = 0,
    int? limit,
  }) async {
    final locationLimit =
        limit ?? AppEnvironment.instance.get<int>('pokemonLimit');

    return performanceAsync(
      operationName: 'LocationService.getLocationList',
      function: () async {
        try {
          final response = await _dioService.get(
            '/location',
            queryParameters: {
              'offset': offset,
              'limit': locationLimit,
            },
          );

          return PaginatedApiResponse<ResourceListItem>.fromJson(
            response.data,
            (item) => ResourceListItem.fromJson(item),
          );
        } catch (e, stackTrace) {
          logger.e(
            'Failed to load location list',
            error: e,
            stackTrace: stackTrace,
            tag: 'LocationService',
          );
          rethrow;
        }
      },
      tag: 'LocationService',
    );
  }

  /// Get location detail by ID or name
  Future<Map<String, dynamic>> getLocationDetail(String idOrName) async {
    return performanceAsync(
      operationName: 'LocationService.getLocationDetail',
      function: () async {
        try {
          final response = await _dioService.get('/location/$idOrName');
          return response.data;
        } catch (e, stackTrace) {
          logger.e(
            'Failed to load location detail',
            error: e,
            stackTrace: stackTrace,
            tag: 'LocationService',
          );
          rethrow;
        }
      },
      tag: 'LocationService',
    );
  }
}
