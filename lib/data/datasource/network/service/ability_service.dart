import '../../../../core/base/base_network.dart';
import '../../../datasource/models/api_response_model.dart';
import '../repository/ability_repository.dart';

/// Service untuk mengelola logika bisnis terkait Ability
class AbilityService extends BaseService {
  final AbilityRepository _abilityRepository = AbilityRepository();

  /// Ambil daftar Ability dengan pagination
  Future<PaginatedApiResponse<ResourceListItem>> getAbilityList({
    int offset = 0,
    int? limit,
  }) async {
    return performanceAsync(
      operationName: 'AbilityService.getAbilityList',
      function: () async {
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
      tag: 'AbilityService',
    );
  }

  /// Ambil detail Ability berdasarkan ID atau nama
  Future<Map<String, dynamic>> getAbilityDetail(String idOrName) async {
    return performanceAsync(
      operationName: 'AbilityService.getAbilityDetail',
      function: () async {
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
      tag: 'AbilityService',
    );
  }
}
