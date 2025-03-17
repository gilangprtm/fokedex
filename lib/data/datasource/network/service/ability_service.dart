import '../../../../core/base/base_network.dart';
import '../../../../core/env/app_environment.dart';
import '../../../datasource/models/api_response_model.dart';
import '../db/dio_service.dart';

class AbilityService extends BaseService {
  final DioService _dioService = DioService();

  /// Get list of abilities with pagination
  Future<PaginatedApiResponse<ResourceListItem>> getAbilityList({
    int offset = 0,
    int? limit,
  }) async {
    final abilityLimit =
        limit ?? AppEnvironment.instance.get<int>('pokemonLimit');

    return performanceAsync(
      operationName: 'AbilityService.getAbilityList',
      function: () async {
        try {
          final response = await _dioService.get(
            '/ability',
            queryParameters: {
              'offset': offset,
              'limit': abilityLimit,
            },
          );

          return PaginatedApiResponse<ResourceListItem>.fromJson(
            response.data,
            (item) => ResourceListItem.fromJson(item),
          );
        } catch (e, stackTrace) {
          logger.e(
            'Failed to load ability list',
            error: e,
            stackTrace: stackTrace,
            tag: 'AbilityService',
          );
          rethrow;
        }
      },
      tag: 'AbilityService',
    );
  }

  /// Get ability detail by ID or name
  Future<Map<String, dynamic>> getAbilityDetail(String idOrName) async {
    return performanceAsync(
      operationName: 'AbilityService.getAbilityDetail',
      function: () async {
        try {
          final response = await _dioService.get('/ability/$idOrName');
          return response.data;
        } catch (e, stackTrace) {
          logger.e(
            'Failed to load ability detail',
            error: e,
            stackTrace: stackTrace,
            tag: 'AbilityService',
          );
          rethrow;
        }
      },
      tag: 'AbilityService',
    );
  }
}
