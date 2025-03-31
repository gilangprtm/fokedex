import '../../../../core/base/base_network.dart';
import '../../../../data/models/api_response_model.dart';
import '../../../../data/models/location_model.dart';
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
  Future<Location> getLocationDetail(String idOrName) async {
    final String endpoint = '/location/$idOrName';

    logInfo('Fetching Location detail: $endpoint', tag: 'LocationRepository');
    try {
      final response = await dioService.get(endpoint);
      // Konversi data JSON ke model Location
      return Location.fromJson(response.data);
    } catch (e, stackTrace) {
      logError('Failed to fetch Location detail',
          error: e, stackTrace: stackTrace, tag: 'LocationRepository');
      rethrow;
    }
  }

  /// Ambil detail Location Area berdasarkan ID atau nama
  Future<LocationAreaDetail> getLocationAreaDetail(String idOrName) async {
    final String endpoint = '/location-area/$idOrName';

    logInfo('Fetching Location Area detail: $endpoint',
        tag: 'LocationRepository');
    try {
      final response = await dioService.get(endpoint);
      // Konversi data JSON ke model LocationAreaDetail
      return LocationAreaDetail.fromJson(response.data);
    } catch (e, stackTrace) {
      logError('Failed to fetch Location Area detail',
          error: e, stackTrace: stackTrace, tag: 'LocationRepository');
      rethrow;
    }
  }
}
