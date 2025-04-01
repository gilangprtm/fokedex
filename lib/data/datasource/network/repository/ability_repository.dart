import '../../../../core/base/base_network.dart';
import '../../../../data/models/api_response_model.dart';
import '../../../../data/models/ability_model.dart';

/// Repository untuk mengambil data dari Ability endpoint
class AbilityRepository extends BaseRepository {
  /// Ambil daftar ability (dengan pagination)
  Future<PaginatedApiResponse<ResourceListItem>> getAbilityList({
    int offset = 0,
    int? limit,
  }) async {
    final abilityLimit = limit ?? 20;
    final String endpoint = '/ability?offset=$offset&limit=$abilityLimit';

    try {
      final response = await dioService.get(endpoint);

      // Konversi data JSON ke model langsung di repository
      return PaginatedApiResponse<ResourceListItem>.fromJson(
        response.data,
        (item) => ResourceListItem.fromJson(item),
      );
    } catch (e, stackTrace) {
      logError('Failed to fetch Ability list',
          error: e, stackTrace: stackTrace, tag: 'AbilityRepository');
      rethrow;
    }
  }

  /// Ambil detail Ability berdasarkan ID atau nama
  Future<Ability> getAbilityDetail(String idOrName) async {
    final String endpoint = '/ability/$idOrName';

    try {
      final response = await dioService.get(endpoint);
      // Konversi data JSON ke model Ability
      return Ability.fromJson(response.data);
    } catch (e, stackTrace) {
      logError('Failed to fetch Ability detail',
          error: e, stackTrace: stackTrace, tag: 'AbilityRepository');
      rethrow;
    }
  }
}
