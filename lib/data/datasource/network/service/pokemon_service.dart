import '../../../../core/base/base_network.dart';
import '../../../../core/env/app_environment.dart';
import '../../../datasource/models/pokemon_model.dart';
import '../../../datasource/models/api_response_model.dart';
import '../repository/pokemon_repository.dart';

/// Service untuk mengelola logika bisnis terkait Pokemon
class PokemonService extends BaseService {
  final PokemonRepository _pokemonRepository = PokemonRepository();

  /// Ambil daftar Pokemon dengan pagination
  Future<PaginatedApiResponse<ResourceListItem>> getPokemonList({
    int offset = 0,
    int? limit,
  }) async {
    final pokemonLimit =
        limit ?? AppEnvironment.instance.get<int>('pokemonLimit');

    return performanceAsync(
      operationName: 'PokemonService.getPokemonList',
      function: () async {
        try {
          final response = await _pokemonRepository.getPokemonList(
            offset: offset,
            limit: pokemonLimit,
          );

          return PaginatedApiResponse<ResourceListItem>.fromJson(
            response,
            (item) => ResourceListItem.fromJson(item),
          );
        } catch (e, stackTrace) {
          logger.e(
            'Failed to load Pokemon list',
            error: e,
            stackTrace: stackTrace,
            tag: 'PokemonService',
          );
          rethrow; // DioService already handles the specific error types
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
          final response = await _pokemonRepository.getPokemonDetail(idOrName);
          return Pokemon.fromJson(response);
        } catch (e, stackTrace) {
          logger.e(
            'Failed to load Pokemon detail',
            error: e,
            stackTrace: stackTrace,
            tag: 'PokemonService',
          );
          rethrow; // DioService already handles the specific error types
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
          final response = await _pokemonRepository.getPokemonTypes();

          return PaginatedApiResponse<ResourceListItem>.fromJson(
            response,
            (item) => ResourceListItem.fromJson(item),
          );
        } catch (e, stackTrace) {
          logger.e(
            'Failed to load Pokemon types',
            error: e,
            stackTrace: stackTrace,
            tag: 'PokemonService',
          );
          rethrow; // DioService already handles the specific error types
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
          rethrow; // DioService already handles the specific error types
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
          final response =
              await _pokemonRepository.getPokemonTypeDetail(typeName);
          final pokemonList = response['pokemon'] as List<dynamic>;

          return pokemonList
              .map((item) => ResourceListItem.fromJson({
                    'name': item['pokemon']['name'],
                    'url': item['pokemon']['url'],
                  }))
              .toList();
        } catch (e, stackTrace) {
          logger.e(
            'Failed to load Pokemon by type',
            error: e,
            stackTrace: stackTrace,
            tag: 'PokemonService',
          );
          rethrow; // DioService already handles the specific error types
        }
      },
      tag: 'PokemonService',
    );
  }
}
