import '../../../../core/base/base_network.dart';
import '../../../../core/env/app_environment.dart';
import '../../../datasource/models/api_response_model.dart';
import '../db/dio_service.dart';

class ItemService extends BaseService {
  final DioService _dioService = DioService();

  /// Get list of items with pagination
  Future<PaginatedApiResponse<ResourceListItem>> getItemList({
    int offset = 0,
    int? limit,
  }) async {
    final itemLimit = limit ?? AppEnvironment.instance.get<int>('pokemonLimit');

    return performanceAsync(
      operationName: 'ItemService.getItemList',
      function: () async {
        try {
          final response = await _dioService.get(
            '/item',
            queryParameters: {
              'offset': offset,
              'limit': itemLimit,
            },
          );

          return PaginatedApiResponse<ResourceListItem>.fromJson(
            response.data,
            (item) => ResourceListItem.fromJson(item),
          );
        } catch (e, stackTrace) {
          logger.e(
            'Failed to load item list',
            error: e,
            stackTrace: stackTrace,
            tag: 'ItemService',
          );
          rethrow;
        }
      },
      tag: 'ItemService',
    );
  }

  /// Get item detail by ID or name
  Future<Map<String, dynamic>> getItemDetail(String idOrName) async {
    return performanceAsync(
      operationName: 'ItemService.getItemDetail',
      function: () async {
        try {
          final response = await _dioService.get('/item/$idOrName');
          return response.data;
        } catch (e, stackTrace) {
          logger.e(
            'Failed to load item detail',
            error: e,
            stackTrace: stackTrace,
            tag: 'ItemService',
          );
          rethrow;
        }
      },
      tag: 'ItemService',
    );
  }
}
