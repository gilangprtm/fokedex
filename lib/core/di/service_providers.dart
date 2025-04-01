import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasource/network/service/pokemon_service.dart';
import '../../data/datasource/network/service/move_service.dart';
import '../../data/datasource/network/service/ability_service.dart';
import '../../data/datasource/network/service/item_service.dart';
import '../../data/datasource/local/services/local_pokemon_service.dart';
import '../../data/datasource/network/service/location_service.dart';

// Network Services
final pokemonServiceProvider = Provider<PokemonService>((ref) {
  return PokemonService();
});

final moveServiceProvider = Provider<MoveService>((ref) {
  return MoveService();
});

final abilityServiceProvider = Provider<AbilityService>((ref) {
  return AbilityService();
});

final itemServiceProvider = Provider<ItemService>((ref) {
  return ItemService();
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

// Local Services
final localPokemonServiceProvider = Provider<LocalPokemonService>((ref) {
  return LocalPokemonService();
});
