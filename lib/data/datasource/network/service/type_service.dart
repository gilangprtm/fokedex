import '../../../../../../core/base/base_network.dart';
import '../../../../../data/models/api_response_model.dart';
import '../../../../../data/models/type_model.dart' show TypeDetail;
import '../repository/pokemon_repository.dart';

/// Service untuk mengelola logika bisnis terkait Type
class TypeService extends BaseService {
  final PokemonRepository _pokemonRepository = PokemonRepository();

  /// Ambil daftar semua tipe Pokemon
  Future<PaginatedApiResponse<ResourceListItem>> getTypeList() async {
    return performanceAsync(
      operationName: 'TypeService.getTypeList',
      function: () async {
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
      tag: 'TypeService',
    );
  }

  /// Ambil detail tipe Pokemon
  Future<TypeDetail> getTypeDetail(String nameOrId) async {
    return performanceAsync(
      operationName: 'TypeService.getTypeDetail',
      function: () async {
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
      tag: 'TypeService',
    );
  }
}
