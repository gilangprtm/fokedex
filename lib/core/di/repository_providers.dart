import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasource/network/repository/pokemon_repository.dart';

final pokemonRepositoryProvider = Provider<PokemonRepository>((ref) {
  return PokemonRepository();
});
