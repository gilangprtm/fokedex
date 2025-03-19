import '../../../../core/base/base_network.dart';
import '../../../datasource/models/api_response_model.dart';
import '../../../../core/env/app_environment.dart';

/// Repository untuk mengambil data dari Location endpoint
class LocationRepository extends BaseRepository {
  /// Ambil daftar location (dengan pagination)
  Future<PaginatedApiResponse<ResourceListItem>> getLocationList({
    int offset = 0,
    int? limit,
  }) async {
    final locationLimit =
        limit ?? AppEnvironment.instance.get<int>('pokemonLimit');
    final String endpoint = '/location?offset=$offset&limit=$locationLimit';

    logInfo('Fetching Location list: $endpoint', tag: 'LocationRepository');
    try {
      final response = await dioService.get(endpoint);

      // Konversi data JSON ke model langsung di repository
      return PaginatedApiResponse<ResourceListItem>.fromJson(
        response.data,
        (item) => ResourceListItem.fromJson(item),
      );
    } catch (e, stackTrace) {
      logError('Failed to fetch Location list',
          error: e, stackTrace: stackTrace, tag: 'LocationRepository');
      rethrow;
    }
  }

  /// Ambil detail Location berdasarkan ID atau nama
  Future<Map<String, dynamic>> getLocationDetail(String idOrName) async {
    final String endpoint = '/location/$idOrName';

    logInfo('Fetching Location detail: $endpoint', tag: 'LocationRepository');
    try {
      final response = await dioService.get(endpoint);
      return response.data;
    } catch (e, stackTrace) {
      logError('Failed to fetch Location detail',
          error: e, stackTrace: stackTrace, tag: 'LocationRepository');
      rethrow;
    }
  }
}
