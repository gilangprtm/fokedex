import 'package:flutter_pokedex/core/base/base_state_notifier.dart';
import '../../../../data/models/pokemon_model.dart';
import '../../../../data/models/evolution_stage_model.dart';

/// State class for the Pokemon Detail Screen
class PokemonDetailState extends BaseState {
  // Pokemon data
  final Pokemon? pokemon;
  final Map<String, dynamic>? speciesData;
  final Map<String, dynamic>? evolutionData;
  final List<EvolutionStage> evolutionStages;

  // Identifiers
  final String currentPokemonId;
  final String currentPokemonName;

  // Tab selection
  final int selectedTabIndex;

  const PokemonDetailState({
    super.isLoading = false,
    super.error,
    super.stackTrace,
    this.pokemon,
    this.speciesData,
    this.evolutionData,
    this.evolutionStages = const [],
    this.currentPokemonId = '',
    this.currentPokemonName = '',
    this.selectedTabIndex = 0,
  });

  @override
  PokemonDetailState copyWith({
    bool? isLoading,
    Object? error,
    StackTrace? stackTrace,
    bool clearError = false,
    Pokemon? pokemon,
    Map<String, dynamic>? speciesData,
    Map<String, dynamic>? evolutionData,
    List<EvolutionStage>? evolutionStages,
    String? currentPokemonId,
    String? currentPokemonName,
    int? selectedTabIndex,
  }) {
    return PokemonDetailState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      stackTrace: clearError ? null : stackTrace ?? this.stackTrace,
      pokemon: pokemon ?? this.pokemon,
      speciesData: speciesData ?? this.speciesData,
      evolutionData: evolutionData ?? this.evolutionData,
      evolutionStages: evolutionStages ?? this.evolutionStages,
      currentPokemonId: currentPokemonId ?? this.currentPokemonId,
      currentPokemonName: currentPokemonName ?? this.currentPokemonName,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
    );
  }

  // Helper method to get color based on Pokemon's type
  String? get primaryTypeName => pokemon?.types?.firstOrNull?.type.name;

  // Get a description from species data
  String? get description {
    if (speciesData == null ||
        speciesData!['flavor_text_entries'] == null ||
        speciesData!['flavor_text_entries'].isEmpty) {
      return null;
    }

    // Try to find an English description first
    for (final entry in speciesData!['flavor_text_entries']) {
      if (entry['language']['name'] == 'en') {
        return entry['flavor_text']
            .toString()
            .replaceAll('\n', ' ')
            .replaceAll('\f', ' ');
      }
    }

    // Fallback to the first entry
    return speciesData!['flavor_text_entries'][0]['flavor_text']
        .toString()
        .replaceAll('\n', ' ')
        .replaceAll('\f', ' ');
  }

  // Get genus (category) from species data
  String? get category {
    if (speciesData == null ||
        speciesData!['genera'] == null ||
        speciesData!['genera'].isEmpty) {
      return null;
    }

    // Try to find an English genus first
    for (final entry in speciesData!['genera']) {
      if (entry['language']['name'] == 'en') {
        return entry['genus'];
      }
    }

    // Fallback to the first entry
    return speciesData!['genera'][0]['genus'];
  }
}
