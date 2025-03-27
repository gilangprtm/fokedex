import '../../../../core/base/base_network.dart';
import '../../../datasource/models/pokemon_model.dart';
import '../../../datasource/models/api_response_model.dart';
import '../../models/pokemon_list_item_model.dart';
import '../repository/pokemon_repository.dart';

/// Service untuk mengelola logika bisnis terkait Pokemon
class PokemonService extends BaseService {
  final PokemonRepository _pokemonRepository = PokemonRepository();

  /// Ambil daftar Pokemon dengan pagination
  Future<PaginatedApiResponse<ResourceListItem>> getPokemonList({
    int offset = 0,
    int? limit,
  }) async {
    return performanceAsync(
      operationName: 'PokemonService.getPokemonList',
      function: () async {
        try {
          // Repository sudah mengembalikan data dalam bentuk model
          return await _pokemonRepository.getPokemonList(
            offset: offset,
            limit: limit,
          );
        } catch (e, stackTrace) {
          logger.e(
            'Failed to load Pokemon list',
            error: e,
            stackTrace: stackTrace,
            tag: 'PokemonService',
          );
          rethrow;
        }
      },
      tag: 'PokemonService',
    );
  }

  /// Ambil detail Pokemon berdasarkan ID atau nama
  Future<Pokemon> getPokemonDetail(String idOrName) async {
    return performanceAsync(
      operationName: 'PokemonService.getPokemonDetail',
      function: () async {
        try {
          // Repository sudah mengembalikan data dalam bentuk model
          return await _pokemonRepository.getPokemonDetail(idOrName);
        } catch (e, stackTrace) {
          logger.e(
            'Failed to load Pokemon detail',
            error: e,
            stackTrace: stackTrace,
            tag: 'PokemonService',
          );
          rethrow;
        }
      },
      tag: 'PokemonService',
    );
  }

  /// Ambil detail Pokemon berdasarkan ID atau nama
  Future<PokemonList> getPokemonDetailList(String idOrName) async {
    return performanceAsync(
      operationName: 'PokemonService.getPokemonList',
      function: () async {
        try {
          // Repository sudah mengembalikan data dalam bentuk model
          return await _pokemonRepository.getPokemonDetailList(idOrName);
        } catch (e, stackTrace) {
          logger.e(
            'Failed to load Pokemon detail',
            error: e,
            stackTrace: stackTrace,
            tag: 'PokemonService',
          );
          rethrow;
        }
      },
      tag: 'PokemonService',
    );
  }

  /// Ambil daftar semua tipe Pokemon
  Future<PaginatedApiResponse<ResourceListItem>> getPokemonTypes() async {
    return performanceAsync(
      operationName: 'PokemonService.getPokemonTypes',
      function: () async {
        try {
          // Repository sudah mengembalikan data dalam bentuk model
          return await _pokemonRepository.getPokemonTypes();
        } catch (e, stackTrace) {
          logger.e(
            'Failed to load Pokemon types',
            error: e,
            stackTrace: stackTrace,
            tag: 'PokemonService',
          );
          rethrow;
        }
      },
      tag: 'PokemonService',
    );
  }

  /// Ambil detail tipe Pokemon
  Future<Map<String, dynamic>> getPokemonTypeDetail(String nameOrId) async {
    return performanceAsync(
      operationName: 'PokemonService.getPokemonTypeDetail',
      function: () async {
        try {
          return await _pokemonRepository.getPokemonTypeDetail(nameOrId);
        } catch (e, stackTrace) {
          logger.e(
            'Failed to load Pokemon type detail',
            error: e,
            stackTrace: stackTrace,
            tag: 'PokemonService',
          );
          rethrow;
        }
      },
      tag: 'PokemonService',
    );
  }

  /// Ambil daftar Pokemon berdasarkan tipe
  Future<List<ResourceListItem>> getPokemonByType(String typeName) async {
    return performanceAsync(
      operationName: 'PokemonService.getPokemonByType',
      function: () async {
        try {
          // Repository sudah mengembalikan data dalam bentuk model
          return await _pokemonRepository.getPokemonByType(typeName);
        } catch (e, stackTrace) {
          logger.e(
            'Failed to load Pokemon by type',
            error: e,
            stackTrace: stackTrace,
            tag: 'PokemonService',
          );
          rethrow;
        }
      },
      tag: 'PokemonService',
    );
  }

  /// Ambil daftar ability Pokemon
  Future<PaginatedApiResponse<ResourceListItem>> getPokemonAbilities({
    int offset = 0,
    int? limit,
  }) async {
    return performanceAsync(
      operationName: 'PokemonService.getPokemonAbilities',
      function: () async {
        try {
          // Repository sudah mengembalikan data dalam bentuk model
          return await _pokemonRepository.getPokemonAbilities(
            offset: offset,
            limit: limit,
          );
        } catch (e, stackTrace) {
          logger.e(
            'Failed to load Pokemon abilities',
            error: e,
            stackTrace: stackTrace,
            tag: 'PokemonService',
          );
          rethrow;
        }
      },
      tag: 'PokemonService',
    );
  }

  /// Ambil detail ability Pokemon
  Future<Map<String, dynamic>> getPokemonAbilityDetail(String nameOrId) async {
    return performanceAsync(
      operationName: 'PokemonService.getPokemonAbilityDetail',
      function: () async {
        try {
          return await _pokemonRepository.getPokemonAbilityDetail(nameOrId);
        } catch (e, stackTrace) {
          logger.e(
            'Failed to load Pokemon ability detail',
            error: e,
            stackTrace: stackTrace,
            tag: 'PokemonService',
          );
          rethrow;
        }
      },
      tag: 'PokemonService',
    );
  }

  /// Ambil informasi species Pokemon
  Future<Map<String, dynamic>> getPokemonSpecies(String idOrName) async {
    return performanceAsync(
      operationName: 'PokemonService.getPokemonSpecies',
      function: () async {
        try {
          return await _pokemonRepository.getPokemonSpecies(idOrName);
        } catch (e, stackTrace) {
          logger.e(
            'Failed to load Pokemon species',
            error: e,
            stackTrace: stackTrace,
            tag: 'PokemonService',
          );
          rethrow;
        }
      },
      tag: 'PokemonService',
    );
  }

  /// Ambil rantai evolusi Pokemon
  Future<Map<String, dynamic>> getEvolutionChain(String url) async {
    return performanceAsync(
      operationName: 'PokemonService.getEvolutionChain',
      function: () async {
        try {
          return await _pokemonRepository.getEvolutionChain(url);
        } catch (e, stackTrace) {
          logger.e(
            'Failed to load evolution chain',
            error: e,
            stackTrace: stackTrace,
            tag: 'PokemonService',
          );
          rethrow;
        }
      },
      tag: 'PokemonService',
    );
  }
}
