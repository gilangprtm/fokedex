import '../../../../core/base/base_network.dart';
import '../../../../data/models/api_response_model.dart';
import '../../../../data/models/move_model.dart';

/// Repository untuk mengambil data dari Move endpoint
class MoveRepository extends BaseRepository {
  /// Ambil daftar move (dengan pagination)
  Future<PaginatedApiResponse<ResourceListItem>> getMoveList({
    int offset = 0,
    int? limit,
  }) async {
    final moveLimit = limit ?? 20;
    final String endpoint = '/move?offset=$offset&limit=$moveLimit';

    try {
      final response = await dioService.get(endpoint);

      // Konversi data JSON ke model langsung di repository
      return PaginatedApiResponse<ResourceListItem>.fromJson(
        response.data,
        (item) => ResourceListItem.fromJson(item),
      );
    } catch (e, stackTrace) {
      logError('Failed to fetch Move list',
          error: e, stackTrace: stackTrace, tag: 'MoveRepository');
      rethrow;
    }
  }

  /// Ambil detail Move berdasarkan ID atau nama
  Future<Move> getMoveDetail(String idOrName) async {
    final String endpoint = '/move/$idOrName';

    try {
      final response = await dioService.get(endpoint);
      // Konversi data JSON ke model Move
      return Move.fromJson(response.data);
    } catch (e, stackTrace) {
      logError('Failed to fetch Move detail',
          error: e, stackTrace: stackTrace, tag: 'MoveRepository');
      rethrow;
    }
  }
}
