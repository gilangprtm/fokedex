import '../../../../../../core/base/base_network.dart';
import '../../../../../data/models/api_response_model.dart';
import '../../../../../data/models/item_model.dart';
import '../repository/item_repository.dart';

/// Service untuk mengelola logika bisnis terkait Item
class ItemService extends BaseService {
  final ItemRepository _itemRepository = ItemRepository();

  /// Ambil daftar Item dengan pagination
  Future<PaginatedApiResponse<ResourceListItem>> getItemList({
    int offset = 0,
    int? limit,
    bool forceRefresh = false,
  }) async {
    // Cache key yang unik berdasarkan parameter
    final cacheKey = 'items_list_${offset}_${limit ?? "all"}';

    // Gunakan cachedOperationAsync dengan TTL 7 hari
    return cachedOperationAsync(
      cacheKey: cacheKey,
      ttlMinutes: 60 * 24 * 7, // 7 hari
      forceRefresh: forceRefresh,
      operationName: 'ItemService.getItemList',
      fetchFunction: () async {
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
      fromJson: (json) => PaginatedApiResponse<ResourceListItem>.fromJson(
        json,
        (item) => ResourceListItem.fromJson(item),
      ),
      tag: 'ItemService',
    );
  }

  /// Ambil detail Item berdasarkan ID atau nama
  Future<Item> getItemDetail(String idOrName,
      {bool forceRefresh = false}) async {
    // Cache key yang unik berdasarkan ID/nama
    final cacheKey = 'item_detail_$idOrName';

    // Gunakan cachedOperationAsync dengan TTL 7 hari
    return cachedOperationAsync(
      cacheKey: cacheKey,
      ttlMinutes: 60 * 24 * 7, // 7 hari
      forceRefresh: forceRefresh,
      operationName: 'ItemService.getItemDetail',
      fetchFunction: () async {
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
      fromJson: (json) => Item.fromJson(json),
      tag: 'ItemService',
    );
  }
}
