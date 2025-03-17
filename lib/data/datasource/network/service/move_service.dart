import '../../../../core/base/base_network.dart';
import '../../../../core/env/app_environment.dart';
import '../../../datasource/models/api_response_model.dart';
import '../db/dio_service.dart';

class MoveService extends BaseService {
  final DioService _dioService = DioService();

  /// Get list of moves with pagination
  Future<PaginatedApiResponse<ResourceListItem>> getMoveList({
    int offset = 0,
    int? limit,
  }) async {
    final moveLimit = limit ?? AppEnvironment.instance.get<int>('pokemonLimit');

    return performanceAsync(
      operationName: 'MoveService.getMoveList',
      function: () async {
        try {
          final response = await _dioService.get(
            '/move',
            queryParameters: {
              'offset': offset,
              'limit': moveLimit,
            },
          );

          return PaginatedApiResponse<ResourceListItem>.fromJson(
            response.data,
            (item) => ResourceListItem.fromJson(item),
          );
        } catch (e, stackTrace) {
          logger.e(
            'Failed to load move list',
            error: e,
            stackTrace: stackTrace,
            tag: 'MoveService',
          );
          rethrow;
        }
      },
      tag: 'MoveService',
    );
  }

  /// Get move detail by ID or name
  Future<Map<String, dynamic>> getMoveDetail(String idOrName) async {
    return performanceAsync(
      operationName: 'MoveService.getMoveDetail',
      function: () async {
        try {
          final response = await _dioService.get('/move/$idOrName');
          return response.data;
        } catch (e, stackTrace) {
          logger.e(
            'Failed to load move detail',
            error: e,
            stackTrace: stackTrace,
            tag: 'MoveService',
          );
          rethrow;
        }
      },
      tag: 'MoveService',
    );
  }
}
