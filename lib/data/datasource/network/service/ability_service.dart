import '../../../../../../core/base/base_network.dart';
import '../../../../../data/models/api_response_model.dart';
import '../../../../../data/models/ability_model.dart';
import '../repository/ability_repository.dart';

/// Service untuk mengelola logika bisnis terkait Ability
class AbilityService extends BaseService {
  final AbilityRepository _abilityRepository = AbilityRepository();

  /// Ambil daftar Ability dengan pagination
  Future<PaginatedApiResponse<ResourceListItem>> getAbilityList({
    int offset = 0,
    int? limit,
    bool forceRefresh = false,
  }) async {
    // Cache key yang unik berdasarkan parameter
    final cacheKey = 'abilities_list_${offset}_${limit ?? "all"}';

    // Gunakan cachedOperationAsync dengan TTL 7 hari
    return cachedOperationAsync(
      cacheKey: cacheKey,
      ttlMinutes: 60 * 24 * 7, // 7 hari
      operationName: 'AbilityService.getAbilityList',
      forceRefresh: forceRefresh,
      fetchFunction: () async {
        try {
          // Repository sudah mengembalikan data dalam bentuk model
          return await _abilityRepository.getAbilityList(
            offset: offset,
            limit: limit,
          );
        } catch (e, stackTrace) {
          logger.e(
            'Failed to load ability list',
            error: e,
            stackTrace: stackTrace,
            tag: 'AbilityService',
          );
          rethrow;
        }
      },
      fromJson: (json) => PaginatedApiResponse<ResourceListItem>.fromJson(
        json,
        (item) => ResourceListItem.fromJson(item),
      ),
      tag: 'AbilityService',
    );
  }

  /// Ambil detail Ability berdasarkan ID atau nama
  Future<Ability> getAbilityDetail(String idOrName,
      {bool forceRefresh = false}) async {
    // Cache key yang unik berdasarkan ID/nama
    final cacheKey = 'ability_detail_$idOrName';

    // Gunakan cachedOperationAsync dengan TTL 7 hari
    return cachedOperationAsync(
      cacheKey: cacheKey,
      ttlMinutes: 60 * 24 * 7, // 7 hari
      operationName: 'AbilityService.getAbilityDetail',
      forceRefresh: forceRefresh,
      fetchFunction: () async {
        try {
          return await _abilityRepository.getAbilityDetail(idOrName);
        } catch (e, stackTrace) {
          logger.e(
            'Failed to load ability detail',
            error: e,
            stackTrace: stackTrace,
            tag: 'AbilityService',
          );
          rethrow;
        }
      },
      fromJson: (json) => Ability.fromJson(json),
      tag: 'AbilityService',
    );
  }
}
