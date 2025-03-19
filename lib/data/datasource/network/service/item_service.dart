import '../../../../core/base/base_network.dart';
import '../../../datasource/models/api_response_model.dart';
import '../repository/item_repository.dart';

/// Service untuk mengelola logika bisnis terkait Item
class ItemService extends BaseService {
  final ItemRepository _itemRepository = ItemRepository();

  /// Ambil daftar Item dengan pagination
  Future<PaginatedApiResponse<ResourceListItem>> getItemList({
    int offset = 0,
    int? limit,
  }) async {
    return performanceAsync(
      operationName: 'ItemService.getItemList',
      function: () async {
        try {
          // Repository sudah mengembalikan data dalam bentuk model
          return await _itemRepository.getItemList(
            offset: offset,
            limit: limit,
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

  /// Ambil detail Item berdasarkan ID atau nama
  Future<Map<String, dynamic>> getItemDetail(String idOrName) async {
    return performanceAsync(
      operationName: 'ItemService.getItemDetail',
      function: () async {
        try {
          return await _itemRepository.getItemDetail(idOrName);
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
