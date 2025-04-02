import '../../../../../../core/base/base_network.dart';
import '../../../../../data/models/api_response_model.dart';
import '../../../../../data/models/move_model.dart';
import '../repository/move_repository.dart';

/// Service untuk mengelola logika bisnis terkait Move
class MoveService extends BaseService {
  final MoveRepository _moveRepository = MoveRepository();

  /// Ambil daftar Move dengan pagination
  Future<PaginatedApiResponse<ResourceListItem>> getMoveList({
    int offset = 0,
    int? limit,
    bool forceRefresh = false,
  }) async {
    // Cache key yang unik berdasarkan parameter
    final cacheKey = 'moves_list_${offset}_${limit ?? "all"}';

    // Gunakan cachedOperationAsync dengan TTL 24 jam (1440 menit)
    return cachedOperationAsync(
      cacheKey: cacheKey,
      ttlMinutes: 60 * 24 * 7, // 7 hari
      forceRefresh: forceRefresh,
      operationName: 'MoveService.getMoveList',
      fetchFunction: () async {
        try {
          // Repository sudah mengembalikan data dalam bentuk model
          return await _moveRepository.getMoveList(
            offset: offset,
            limit: limit,
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
      fromJson: (json) => PaginatedApiResponse<ResourceListItem>.fromJson(
        json,
        (item) => ResourceListItem.fromJson(item),
      ),
      tag: 'MoveService',
    );
  }

  /// Ambil detail Move berdasarkan ID atau nama
  Future<Move> getMoveDetail(String idOrName,
      {bool forceRefresh = false}) async {
    // Cache key yang unik berdasarkan ID/nama
    final cacheKey = 'move_detail_$idOrName';

    // Gunakan cachedOperationAsync dengan TTL 24 jam (1440 menit)
    return cachedOperationAsync(
      cacheKey: cacheKey,
      ttlMinutes: 60 * 24 * 7, // 7 hari
      forceRefresh: forceRefresh,
      operationName: 'MoveService.getMoveDetail',
      fetchFunction: () async {
        try {
          return await _moveRepository.getMoveDetail(idOrName);
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
      fromJson: (json) => Move.fromJson(json),
      tag: 'MoveService',
    );
  }
}
