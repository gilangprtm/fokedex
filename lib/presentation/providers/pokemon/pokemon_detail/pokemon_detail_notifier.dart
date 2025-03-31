import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/base/base_state_notifier.dart';
import '../../../../core/utils/mahas.dart';
import '../../../../data/datasource/network/service/pokemon_service.dart';
import '../../../../data/datasource/network/repository/pokemon_repository.dart';
import '../../../../data/models/pokemon_model.dart';
import '../../../../data/models/evolution_stage_model.dart';
import 'pokemon_detail_state.dart';

class PokemonDetailNotifier extends BaseStateNotifier<PokemonDetailState> {
  final PokemonService _pokemonService;
  final PokemonRepository _pokemonRepository;

  // Additional states to manage loading state granularity
  bool _isLoadingEvolution = false;

  PokemonDetailNotifier({
    required PokemonDetailState initialState,
    required Ref ref,
    required PokemonService pokemonService,
    required PokemonRepository pokemonRepository,
  })  : _pokemonService = pokemonService,
        _pokemonRepository = pokemonRepository,
        super(initialState, ref);

  @override
  void onInit() {
    super.onInit();
    getArgs();
  }

  void getArgs() {
    final args = Mahas.arguments();
    if (args.isNotEmpty) {
      final String id = args['id'] ?? '';
      final String name = args['name'] ?? '';

      state = state.copyWith(
        currentPokemonId: id,
        currentPokemonName: name,
      );

      loadPokemonDetail(id);
    }
  }

  /// Loads the Pokemon details
  Future<void> loadPokemonDetail(String idOrName) async {
    if (idOrName.isEmpty) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final pokemon = await _pokemonService.getPokemonDetail(idOrName);

      state = state.copyWith(
        pokemon: pokemon,
        isLoading: false,
      );

      // After loading the basic details, load additional data
      await _loadSpeciesData(pokemon.species ?? '');
    } catch (e, stack) {
      state = state.copyWith(
        isLoading: false,
        error: e,
        stackTrace: stack,
      );
    }
  }

  /// Loads species data from the API
  Future<void> _loadSpeciesData(String speciesUrl) async {
    if (speciesUrl.isEmpty) return;

    try {
      final speciesData = await _pokemonRepository.getDataFromUrl(speciesUrl);

      state = state.copyWith(
        speciesData: speciesData,
      );

      // Check if there's an evolution chain to load
      if (speciesData != null &&
          speciesData['evolution_chain'] != null &&
          speciesData['evolution_chain']['url'] != null) {
        await _loadEvolutionData(speciesData['evolution_chain']['url']);
      }
    } catch (e) {
      // Just log the error, don't update state
      logger.e('Error loading species data: $e', tag: logTag);
    }
  }

  /// Loads evolution data from the API
  Future<void> _loadEvolutionData(String evolutionUrl) async {
    // Update evolution loading state
    _isLoadingEvolution = true;
    state = state.copyWith();

    try {
      final evolutionData =
          await _pokemonRepository.getDataFromUrl(evolutionUrl);

      if (evolutionData != null && evolutionData['chain'] != null) {
        final evolutionStages =
            _precomputeEvolutionChain(evolutionData['chain']);

        state = state.copyWith(
          evolutionData: evolutionData,
          evolutionStages: evolutionStages,
        );
      }
    } catch (e) {
      logger.e('Error loading evolution data: $e', tag: logTag);
    } finally {
      _isLoadingEvolution = false;
      state = state.copyWith();
    }
  }

  /// Precomputes evolution stages from the evolution chain data
  List<EvolutionStage> _precomputeEvolutionChain(Map<String, dynamic> chain) {
    List<EvolutionStage> stages = [];

    try {
      // Extract data from the first form (base form)
      final baseFormUrl = chain['species']['url'] as String;
      final baseFormId = _extractIdFromUrl(baseFormUrl);
      final baseFormName = chain['species']['name'] as String;

      // Add base form to stages
      stages.add(
        EvolutionStage(
          name: baseFormName,
          id: baseFormId,
          imageUrl: Pokemon.getOfficialArtworkUrl(baseFormId),
          evolutionDetails: const [],
        ),
      );

      // Process subsequent evolutions
      if (chain['evolves_to'] != null && chain['evolves_to'].isNotEmpty) {
        _extractEvolutionDetailsSync(chain['evolves_to'], stages);
      }
    } catch (e) {
      logger.e('Error computing evolution chain: $e', tag: logTag);
    }

    return stages;
  }

  /// Extracts evolution details synchronously (avoid setState during build)
  void _extractEvolutionDetailsSync(
      List<dynamic> evolvesTo, List<EvolutionStage> stages) {
    for (final evolution in evolvesTo) {
      final speciesUrl = evolution['species']['url'] as String;
      final pokemonId = _extractIdFromUrl(speciesUrl);
      final pokemonName = evolution['species']['name'] as String;

      // Extract evolution details
      List<String> evolutionDetails = [];
      if (evolution['evolution_details'] != null &&
          evolution['evolution_details'].isNotEmpty) {
        final details = evolution['evolution_details'][0];

        // Level-based evolution
        if (details['min_level'] != null) {
          evolutionDetails.add('Level ${details['min_level']}');
        }

        // Item-based evolution
        if (details['item'] != null) {
          evolutionDetails
              .add('Use ${_formatNameSync(details['item']['name'])}');
        }

        // Happiness-based evolution
        if (details['min_happiness'] != null) {
          evolutionDetails.add('Happiness ${details['min_happiness']}+');
        }

        // Time-based evolution
        if (details['time_of_day'] != null &&
            details['time_of_day'].isNotEmpty) {
          evolutionDetails.add('During ${details['time_of_day']}');
        }
      }

      // Add to stages
      stages.add(
        EvolutionStage(
          name: pokemonName,
          id: pokemonId,
          imageUrl: Pokemon.getOfficialArtworkUrl(pokemonId),
          evolutionDetails: evolutionDetails,
        ),
      );

      // Process next evolution if exists
      if (evolution['evolves_to'] != null &&
          evolution['evolves_to'].isNotEmpty) {
        _extractEvolutionDetailsSync(evolution['evolves_to'], stages);
      }
    }
  }

  /// Formats name (replaces hyphens with spaces and capitalizes each word)
  String _formatNameSync(String name) {
    return name
        .split('-')
        .map((part) => part.isNotEmpty
            ? '${part[0].toUpperCase()}${part.substring(1)}'
            : '')
        .join(' ');
  }

  /// Extract Pokemon ID from URL
  String _extractIdFromUrl(String url) {
    final regex = RegExp(r'/(\d+)/$');
    final match = regex.firstMatch(url);
    return match?.group(1) ?? '';
  }

  /// Sets the selected tab index
  void setSelectedTab(int index) {
    state = state.copyWith(selectedTabIndex: index);
  }

  // Getter to expose evolution loading state
  bool get isLoadingEvolution => _isLoadingEvolution;
}
