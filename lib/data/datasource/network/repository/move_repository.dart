import '../../../../core/base/base_network.dart';
import '../../../datasource/models/api_response_model.dart';
import '../../../../core/env/app_environment.dart';

/// Repository untuk mengambil data dari Move endpoint
class MoveRepository extends BaseRepository {
  /// Ambil daftar move (dengan pagination)
  Future<PaginatedApiResponse<ResourceListItem>> getMoveList({
    int offset = 0,
    int? limit,
  }) async {
    final moveLimit = limit ?? AppEnvironment.instance.get<int>('pokemonLimit');
    final String endpoint = '/move?offset=$offset&limit=$moveLimit';

    logInfo('Fetching Move list: $endpoint', tag: 'MoveRepository');
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
  Future<Map<String, dynamic>> getMoveDetail(String idOrName) async {
    final String endpoint = '/move/$idOrName';

    logInfo('Fetching Move detail: $endpoint', tag: 'MoveRepository');
    try {
      final response = await dioService.get(endpoint);
      return response.data;
    } catch (e, stackTrace) {
      logError('Failed to fetch Move detail',
          error: e, stackTrace: stackTrace, tag: 'MoveRepository');
      rethrow;
    }
  }
}
