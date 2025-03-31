import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasource/network/service/pokemon_service.dart';
import '../../data/datasource/network/service/move_service.dart';
import '../../data/datasource/local/services/local_pokemon_service.dart';

// Network Services
final pokemonServiceProvider = Provider<PokemonService>((ref) {
  return PokemonService();
});

final moveServiceProvider = Provider<MoveService>((ref) {
  return MoveService();
});

// Local Services
final localPokemonServiceProvider = Provider<LocalPokemonService>((ref) {
  return LocalPokemonService();
});
