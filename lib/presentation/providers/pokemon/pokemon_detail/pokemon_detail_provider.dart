import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import 'pokemon_detail_state.dart';
import 'pokemon_detail_notifier.dart';

/// Provider for Pokemon Detail Screen
final pokemonDetailProvider = StateNotifierProvider.autoDispose<
    PokemonDetailNotifier, PokemonDetailState>(
  (ref) {
    // Get service instances using Riverpod
    final pokemonService = ref.read(pokemonServiceProvider);
    final pokemonRepository = ref.read(pokemonRepositoryProvider);

    // Create initial state
    const initialState = PokemonDetailState();

    // Return notifier with dependencies
    return PokemonDetailNotifier(
      initialState: initialState,
      ref: ref,
      pokemonService: pokemonService,
      pokemonRepository: pokemonRepository,
    );
  },
);
