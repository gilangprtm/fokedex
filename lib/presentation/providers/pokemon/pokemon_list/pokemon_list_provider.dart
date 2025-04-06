import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/datasource/local/services/local_pokemon_service.dart';
import '../../../../data/datasource/network/service/pokemon_service.dart';
import 'pokemon_list_state.dart';
import 'pokemon_list_notifier.dart';

/// Provider for Pokemon List Screen
final pokemonListProvider =
    StateNotifierProvider.autoDispose<PokemonListNotifier, PokemonListState>(
        (ref) {
  // Create controllers that will be passed to the initial state
  final scrollController = ScrollController();
  final searchController = TextEditingController();

  // Create the initial state
  final initialState = PokemonListState(
    scrollController: scrollController,
    searchController: searchController,
  );

  // Create and return the notifier with initial state and services
  return PokemonListNotifier(
    initialState,
    ref,
    PokemonService(),
    LocalPokemonService(),
  );
});
