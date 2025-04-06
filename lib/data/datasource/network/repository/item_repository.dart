import '../../../../core/base/base_network.dart';
import '../../../../data/models/api_response_model.dart';
import '../../../../data/models/item_model.dart';

/// Repository untuk mengambil data dari Item endpoint
class ItemRepository extends BaseRepository {
  /// Ambil daftar item (dengan pagination)
  Future<PaginatedApiResponse<ResourceListItem>> getItemList({
    int offset = 0,
    int? limit,
  }) async {
    final itemLimit = limit ?? 20;
    final String endpoint = '/item?offset=$offset&limit=$itemLimit';

    try {
      final response = await dioService.get(endpoint);

      // Konversi data JSON ke model langsung di repository
      return PaginatedApiResponse<ResourceListItem>.fromJson(
        response.data,
        (item) => ResourceListItem.fromJson(item),
      );
    } catch (e, stackTrace) {
      logError('Failed to fetch Item list',
          error: e, stackTrace: stackTrace, tag: 'ItemRepository');
      rethrow;
    }
  }

  /// Ambil detail Item berdasarkan ID atau nama
  Future<Item> getItemDetail(String idOrName) async {
    final String endpoint = '/item/$idOrName';

    try {
      final response = await dioService.get(endpoint);
      // Konversi data JSON ke model Item
      return Item.fromJson(response.data);
    } catch (e, stackTrace) {
      logError('Failed to fetch Item detail',
          error: e, stackTrace: stackTrace, tag: 'ItemRepository');
      rethrow;
    }
  }
}
