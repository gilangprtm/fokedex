import 'package:flutter_pokedex/core/utils/mahas.dart';
import '../../../core/base/base_provider.dart';
import '../../../data/models/pokemon_model.dart';
import '../../../data/models/evolution_stage_model.dart';
import '../../../data/datasource/network/service/pokemon_service.dart';
import '../../../data/datasource/network/repository/pokemon_repository.dart';

class PokemonDetailProvider extends BaseProvider {
  // Service untuk mengambil data Pokemon
  final PokemonService _pokemonService = PokemonService();
  // Repository untuk akses langsung ke API jika diperlukan
  final PokemonRepository _repository = PokemonRepository();

  // State untuk detail Pokemon
  Pokemon? _pokemon;
  Pokemon? get pokemon => _pokemon;

  // State untuk loading dan error
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasError = false;
  bool get hasError => _hasError;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // Untuk menyimpan ID dan Nama Pokemon yang sedang ditampilkan
  String _currentPokemonId = '';
  String get currentPokemonId => _currentPokemonId;
  String _currentPokemonName = '';
  String get currentPokemonName => _currentPokemonName;

  // Data species Pokemon
  Map<String, dynamic>? _speciesData;
  Map<String, dynamic>? get speciesData => _speciesData;

  // Data evolusi Pokemon
  Map<String, dynamic>? _evolutionData;
  Map<String, dynamic>? get evolutionData => _evolutionData;

  // Precomputed evolution stages
  List<EvolutionStage> _evolutionStages = [];
  List<EvolutionStage> get evolutionStages => _evolutionStages;

  @override
  void onInit() {
    super.onInit();
    getArgs();
    loadPokemonDetail(_currentPokemonId);
  }

  void getArgs() {
    run('getArgs', () {
      _currentPokemonId = Mahas.argument<String>('id') ?? '';
      _currentPokemonName = Mahas.argument<String>('name') ?? '';
    }, properties: ['currentPokemonId', 'currentPokemonName']);
  }

  // Load detail Pokemon berdasarkan ID atau nama
  Future<void> loadPokemonDetail(String idOrName) async {
    // Skip if already loading the same Pokemon
    if (_isLoading && _currentPokemonId == idOrName) {
      return;
    }

    await runAsync('loadPokemonDetail', () async {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
      _currentPokemonId = idOrName;
      _evolutionStages = []; // Reset evolution stages

      // Notify immediately for loading state
      notifyPropertyListeners('isLoading');

      try {
        // Load Pokemon detail
        _pokemon = await _pokemonService.getPokemonDetail(idOrName.toString());

        // Notify after main data is loaded for immediate UI update
        notifyPropertyListeners('pokemon');

        // Load species data if available
        if (_pokemon?.species != null) {
          await _loadSpeciesData(_pokemon!.species!);
        }

        _isLoading = false;
      } catch (e) {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to load Pokemon detail: $e';
        logger.e(_errorMessage);
      }
    }, properties: [
      'isLoading',
      'hasError',
      'errorMessage',
      'pokemon',
      'currentPokemonId',
      'evolutionStages'
    ]);
  }

  // Load species data
  Future<void> _loadSpeciesData(String speciesUrl) async {
    await runAsync('loadSpeciesData', () async {
      try {
        // Extract ID from species URL
        final uri = Uri.parse(speciesUrl);
        final pathSegments = uri.pathSegments;
        final speciesId = pathSegments[pathSegments.length - 2];

        // Load species data from repository
        _speciesData = await _repository.getPokemonSpecies(speciesId);

        // Notify that species data has been loaded
        notifyPropertyListeners('speciesData');

        // If species has evolution chain, load it
        if (_speciesData != null &&
            _speciesData!.containsKey('evolution_chain') &&
            _speciesData!['evolution_chain'] != null) {
          final evolutionUrl = _speciesData!['evolution_chain']['url'];
          await _loadEvolutionData(evolutionUrl);
        }
      } catch (e) {
        logger.e('Error loading species data: $e');
        // Don't set hasError as this is not critical
      }
    }, properties: ['speciesData']);
  }

  // Load evolution data
  Future<void> _loadEvolutionData(String evolutionUrl) async {
    await runAsync('loadEvolutionData', () async {
      try {
        _evolutionData = await _repository.getEvolutionChain(evolutionUrl);

        // Precompute evolution stages immediately after loading the data
        if (_evolutionData != null && _evolutionData!.containsKey('chain')) {
          _precomputeEvolutionChain();
        }
      } catch (e) {
        logger.e('Error loading evolution data: $e');
        // Don't set hasError as this is not critical
      }
    }, properties: ['evolutionData', 'evolutionStages']);
  }

  // Precompute evolution chain data instead of doing it during build
  void _precomputeEvolutionChain() {
    try {
      List<EvolutionStage> stages = [];

      if (_evolutionData == null || !_evolutionData!.containsKey('chain')) {
        _evolutionStages = stages;
        return;
      }

      // Start with the base form
      Map<String, dynamic> currentChain = _evolutionData!['chain'];
      List<String> previousEvolutionDetails = [];

      while (true) {
        // Get the species details
        final speciesName = currentChain['species']['name'];
        final speciesUrl = currentChain['species']['url'];

        // Extract ID from URL
        final uri = Uri.parse(speciesUrl);
        final pathSegments = uri.pathSegments;
        final speciesId = pathSegments[pathSegments.length - 2];

        // Add current species to evolution stages
        stages.add(EvolutionStage(
          name: speciesName,
          id: speciesId,
          imageUrl:
              'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$speciesId.png',
          evolutionDetails: previousEvolutionDetails,
        ));

        // Check if there's next evolution
        if (currentChain['evolves_to'] == null ||
            currentChain['evolves_to'].isEmpty) {
          break;
        }

        // Process evolution details for the next stage
        previousEvolutionDetails =
            _extractEvolutionDetailsSync(currentChain['evolves_to'][0]);

        // Move to next evolution
        currentChain = currentChain['evolves_to'][0];
      }

      _evolutionStages = stages;
    } catch (e) {
      logger.e('Error precomputing evolution chain: $e');
      _evolutionStages = [];
    }
  }

  // Extract evolution details synchronously without using runWithResult
  List<String> _extractEvolutionDetailsSync(
      Map<String, dynamic> evolutionData) {
    List<String> details = [];

    try {
      final evoDetails = evolutionData['evolution_details'][0];

      // Check various evolution methods
      if (evoDetails['min_level'] != null && evoDetails['min_level'] > 0) {
        details.add('Level ${evoDetails['min_level']}');
      }

      if (evoDetails['item'] != null) {
        details.add('Use ${_formatNameSync(evoDetails['item']['name'])}');
      }

      if (evoDetails['trigger'] != null &&
          evoDetails['trigger']['name'] == 'trade') {
        details.add('Trade');
      }

      if (evoDetails['held_item'] != null) {
        details.add(
            'Hold ${_formatNameSync(evoDetails['held_item']['name'])} while trading');
      }

      if (evoDetails['known_move'] != null) {
        details
            .add('Know ${_formatNameSync(evoDetails['known_move']['name'])}');
      }

      if (evoDetails['min_happiness'] != null &&
          evoDetails['min_happiness'] > 0) {
        details.add('Happiness ≥ ${evoDetails['min_happiness']}');
      }

      if (evoDetails['time_of_day'] != null &&
          evoDetails['time_of_day'].isNotEmpty) {
        details.add('During ${evoDetails['time_of_day']}time');
      }

      // If no specific details found, it might be a special case
      if (details.isEmpty) {
        details.add('Special evolution');
      }
    } catch (e) {
      logger.e('Error extracting evolution details: $e');
    }

    return details;
  }

  // Format name synchronously
  String _formatNameSync(String name) {
    final words = name.split('-');
    return words
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  // Get description from species data
  String getDescription() {
    if (_speciesData == null) {
      return 'No description available.';
    }

    // Get the flavor text entries
    final flavorTextEntries =
        _speciesData!['flavor_text_entries'] as List<dynamic>?;
    if (flavorTextEntries == null || flavorTextEntries.isEmpty) {
      return 'No description available.';
    }

    // Find English flavor text
    final englishEntries = flavorTextEntries
        .where((entry) => entry['language']['name'] == 'en')
        .toList();

    if (englishEntries.isEmpty) {
      return 'No English description available.';
    }

    // Get the most recent English flavor text
    String flavorText = englishEntries.last['flavor_text'];

    // Clean up the text by removing newlines and multiple spaces
    flavorText = flavorText.replaceAll('\n', ' ').replaceAll('\f', ' ');
    flavorText = flavorText.replaceAll(RegExp(r'\s{2,}'), ' ');

    return flavorText;
  }

  // Reset provider state
  void reset() {
    _pokemon = null;
    _speciesData = null;
    _evolutionData = null;
    _evolutionStages = [];
    _currentPokemonId = '';
    _hasError = false;
    _errorMessage = '';
  }
}
