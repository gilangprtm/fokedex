import '../../../../../../core/base/base_network.dart';
import '../../../models/api_response_model.dart';
import '../../../models/pokemon_list_item_model.dart';
import '../../../models/pokemon_model.dart';
import '../repository/pokemon_repository.dart';

/// Service untuk mengelola logika bisnis terkait Pokemon
class PokemonService extends BaseService {
  final PokemonRepository _pokemonRepository = PokemonRepository();

  /// Ambil daftar Pokemon dengan pagination
  Future<PaginatedApiResponse<ResourceListItem>> getPokemonList({
    int offset = 0,
    int? limit,
    bool forceRefresh = false,
  }) async {
    // Cache key yang unik berdasarkan parameter
    final cacheKey = 'pokemon_list_${offset}_${limit ?? "all"}';

    // Gunakan cachedOperationAsync dengan TTL 7 hari
    return cachedOperationAsync(
      cacheKey: cacheKey,
      ttlMinutes: 60 * 24 * 7, // 7 hari
      forceRefresh: forceRefresh,
      operationName: 'PokemonService.getPokemonList',
      fetchFunction: () async {
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
      fromJson: (json) => PaginatedApiResponse<ResourceListItem>.fromJson(
        json,
        (item) => ResourceListItem.fromJson(item),
      ),
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
  Future<PokemonList> getPokemonDetailList(String idOrName,
      {bool forceRefresh = false}) async {
    // Cache key yang unik berdasarkan ID/nama
    final cacheKey = 'pokemon_detail_list_$idOrName';

    // Gunakan cachedOperationAsync dengan TTL 7 hari
    return cachedOperationAsync(
      cacheKey: cacheKey,
      ttlMinutes: 60 * 24 * 7, // 7 hari
      forceRefresh: forceRefresh,
      operationName: 'PokemonService.getPokemonDetailList',
      fetchFunction: () async {
        try {
          // Repository sudah mengembalikan data dalam bentuk model
          return await _pokemonRepository.getPokemonDetailList(idOrName);
        } catch (e, stackTrace) {
          logger.e(
            'Failed to load Pokemon detail list',
            error: e,
            stackTrace: stackTrace,
            tag: 'PokemonService',
          );
          rethrow;
        }
      },
      fromJson: (json) => PokemonList.fromJson(json),
      tag: 'PokemonService',
    );
  }

  /// Ambil daftar semua tipe Pokemon
  Future<PaginatedApiResponse<ResourceListItem>> getPokemonTypes(
      {bool forceRefresh = false}) async {
    // Cache key yang unik
    const cacheKey = 'pokemon_types';

    // Gunakan cachedOperationAsync dengan TTL 7 hari
    return cachedOperationAsync(
      cacheKey: cacheKey,
      ttlMinutes: 60 * 24 * 7, // 7 hari
      forceRefresh: forceRefresh,
      operationName: 'PokemonService.getPokemonTypes',
      fetchFunction: () async {
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
      fromJson: (json) => PaginatedApiResponse<ResourceListItem>.fromJson(
        json,
        (item) => ResourceListItem.fromJson(item),
      ),
      tag: 'PokemonService',
    );
  }

  /// Ambil detail tipe Pokemon
  Future<Map<String, dynamic>> getPokemonTypeDetail(String nameOrId,
      {bool forceRefresh = false}) async {
    // Cache key yang unik berdasarkan ID/nama
    final cacheKey = 'pokemon_type_detail_$nameOrId';

    // Gunakan cachedOperationAsync dengan TTL 7 hari
    return cachedOperationAsync(
      cacheKey: cacheKey,
      ttlMinutes: 60 * 24 * 7, // 7 hari
      forceRefresh: forceRefresh,
      operationName: 'PokemonService.getPokemonTypeDetail',
      fetchFunction: () async {
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
  Future<List<ResourceListItem>> getPokemonByType(String typeName,
      {bool forceRefresh = false}) async {
    // Cache key yang unik berdasarkan tipe
    final cacheKey = 'pokemon_by_type_$typeName';

    // Gunakan cachedOperationAsync dengan TTL 7 hari
    return cachedOperationAsync(
      cacheKey: cacheKey,
      ttlMinutes: 60 * 24 * 7, // 7 hari
      forceRefresh: forceRefresh,
      operationName: 'PokemonService.getPokemonByType',
      fetchFunction: () async {
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
    bool forceRefresh = false,
  }) async {
    // Cache key yang unik berdasarkan parameter
    final cacheKey = 'pokemon_abilities_${offset}_${limit ?? "all"}';

    // Gunakan cachedOperationAsync dengan TTL 7 hari
    return cachedOperationAsync(
      cacheKey: cacheKey,
      ttlMinutes: 60 * 24 * 7, // 7 hari
      forceRefresh: forceRefresh,
      operationName: 'PokemonService.getPokemonAbilities',
      fetchFunction: () async {
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
      fromJson: (json) => PaginatedApiResponse<ResourceListItem>.fromJson(
        json,
        (item) => ResourceListItem.fromJson(item),
      ),
      tag: 'PokemonService',
    );
  }

  /// Ambil detail ability Pokemon
  Future<Map<String, dynamic>> getPokemonAbilityDetail(String nameOrId,
      {bool forceRefresh = false}) async {
    // Cache key yang unik berdasarkan ID/nama
    final cacheKey = 'pokemon_ability_detail_$nameOrId';

    // Gunakan cachedOperationAsync dengan TTL 7 hari
    return cachedOperationAsync(
      cacheKey: cacheKey,
      ttlMinutes: 60 * 24 * 7, // 7 hari
      forceRefresh: forceRefresh,
      operationName: 'PokemonService.getPokemonAbilityDetail',
      fetchFunction: () async {
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
  Future<Map<String, dynamic>> getPokemonSpecies(String idOrName,
      {bool forceRefresh = false}) async {
    // Cache key yang unik berdasarkan ID/nama
    final cacheKey = 'pokemon_species_$idOrName';

    // Gunakan cachedOperationAsync dengan TTL 7 hari
    return cachedOperationAsync(
      cacheKey: cacheKey,
      ttlMinutes: 60 * 24 * 7, // 7 hari
      forceRefresh: forceRefresh,
      operationName: 'PokemonService.getPokemonSpecies',
      fetchFunction: () async {
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
  Future<Map<String, dynamic>> getEvolutionChain(String url,
      {bool forceRefresh = false}) async {
    // Cache key yang unik berdasarkan URL
    // Hapus http/https dan ganti slash dengan underscore untuk key yang aman
    final safeUrl =
        url.replaceAll(RegExp(r'https?://'), '').replaceAll('/', '_');
    final cacheKey = 'evolution_chain_$safeUrl';

    // Gunakan cachedOperationAsync dengan TTL 7 hari
    return cachedOperationAsync(
      cacheKey: cacheKey,
      ttlMinutes: 60 * 24 * 7, // 7 hari
      forceRefresh: forceRefresh,
      operationName: 'PokemonService.getEvolutionChain',
      fetchFunction: () async {
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
