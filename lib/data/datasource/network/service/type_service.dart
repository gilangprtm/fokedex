import '../../../../../../core/base/base_network.dart';
import '../../../../../data/models/api_response_model.dart';
import '../../../../../data/models/type_model.dart' show TypeDetail;
import '../repository/pokemon_repository.dart';

/// Service untuk mengelola logika bisnis terkait Type
class TypeService extends BaseService {
  final PokemonRepository _pokemonRepository = PokemonRepository();

  /// Ambil daftar semua tipe Pokemon
  Future<PaginatedApiResponse<ResourceListItem>> getTypeList(
      {bool forceRefresh = false}) async {
    // Cache key unik untuk daftar tipe
    const cacheKey = 'types_list';

    // Gunakan cachedOperationAsync dengan TTL 7 hari
    return cachedOperationAsync(
      cacheKey: cacheKey,
      ttlMinutes: 60 * 24 * 7, // 7 hari
      forceRefresh: forceRefresh,
      operationName: 'TypeService.getTypeList',
      fetchFunction: () async {
        try {
          return await _pokemonRepository.getPokemonTypes();
        } catch (e, stackTrace) {
          logger.e(
            'Failed to load type list',
            error: e,
            stackTrace: stackTrace,
            tag: 'TypeService',
          );
          rethrow;
        }
      },
      fromJson: (json) => PaginatedApiResponse<ResourceListItem>.fromJson(
        json,
        (item) => ResourceListItem.fromJson(item),
      ),
      tag: 'TypeService',
    );
  }

  /// Ambil detail tipe Pokemon
  Future<TypeDetail> getTypeDetail(String nameOrId,
      {bool forceRefresh = false}) async {
    // Cache key unik untuk detail tipe
    final cacheKey = 'type_detail_$nameOrId';

    // Gunakan cachedOperationAsync dengan TTL 7 hari
    return cachedOperationAsync(
      cacheKey: cacheKey,
      ttlMinutes: 60 * 24 * 7, // 7 hari
      forceRefresh: forceRefresh,
      operationName: 'TypeService.getTypeDetail',
      fetchFunction: () async {
        try {
          final Map<String, dynamic> data =
              await _pokemonRepository.getPokemonTypeDetail(nameOrId);
          return TypeDetail.fromJson(data);
        } catch (e, stackTrace) {
          logger.e(
            'Failed to load type detail',
            error: e,
            stackTrace: stackTrace,
            tag: 'TypeService',
          );
          rethrow;
        }
      },
      fromJson: (json) => TypeDetail.fromJson(json),
      tag: 'TypeService',
    );
  }
}
