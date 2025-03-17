import '../../../../core/base/base_network.dart';

/// Repository untuk mengambil data dari Pokemon API
class PokemonRepository extends BaseRepository {
  /// Ambil daftar Pokemon (dengan pagination)
  Future<Map<String, dynamic>> getPokemonList({
    int offset = 0,
    int limit = 20,
  }) async {
    final String endpoint = '/pokemon?offset=$offset&limit=$limit';

    logInfo('Fetching Pokemon list: $endpoint', tag: 'PokemonRepository');
    final response = await dioService.get(endpoint);
    return response.data;
  }

  /// Ambil detail Pokemon berdasarkan ID atau nama
  Future<Map<String, dynamic>> getPokemonDetail(String idOrName) async {
    final String endpoint = '/pokemon/$idOrName';

    logInfo('Fetching Pokemon detail: $endpoint', tag: 'PokemonRepository');
    final response = await dioService.get(endpoint);
    return response.data;
  }

  /// Ambil informasi species Pokemon
  Future<Map<String, dynamic>> getPokemonSpecies(String idOrName) async {
    final String endpoint = '/pokemon-species/$idOrName';

    logInfo('Fetching Pokemon species: $endpoint', tag: 'PokemonRepository');
    final response = await dioService.get(endpoint);
    return response.data;
  }

  /// Ambil rantai evolusi Pokemon berdasarkan URL chain
  Future<Map<String, dynamic>> getEvolutionChain(String url) async {
    // This is a special case as it's a full URL coming from the species response
    logInfo('Fetching evolution chain: $url', tag: 'PokemonRepository');
    // Using isFullUrl parameter since this is a full URL from the API response
    final response = await dioService.get(url, isFullUrl: true);
    return response.data;
  }

  /// Ambil daftar type Pokemon
  Future<Map<String, dynamic>> getPokemonTypes() async {
    final String endpoint = '/type';

    logInfo('Fetching Pokemon types: $endpoint', tag: 'PokemonRepository');
    final response = await dioService.get(endpoint);
    return response.data;
  }

  /// Ambil detail type Pokemon
  Future<Map<String, dynamic>> getPokemonTypeDetail(String nameOrId) async {
    final String endpoint = '/type/$nameOrId';

    logInfo('Fetching Pokemon type detail: $endpoint',
        tag: 'PokemonRepository');
    final response = await dioService.get(endpoint);
    return response.data;
  }

  /// Ambil daftar ability Pokemon
  Future<Map<String, dynamic>> getPokemonAbilities({
    int offset = 0,
    int limit = 20,
  }) async {
    final String endpoint = '/ability?offset=$offset&limit=$limit';

    logInfo('Fetching Pokemon abilities: $endpoint', tag: 'PokemonRepository');
    final response = await dioService.get(endpoint);
    return response.data;
  }

  /// Ambil detail ability Pokemon
  Future<Map<String, dynamic>> getPokemonAbilityDetail(String nameOrId) async {
    final String endpoint = '/ability/$nameOrId';

    logInfo('Fetching Pokemon ability detail: $endpoint',
        tag: 'PokemonRepository');
    final response = await dioService.get(endpoint);
    return response.data;
  }
}
