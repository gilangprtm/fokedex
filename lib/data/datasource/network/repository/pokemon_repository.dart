import '../../../../core/base/base_network.dart';
import '../../../models/api_response_model.dart';
import '../../../models/pokemon_model.dart';
import '../../../models/pokemon_list_item_model.dart';

/// Repository untuk mengambil data dari Pokemon API
class PokemonRepository extends BaseRepository {
  /// Ambil daftar Pokemon (dengan pagination)
  Future<PaginatedApiResponse<ResourceListItem>> getPokemonList({
    int offset = 0,
    int? limit,
  }) async {
    final pokemonLimit = limit ?? 20;
    final String endpoint = '/pokemon?offset=$offset&limit=$pokemonLimit';

    try {
      final response = await dioService.get(endpoint);

      // Konversi data JSON ke model langsung di repository
      return PaginatedApiResponse<ResourceListItem>.fromJson(
        response.data,
        (item) => ResourceListItem.fromJson(item),
      );
    } catch (e, stackTrace) {
      logError('Failed to fetch Pokemon list',
          error: e, stackTrace: stackTrace, tag: 'PokemonRepository');
      rethrow;
    }
  }

  /// Ambil detail Pokemon berdasarkan ID atau nama
  Future<Pokemon> getPokemonDetail(String idOrName) async {
    final String endpoint = '/pokemon/$idOrName';

    try {
      final response = await dioService.get(endpoint);

      // Konversi data JSON ke model Pokemon langsung di repository
      return Pokemon.fromJson(response.data);
    } catch (e, stackTrace) {
      logError('Failed to fetch Pokemon detail',
          error: e, stackTrace: stackTrace, tag: 'PokemonRepository');
      rethrow;
    }
  }

  /// Ambil detail Pokemon berdasarkan ID atau nama
  Future<PokemonList> getPokemonDetailList(String idOrName) async {
    final String endpoint = '/pokemon/$idOrName';

    try {
      final response = await dioService.get(endpoint);

      // Konversi data JSON ke model Pokemon langsung di repository
      return PokemonList.fromJson(response.data);
    } catch (e, stackTrace) {
      logError('Failed to fetch Pokemon detail',
          error: e, stackTrace: stackTrace, tag: 'PokemonRepository');
      rethrow;
    }
  }

  /// Ambil informasi species Pokemon
  Future<Map<String, dynamic>> getPokemonSpecies(String idOrName) async {
    final String endpoint = '/pokemon-species/$idOrName';

    try {
      final response = await dioService.get(endpoint);
      return response.data;
    } catch (e, stackTrace) {
      logError('Failed to fetch Pokemon species',
          error: e, stackTrace: stackTrace, tag: 'PokemonRepository');
      rethrow;
    }
  }

  /// Ambil rantai evolusi Pokemon berdasarkan URL chain
  Future<Map<String, dynamic>> getEvolutionChain(String url) async {
    // This is a special case as it's a full URL coming from the species response
    try {
      // Using isFullUrl parameter since this is a full URL from the API response
      final response = await dioService.get(url, isFullUrl: true);
      return response.data;
    } catch (e, stackTrace) {
      logError('Failed to fetch evolution chain',
          error: e, stackTrace: stackTrace, tag: 'PokemonRepository');
      rethrow;
    }
  }

  /// Ambil daftar type Pokemon
  Future<PaginatedApiResponse<ResourceListItem>> getPokemonTypes() async {
    const String endpoint = '/type';

    try {
      final response = await dioService.get(endpoint);

      // Konversi data JSON ke model langsung di repository
      return PaginatedApiResponse<ResourceListItem>.fromJson(
        response.data,
        (item) => ResourceListItem.fromJson(item),
      );
    } catch (e, stackTrace) {
      logError('Failed to fetch Pokemon types',
          error: e, stackTrace: stackTrace, tag: 'PokemonRepository');
      rethrow;
    }
  }

  /// Ambil detail type Pokemon
  Future<Map<String, dynamic>> getPokemonTypeDetail(String nameOrId) async {
    final String endpoint = '/type/$nameOrId';

    try {
      final response = await dioService.get(endpoint);
      return response.data;
    } catch (e, stackTrace) {
      logError('Failed to fetch Pokemon type detail',
          error: e, stackTrace: stackTrace, tag: 'PokemonRepository');
      rethrow;
    }
  }

  /// Ambil daftar Pokemon berdasarkan tipe
  Future<List<ResourceListItem>> getPokemonByType(String typeName) async {
    try {
      final response = await getPokemonTypeDetail(typeName);
      final pokemonList = response['pokemon'] as List<dynamic>;

      // Konversi data JSON ke List<ResourceListItem> langsung di repository
      return pokemonList
          .map((item) => ResourceListItem.fromJson({
                'name': item['pokemon']['name'],
                'url': item['pokemon']['url'],
              }))
          .toList();
    } catch (e, stackTrace) {
      logError('Failed to fetch Pokemon by type',
          error: e, stackTrace: stackTrace, tag: 'PokemonRepository');
      rethrow;
    }
  }

  /// Ambil daftar ability Pokemon
  Future<PaginatedApiResponse<ResourceListItem>> getPokemonAbilities({
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
      logError('Failed to fetch Pokemon abilities',
          error: e, stackTrace: stackTrace, tag: 'PokemonRepository');
      rethrow;
    }
  }

  /// Ambil detail ability Pokemon
  Future<Map<String, dynamic>> getPokemonAbilityDetail(String nameOrId) async {
    final String endpoint = '/ability/$nameOrId';

    try {
      final response = await dioService.get(endpoint);
      return response.data;
    } catch (e, stackTrace) {
      logError('Failed to fetch Pokemon ability detail',
          error: e, stackTrace: stackTrace, tag: 'PokemonRepository');
      rethrow;
    }
  }

  /// Ambil data dari URL lengkap
  Future<Map<String, dynamic>> getDataFromUrl(String url) async {
    try {
      final response = await dioService.get(url, isFullUrl: true);
      return response.data;
    } catch (e, stackTrace) {
      logError('Failed to fetch data from URL',
          error: e, stackTrace: stackTrace, tag: 'PokemonRepository');
      rethrow;
    }
  }
}
