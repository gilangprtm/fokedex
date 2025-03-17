import '../../core/base/base_provider.dart';
import '../../data/datasource/models/pokemon_model.dart';
import '../../data/datasource/models/evolution_stage_model.dart';
import '../../data/datasource/network/service/pokemon_service.dart';
import '../../data/datasource/network/repository/pokemon_repository.dart';

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

  // Untuk menyimpan ID Pokemon yang sedang ditampilkan
  String _currentPokemonId = '';
  String get currentPokemonId => _currentPokemonId;

  // Data species Pokemon
  Map<String, dynamic>? _speciesData;
  Map<String, dynamic>? get speciesData => _speciesData;

  // Data evolusi Pokemon
  Map<String, dynamic>? _evolutionData;
  Map<String, dynamic>? get evolutionData => _evolutionData;

  // Constructor with optional parameter for initialization
  DetailProvider({String? pokemonId}) {
    if (pokemonId != null) {
      loadPokemonDetail(pokemonId);
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Any additional initialization
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

      try {
        // Load Pokemon detail
        _pokemon = await _pokemonService.getPokemonDetail(idOrName);

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
    });
  }

  // Load species data
  Future<void> _loadSpeciesData(String speciesUrl) async {
    try {
      // Extract ID from species URL
      final uri = Uri.parse(speciesUrl);
      final pathSegments = uri.pathSegments;
      final speciesId = pathSegments[pathSegments.length - 2];

      // Load species data from repository
      _speciesData = await _repository.getPokemonSpecies(speciesId);

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
  }

  // Load evolution data
  Future<void> _loadEvolutionData(String evolutionUrl) async {
    try {
      _evolutionData = await _repository.getEvolutionChain(evolutionUrl);
    } catch (e) {
      logger.e('Error loading evolution data: $e');
      // Don't set hasError as this is not critical
    }
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

  // Parse evolution chain data
  List<EvolutionStage> parseEvolutionChain() {
    List<EvolutionStage> evolutionStages = [];

    if (_evolutionData == null || !_evolutionData!.containsKey('chain')) {
      return evolutionStages;
    }

    try {
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
        evolutionStages.add(EvolutionStage(
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
            _extractEvolutionDetails(currentChain['evolves_to'][0]);

        // Move to next evolution
        currentChain = currentChain['evolves_to'][0];
      }
    } catch (e) {
      logger.e('Error parsing evolution chain: $e');
    }

    return evolutionStages;
  }

  // Extract evolution details like trigger, min_level, etc.
  List<String> _extractEvolutionDetails(Map<String, dynamic> evolution) {
    List<String> details = [];

    try {
      if (evolution.containsKey('evolution_details') &&
          evolution['evolution_details'] is List &&
          evolution['evolution_details'].isNotEmpty) {
        final evolutionDetail = evolution['evolution_details'][0];

        // Level up evolution
        if (evolutionDetail['min_level'] != null) {
          details.add('Level ${evolutionDetail['min_level']}');
        }

        // Evolution by item
        if (evolutionDetail['item'] != null) {
          String itemName =
              evolutionDetail['item']['name'].toString().replaceAll('-', ' ');
          details.add('Use ${_capitalizeWords(itemName)}');
        }

        // Evolution by trade
        if (evolutionDetail['trade_species'] != null) {
          details.add(
              'Trade with ${_capitalizeWords(evolutionDetail['trade_species']['name'])}');
        }

        // Evolution by happiness
        if (evolutionDetail['min_happiness'] != null) {
          details.add('Happiness (${evolutionDetail['min_happiness']})');
        }

        // Evolution by trigger
        if (evolutionDetail['trigger'] != null &&
            details.isEmpty &&
            evolutionDetail['trigger']['name'] != 'level-up') {
          details.add(_capitalizeWords(evolutionDetail['trigger']['name']
              .toString()
              .replaceAll('-', ' ')));
        }
      }
    } catch (e) {
      logger.e('Error extracting evolution details: $e');
    }

    return details;
  }

  String _capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((word) =>
            word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : word)
        .join(' ');
  }

  // Reset provider state
  void reset() {
    _pokemon = null;
    _speciesData = null;
    _evolutionData = null;
    _currentPokemonId = '';
    _hasError = false;
    _errorMessage = '';
  }
}
