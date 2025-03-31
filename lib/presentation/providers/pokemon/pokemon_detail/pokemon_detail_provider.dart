import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/datasource/network/service/pokemon_service.dart';
import '../../../../data/datasource/network/repository/pokemon_repository.dart';
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
    final initialState = PokemonDetailState(
      isLoading: true,
      currentPokemonId: '',
      currentPokemonName: '',
    );

    // Return notifier with dependencies
    return PokemonDetailNotifier(
      initialState: initialState,
      ref: ref,
      pokemonService: pokemonService,
      pokemonRepository: pokemonRepository,
    );
  },
);
