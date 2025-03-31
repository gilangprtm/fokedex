import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/mahas/services/logger_service.dart';
import '../../../models/api_response_model.dart';
import '../../../models/pokemon_list_item_model.dart';
import '../../../models/pokemon_model.dart';
import '../../network/service/pokemon_service.dart';
import '../repositories/local_pokemon_repository.dart';

/// Service untuk mengelola operasi data Pokemon lokal
class LocalPokemonService {
  final LocalPokemonRepository _localRepository = LocalPokemonRepository();
  final PokemonService _pokemonService = PokemonService();
  final LoggerService _logger = serviceLocator<LoggerService>();

  // Singleton pattern
  static final LocalPokemonService _instance = LocalPokemonService._internal();
  factory LocalPokemonService() => _instance;
  LocalPokemonService._internal();

  bool _isInitialized = false;

  /// Inisialisasi service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Inisialisasi repository
      await _localRepository.initialize();

      _isInitialized = true;
    } catch (e) {
      // Rethrow untuk penanganan di MahasService
      rethrow;
    }
  }

  /// Pastikan data awal tersedia untuk penggunaan offline
  Future<void> ensureInitialDataExists() async {
    try {
      final hasData = await _localRepository.hasPokemonList();
      if (!hasData) {
        await _localRepository.loadInitialPokemonData();
      }
    } catch (e) {
      // Silent catch
    }
  }

  /// Unduh dan simpan daftar Pokemon
  Future<List<ResourceListItem>> downloadAndSavePokemonList(
      {int limit = 1000}) async {
    try {
      // Ambil data dari API
      final response = await _pokemonService.getPokemonList(
        limit: limit,
        offset: 0,
      );

      final pokemonList = response.results;

      // Simpan ke database lokal
      await _localRepository.savePokemonList(pokemonList);

      return pokemonList;
    } catch (e) {
      // Coba dapatkan data dari lokal jika tersedia
      final localData = await _localRepository.getPokemonList();
      if (localData.isNotEmpty) {
        return localData;
      }

      rethrow;
    }
  }

  /// Unduh dan simpan tipe Pokemon
  Future<List<ResourceListItem>> downloadAndSavePokemonTypes() async {
    try {
      // Ambil data dari API
      final response = await _pokemonService.getPokemonTypes();

      final typesList = response.results;

      // Simpan ke database lokal
      await _localRepository.savePokemonTypes(typesList);

      return typesList;
    } catch (e) {
      // Coba dapatkan data dari lokal jika tersedia
      final localData = await _localRepository.getPokemonTypes();
      if (localData.isNotEmpty) {
        return localData;
      }

      rethrow;
    }
  }

  /// Download and save Pokemon detail
  Future<bool> downloadAndSavePokemonDetail(int id) async {
    try {
      final response = await _pokemonService.getPokemonDetail(id.toString());

      // Log success (only for the first few Pokémon to avoid excessive logging)
      if (id < 10) {
        _logger.d('Downloaded Pokemon ${response.name} (ID: ${response.id})');

        // Check if types are present
        if (response.types != null && response.types!.isNotEmpty) {
          final typeNames = response.types!.map((t) => t.type.name).toList();
          _logger.d('Type names: $typeNames');
        } else {
          _logger.w(
              'Warning: No types found for Pokemon ${response.name} (ID: ${response.id})');
        }
      }

      // Now save to database
      final result = await _localRepository.savePokemonDetail(response);

      // Verify types were saved correctly (for occasional sample)
      if (result && (id % 100 == 0 || id < 10)) {
        final savedPokemon = await _localRepository.getPokemonDetail(id);
        if (savedPokemon != null &&
            savedPokemon.types != null &&
            savedPokemon.types!.isNotEmpty) {
          final typeNames =
              savedPokemon.types!.map((t) => t.type.name).toList();
          _logger.d('Saved type names: $typeNames');
        } else {
          _logger.w('Warning: No types found after saving Pokemon (ID: $id)');
        }
      }

      return result;
    } catch (e) {
      _logger.e('Error downloading Pokemon detail for ID $id: $e');
      return false;
    }
  }

  /// Akses lokal ke daftar Pokemon
  Future<List<ResourceListItem>> getPokemonList() async {
    return await _localRepository.getPokemonList();
  }

  /// Akses lokal ke tipe Pokemon
  Future<List<ResourceListItem>> getPokemonTypes() async {
    return await _localRepository.getPokemonTypes();
  }

  /// Akses lokal ke detail Pokemon
  Future<Pokemon?> getPokemonDetail(dynamic idOrName) async {
    final pokemon = await _localRepository.getPokemonDetail(idOrName);

    // Check for missing type data (for debugging purposes)
    if (pokemon != null && (pokemon.types == null || pokemon.types!.isEmpty)) {
      debugPrint(
          'Warning: Retrieved Pokemon ${pokemon.name} (ID: ${pokemon.id}) has no type data');
    }

    return pokemon;
  }

  /// Akses lokal ke detail Pokemon
  Future<PokemonList?> getPokemonDetailList(dynamic idOrName) async {
    final pokemon = await _localRepository.getPokemonDetailList(idOrName);

    // Check for missing type data (for debugging purposes)
    if (pokemon != null && (pokemon.types == null || pokemon.types!.isEmpty)) {
      debugPrint(
          'Warning: Retrieved Pokemon ${pokemon.name} (ID: ${pokemon.id}) has no type data');
    }

    return pokemon;
  }

  /// Cek apakah ada data Pokemon di lokal
  Future<bool> hasPokemonList() async {
    return await _localRepository.hasPokemonList();
  }

  /// Cek apakah ada detail Pokemon spesifik di lokal
  Future<bool> hasPokemonDetail(dynamic idOrName) async {
    return await _localRepository.hasPokemonDetail(idOrName);
  }

  /// Cek apakah data perlu diperbarui
  Future<bool> needsUpdate(String key) async {
    return await _localRepository.needsUpdate(key);
  }

  /// Dapatkan waktu terakhir pembaruan
  Future<DateTime?> getLastUpdatedTime(String key) async {
    return await _localRepository.getLastUpdatedTime(key);
  }

  /// Dapatkan jumlah Pokemon yang tersimpan
  Future<int> getPokemonCount() async {
    return await _localRepository.getPokemonCount();
  }

  /// Dapatkan jumlah detail Pokemon yang tersimpan
  Future<int> getPokemonDetailCount() async {
    return await _localRepository.getPokemonDetailCount();
  }

  /// Hapus semua data Pokemon
  Future<void> clearAllPokemonData() async {
    await _localRepository.clearAllPokemonData();
  }
}
