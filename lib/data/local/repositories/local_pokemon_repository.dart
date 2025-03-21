import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../datasource/models/api_response_model.dart';
import '../../datasource/models/pokemon_model.dart';
import '../db/db_local.dart';

/// Konstanta untuk key di tabel settings
const String kPokemonListKey = 'pokemon_list_updated';
const String kPokemonTypesKey = 'pokemon_types_updated';
const String kPokemonDetailKey = 'pokemon_detail_updated';

/// Helper method to get type ID from name
int _getTypeId(String typeName) {
  final typeMap = {
    'normal': 1,
    'fighting': 2,
    'flying': 3,
    'poison': 4,
    'ground': 5,
    'rock': 6,
    'bug': 7,
    'ghost': 8,
    'steel': 9,
    'fire': 10,
    'water': 11,
    'grass': 12,
    'electric': 13,
    'psychic': 14,
    'ice': 15,
    'dragon': 16,
    'dark': 17,
    'fairy': 18,
  };

  return typeMap[typeName] ?? 1; // Default to normal type if not found
}

/// Repository untuk operasi lokal terkait data Pokemon menggunakan SQLite
class LocalPokemonRepository {
  final DBLocal _db = DBLocal();

  /// Inisialisasi repository
  Future<void> initialize() async {
    try {
      // Pastikan database sudah terbuka
      await _db.database;
    } catch (e) {
      rethrow;
    }
  }

  /// Menyimpan daftar Pokemon ke dalam database lokal
  Future<int> savePokemonList(List<ResourceListItem> pokemonList) async {
    try {
      final batch = <Map<String, dynamic>>[];

      for (var pokemon in pokemonList) {
        batch.add({
          'id': pokemon.id,
          'name': pokemon.name,
          'url': pokemon.url,
          'json_data': jsonEncode(
            {
              'id': pokemon.id,
              'name': pokemon.name,
              'url': pokemon.url,
            },
          ),
        });
      }

      // Gunakan operasi batch untuk kinerja yang lebih baik
      final count = await _db.insertBatch(DBLocal.tablePokemon, batch);

      // Update timestamp
      await _db.saveSetting(kPokemonListKey, DateTime.now().toIso8601String());

      return count;
    } catch (e) {
      rethrow;
    }
  }

  /// Menyimpan daftar tipe Pokemon ke dalam database lokal
  Future<int> savePokemonTypes(List<ResourceListItem> typesList) async {
    try {
      final batch = <Map<String, dynamic>>[];

      for (var type in typesList) {
        batch.add({
          'id': type.id,
          'name': type.name,
          'url': type.url,
          'json_data': jsonEncode(
            {
              'id': type.id,
              'name': type.name,
              'url': type.url,
            },
          ),
        });
      }

      // Gunakan operasi batch untuk kinerja yang lebih baik
      final count = await _db.insertBatch(DBLocal.tablePokemonType, batch);

      // Update timestamp
      await _db.saveSetting(kPokemonTypesKey, DateTime.now().toIso8601String());

      return count;
    } catch (e) {
      rethrow;
    }
  }

  /// Menyimpan detail Pokemon ke dalam database lokal
  Future<bool> savePokemonDetail(Pokemon pokemon) async {
    try {
      final pokemonJson = pokemon.toJson();

      // Convert complex objects to JSON strings for storage
      final dbData = {
        'id': pokemon.id,
        'name': pokemon.name,
        'height': pokemon.height,
        'weight': pokemon.weight,
        'json_data': jsonEncode(pokemonJson),
      };

      await _db.insert(DBLocal.tablePokemonDetail, dbData);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Menyimpan batch detail Pokemon ke dalam database lokal
  Future<int> savePokemonDetails(List<Pokemon> pokemonDetails) async {
    try {
      final batch = <Map<String, dynamic>>[];

      for (var pokemon in pokemonDetails) {
        final pokemonJson = pokemon.toJson();

        batch.add({
          'id': pokemon.id,
          'name': pokemon.name,
          'height': pokemon.height,
          'weight': pokemon.weight,
          'json_data': jsonEncode(pokemonJson),
        });
      }

      // Gunakan operasi batch untuk kinerja yang lebih baik
      final count = await _db.insertBatch(DBLocal.tablePokemonDetail, batch);

      // Update timestamp
      await _db.saveSetting(
          kPokemonDetailKey, DateTime.now().toIso8601String());

      return count;
    } catch (e) {
      rethrow;
    }
  }

  /// Mendapatkan daftar Pokemon dari database lokal
  Future<List<ResourceListItem>> getPokemonList() async {
    try {
      final data = await _db.queryAll(DBLocal.tablePokemon);

      return data.map((item) {
        // Jika json_data tersedia, gunakan itu untuk parsing
        if (item['json_data'] != null) {
          final jsonData = jsonDecode(item['json_data'] as String);
          return ResourceListItem.fromJson(jsonData);
        }

        // Fallback ke data basic
        return ResourceListItem(
          name: item['name'] as String,
          url: item['url'] as String,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Mendapatkan daftar tipe Pokemon dari database lokal
  Future<List<ResourceListItem>> getPokemonTypes() async {
    try {
      final data = await _db.queryAll(DBLocal.tablePokemonType);

      return data.map((item) {
        // Jika json_data tersedia, gunakan itu untuk parsing
        if (item['json_data'] != null) {
          final jsonData = jsonDecode(item['json_data'] as String);
          return ResourceListItem.fromJson(jsonData);
        }

        // Fallback ke data basic
        return ResourceListItem(
          name: item['name'] as String,
          url: item['url'] as String,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Mendapatkan detail Pokemon dari database lokal
  Future<Pokemon?> getPokemonDetail(dynamic idOrName) async {
    try {
      int id;
      if (idOrName is int) {
        id = idOrName;
      } else if (idOrName is String && int.tryParse(idOrName) != null) {
        id = int.parse(idOrName);
      } else {
        // Query by name
        final result = await _db.queryWhere(
          DBLocal.tablePokemon,
          'name = ?',
          [idOrName.toString().toLowerCase()],
        );
        if (result.isNotEmpty) {
          id = result.first['id'] as int;
        } else {
          return null;
        }
      }

      // Get Pokemon data from DB
      final pokemonResult = await _db.queryWhere(
        DBLocal.tablePokemon,
        'id = ?',
        [id],
      );

      if (pokemonResult.isEmpty) {
        return null;
      }

      final pokemon = pokemonResult.first;

      // Check if there is more detailed info in the pokemon_detail table
      final detailResult = await _db.queryWhere(
        DBLocal.tablePokemonDetail,
        'id = ?',
        [id],
      );

      // Use detail data if available
      final Map<String, dynamic> pokemonData = detailResult.isNotEmpty
          ? {...pokemon, ...detailResult.first}
          : pokemon;

      // If there's JSON data in pokemon_detail, parse it directly
      if (detailResult.isNotEmpty && detailResult.first['json_data'] != null) {
        try {
          final jsonData =
              jsonDecode(detailResult.first['json_data'] as String);
          return Pokemon.fromJson(jsonData);
        } catch (e) {
          // If parsing fails, continue with fallback approach
        }
      }

      // Generate a default type based on Pokemon name
      final name = pokemonData['name'] as String;
      final defaultType = _getDefaultTypeFromName(name);

      // Construct simplified JSON for Pokemon
      final Map<String, dynamic> pokemonJson = {
        "id": id,
        "name": pokemonData['name'],
        "url": pokemonData['url'] ?? 'https://pokeapi.co/api/v2/pokemon/$id/',
        "height": pokemonData['height'] ?? 0,
        "weight": pokemonData['weight'] ?? 0,
        "base_experience": pokemonData['base_experience'] ?? 0,
        "types": [
          {
            "slot": 1,
            "type": {
              "name": defaultType,
              "url":
                  "https://pokeapi.co/api/v2/type/${_getTypeId(defaultType)}/",
            }
          }
        ],
        "sprites": {
          "front_default":
              "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png",
          "other": {
            "official-artwork": {
              "front_default":
                  "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png"
            }
          }
        }
      };

      return Pokemon.fromJson(pokemonJson);
    } catch (e) {
      return null;
    }
  }

  /// Cek apakah ada data Pokemon di database lokal
  Future<bool> hasPokemonList() async {
    return await _db.hasData(DBLocal.tablePokemon);
  }

  /// Cek apakah ada detail Pokemon spesifik di database lokal
  Future<bool> hasPokemonDetail(dynamic idOrName) async {
    try {
      if (idOrName is int ||
          (idOrName is String && int.tryParse(idOrName) != null)) {
        // Cek berdasarkan ID
        final count = await _db.rawQuery(
          'SELECT COUNT(*) as count FROM ${DBLocal.tablePokemonDetail} WHERE id = ?',
          [idOrName is int ? idOrName : int.parse(idOrName)],
        );
        return (count.first['count'] as int) > 0;
      } else {
        // Cek berdasarkan nama
        final count = await _db.rawQuery(
          'SELECT COUNT(*) as count FROM ${DBLocal.tablePokemonDetail} WHERE name = ?',
          [idOrName],
        );
        return (count.first['count'] as int) > 0;
      }
    } catch (e) {
      return false;
    }
  }

  /// Mendapatkan jumlah Pokemon di database lokal
  Future<int> getPokemonCount() async {
    return await _db.getCount(DBLocal.tablePokemon);
  }

  /// Mendapatkan jumlah detail Pokemon di database lokal
  Future<int> getPokemonDetailCount() async {
    return await _db.getCount(DBLocal.tablePokemonDetail);
  }

  /// Hapus semua data Pokemon dari database lokal
  Future<void> clearAllPokemonData() async {
    try {
      await _db.clearTable(DBLocal.tablePokemon);
      await _db.clearTable(DBLocal.tablePokemonDetail);
      await _db.clearTable(DBLocal.tablePokemonType);
    } catch (e) {
      rethrow;
    }
  }

  /// Cek apakah data perlu diperbarui
  Future<bool> needsUpdate(String key) async {
    try {
      final lastUpdated = await _db.getSettingLastUpdated(key);
      if (lastUpdated == null) return true;

      // Anggap data perlu diperbarui jika sudah lebih dari 24 jam
      final now = DateTime.now();
      final diff = now.difference(lastUpdated).inHours;
      return diff >= 24;
    } catch (e) {
      return true;
    }
  }

  /// Mendapatkan waktu terakhir pembaruan
  Future<DateTime?> getLastUpdatedTime(String key) async {
    return await _db.getSettingLastUpdated(key);
  }

  /// Muat data Pokemon awal untuk mode offline
  Future<void> loadInitialPokemonData() async {
    // Implementasi untuk memuat data awal yang sudah ada di assets atau bundel aplikasi
    // Untuk implementation sederhana, kita bisa skip dulu
  }
}

/// Helper method to determine the default type based on Pokémon name
String _getDefaultTypeFromName(String pokemonName) {
  final nameLower = pokemonName.toLowerCase();

  if (nameLower.contains('stellar') ||
      nameLower.contains('psychic') ||
      nameLower.contains('mew') ||
      nameLower.contains('celebi'))
    return 'psychic';
  else if (nameLower.contains('fire') ||
      nameLower.contains('flame') ||
      nameLower.contains('char') ||
      nameLower.contains('cinder'))
    return 'fire';
  else if (nameLower.contains('water') ||
      nameLower.contains('squirt') ||
      nameLower.contains('blastoise') ||
      nameLower.contains('keldeo'))
    return 'water';
  else if (nameLower.contains('electric') ||
      nameLower.contains('thunder') ||
      nameLower.contains('pika') ||
      nameLower.contains('volt'))
    return 'electric';
  else if (nameLower.contains('grass') ||
      nameLower.contains('leaf') ||
      nameLower.contains('bulb') ||
      nameLower.contains('ivy'))
    return 'grass';
  else if (nameLower.contains('ice') ||
      nameLower.contains('snow') ||
      nameLower.contains('frost') ||
      nameLower.contains('freez'))
    return 'ice';
  else if (nameLower.contains('fighting') ||
      nameLower.contains('combat') ||
      nameLower.contains('hit') ||
      nameLower.contains('teras-combat'))
    return 'fighting';
  else if (nameLower.contains('poison') || nameLower.contains('toxic'))
    return 'poison';
  else if (nameLower.contains('ground') ||
      nameLower.contains('earth') ||
      nameLower.contains('terra'))
    return 'ground';
  else if (nameLower.contains('flying') ||
      nameLower.contains('wing') ||
      nameLower.contains('bird'))
    return 'flying';
  else if (nameLower.contains('bug') || nameLower.contains('insect'))
    return 'bug';
  else if (nameLower.contains('rock') || nameLower.contains('stone'))
    return 'rock';
  else if (nameLower.contains('ghost') ||
      nameLower.contains('spirit') ||
      nameLower.contains('specter'))
    return 'ghost';
  else if (nameLower.contains('dragon') || nameLower.contains('draconic'))
    return 'dragon';
  else if (nameLower.contains('dark') ||
      nameLower.contains('evil') ||
      nameLower.contains('wicked'))
    return 'dark';
  else if (nameLower.contains('steel') ||
      nameLower.contains('metal') ||
      nameLower.contains('iron'))
    return 'steel';
  else if (nameLower.contains('fairy') ||
      nameLower.contains('fae') ||
      nameLower.contains('pixie')) return 'fairy';

  // Default to normal
  return 'normal';
}
