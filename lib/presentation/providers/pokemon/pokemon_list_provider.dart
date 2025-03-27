import 'package:flutter/material.dart';
import '../../../core/base/base_provider.dart';
import '../../../data/datasource/local/services/local_pokemon_service.dart';
import '../../../data/datasource/models/api_response_model.dart';
import '../../../data/datasource/models/pokemon_model.dart';
import '../../../data/datasource/models/type_model.dart';
import '../../../data/datasource/network/service/pokemon_service.dart';

class PokemonListProvider extends BaseProvider {
  // Service dan repository
  final PokemonService _pokemonService = PokemonService();
  final LocalPokemonService _localService = LocalPokemonService();

  // Controllers
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  // UI state
  bool _showTypeIcons = false;
  bool get showTypeIcons => _showTypeIcons;

  void toggleTypeIcons() {
    run('toggleTypeIcons', () {
      _showTypeIcons = !_showTypeIcons;
    }, properties: ['showTypeIcons']);
  }

  // Data state
  List<ResourceListItem> _pokemonList = [];
  List<ResourceListItem> get pokemonList => List.unmodifiable(_pokemonList);

  // Map to store Pokemon details
  final Map<int, Pokemon> _pokemonDetails = {};
  Pokemon? getPokemonDetails(int id) => _pokemonDetails[id];

  List<ResourceListItem> _pokemonTypes = [];
  List<ResourceListItem> get pokemonTypes => List.unmodifiable(_pokemonTypes);

  // Filtered list
  List<ResourceListItem> _filteredPokemonList = [];
  List<ResourceListItem> get filteredPokemonList =>
      _filteredPokemonList.isEmpty && _activeTypeFilter == null
          ? List.unmodifiable(_pokemonList)
          : List.unmodifiable(_filteredPokemonList);

  // Pagination state
  int _offset = 0;
  bool _hasMoreData = true;
  bool get hasMoreData => _hasMoreData;

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasError = false;
  bool get hasError => _hasError;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // Active filters
  String? _activeTypeFilter;
  String? get activeTypeFilter => _activeTypeFilter;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // Lifecycle methods
  @override
  void onInit() {
    super.onInit();
    _setupScrollListener();
    loadInitialData();
  }

  // Setup scroll controller listener
  void _setupScrollListener() {
    scrollController.addListener(() {
      // Check if we're near the bottom of the list
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        // Load more Pokemon
        loadMorePokemon();
      }
    });
  }

  // Handle search text changes
  void onSearchChanged(String value) {
    searchPokemon(value);
  }

  // Clear search
  void clearSearch() {
    searchController.clear();
    searchPokemon('');
  }

  // Load initial data
  Future<void> loadInitialData() async {
    await runAsync('loadInitialData', () async {
      await Future.wait([
        loadPokemonList(),
        loadPokemonTypes(),
      ]);
    });
  }

  // Load daftar Pokemon dengan pagination
  Future<void> loadPokemonList({bool refresh = false}) async {
    if (refresh) {
      run('resetPokemonList', () {
        _offset = 0;
        _pokemonList = [];
        _hasMoreData = true;
        _filteredPokemonList = [];
        _activeTypeFilter = null;
        _pokemonDetails.clear(); // Clear cached details on refresh
      }, properties: [
        'pokemonList',
        'filteredPokemonList',
        'activeTypeFilter',
        'hasMoreData'
      ]);
    }

    // Jangan load lagi jika sudah tidak ada data lagi atau sedang loading
    if (!_hasMoreData || (_isLoading && !refresh)) {
      return;
    }

    await runAsync('loadPokemonList', () async {
      _isLoading = true;
      _hasError = false;

      // Notify loading state immediately
      notifyPropertyListeners('isLoading');

      try {
        // Periksa apakah data tersedia di penyimpanan lokal
        final localData = await _localService.getPokemonList();

        if (localData.isNotEmpty) {
          // Gunakan data dari penyimpanan lokal
          _pokemonList = localData;
          _hasMoreData = false; // Semua data sudah diambil

          // Load detail untuk Pokemon yang ada di daftar
          await _loadPokemonDetailsFromLocalStorage();

          _isLoading = false;
        } else {
          // Fallback ke API jika data lokal tidak ada
          final response =
              await _pokemonService.getPokemonList(offset: _offset);

          // Update pagination state
          _hasMoreData = response.hasMore;
          _offset = response.nextOffset ?? _offset;

          // Add new Pokemon to the list
          _pokemonList = [..._pokemonList, ...response.results];

          // Load details for new Pokemon
          for (var pokemon in response.results) {
            if (!_pokemonDetails.containsKey(pokemon.id)) {
              try {
                final details = await _pokemonService
                    .getPokemonDetail(pokemon.id.toString());
                _pokemonDetails[pokemon.id] = details;

                // Notify periodically for better UX when loading many pokemon
                if (_pokemonDetails.length % 5 == 0) {
                  notifyPropertyListeners('pokemonDetails');
                }
              } catch (e) {
                logger.e('Error loading details for Pokemon ${pokemon.id}: $e');
              }
            }
          }
        }

        // Apply filtering if a type filter is active
        if (_activeTypeFilter != null) {
          await _filterByType(_activeTypeFilter!);
        }

        // Apply search if query exists
        if (_searchQuery.isNotEmpty) {
          _filterBySearch(_searchQuery);
        }

        _isLoading = false;
      } catch (e) {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
        logger.e('Error loading Pokemon list: $e');
      }
    }, properties: [
      'isLoading',
      'hasError',
      'errorMessage',
      'pokemonList',
      'filteredPokemonList',
      'hasMoreData'
    ]);
  }

  /// Load Pokemon details from local storage
  Future<void> _loadPokemonDetailsFromLocalStorage() async {
    try {
      int processedCount = 0;
      bool needsNotify = false;

      for (var pokemon in _pokemonList) {
        if (!_pokemonDetails.containsKey(pokemon.id)) {
          final detail = await _localService.getPokemonDetail(pokemon.id);
          processedCount++;

          if (detail != null) {
            _pokemonDetails[pokemon.id] = detail;
            needsNotify = true;

            // Notify periodically while loading many pokemon details
            if (processedCount % 10 == 0) {
              notifyPropertyListeners('pokemonDetails');
              needsNotify = false;
            }
          }
        }
      }

      if (needsNotify) {
        notifyPropertyListeners('pokemonDetails');
      }
    } catch (e) {
      logger.e('Error loading Pokemon details from local storage: $e');
    }
  }

  // Load more Pokemon dengan pagination
  Future<void> loadMorePokemon() async {
    // Skip if already loading, no more data, or already at the end
    if (_isLoading || !_hasMoreData || _activeTypeFilter != null) {
      return;
    }

    await loadPokemonList();
  }

  // Load daftar tipe Pokemon
  Future<void> loadPokemonTypes() async {
    if (_pokemonTypes.isNotEmpty) {
      return;
    }

    await runAsync('loadPokemonTypes', () async {
      try {
        final response = await _pokemonService.getPokemonTypes();
        _pokemonTypes = response.results;
      } catch (e) {
        logger.e('Error loading Pokemon types: $e');
      }
    }, properties: ['pokemonTypes']);
  }

  // Filter Pokemon berdasarkan tipe
  Future<void> filterByType(String? typeName) async {
    await runAsync('filterByType', () async {
      // Jika memilih tipe yang sama lagi, anggap sebagai toggle
      if (_activeTypeFilter == typeName && typeName != null) {
        _activeTypeFilter = null;
        _filteredPokemonList = [];
        return;
      }

      _isLoading = true;
      notifyPropertyListeners('isLoading');

      _activeTypeFilter = typeName;

      // Reset filtered list if no filter (All)
      if (typeName == null) {
        _filteredPokemonList = [];

        // Jika ada search query, terapkan filter pencarian pada daftar lengkap
        if (_searchQuery.isNotEmpty) {
          _filterBySearch(_searchQuery);
        }

        _isLoading = false;
        return;
      }

      await _filterByType(typeName);
    }, properties: ['activeTypeFilter', 'filteredPokemonList', 'isLoading']);
  }

  // Internal method untuk filter berdasarkan tipe
  Future<void> _filterByType(String typeName) async {
    try {
      _isLoading = true;
      notifyPropertyListeners('isLoading');

      // Get Pokemon of this type
      final typeDetail = await _pokemonService.getPokemonTypeDetail(typeName);
      final TypeDetail typeData = TypeDetail.fromJson(typeDetail);

      if (typeData.pokemon != null) {
        // Map to our ResourceListItem format
        _filteredPokemonList = typeData.pokemon!.map((p) {
          final idMatch = RegExp(r'\/(\d+)\/$').firstMatch(p.pokemon.url);
          final id = idMatch != null ? int.parse(idMatch.group(1)!) : 0;

          return ResourceListItem(
            name: p.pokemon.name,
            url: p.pokemon.url,
          );
        }).toList();

        // Sort by ID
        _filteredPokemonList.sort((a, b) => a.id.compareTo(b.id));
      } else {
        // Jika tidak ada pokemon untuk tipe ini
        _filteredPokemonList = [];
      }

      // Apply search filter if needed
      if (_searchQuery.isNotEmpty) {
        _filterBySearch(_searchQuery);
      }
    } catch (e) {
      logger.e('Error filtering by type $typeName: $e');
      _filteredPokemonList = [];
    } finally {
      _isLoading = false;
      notifyPropertyListeners('isLoading');
    }
  }

  // Search Pokemon by name
  void searchPokemon(String query) {
    run('searchPokemon', () {
      _isLoading = true;
      notifyPropertyListeners('isLoading');

      _searchQuery = query.toLowerCase();

      if (query.isEmpty) {
        // If search is cleared, just reset filter if type filter is not active
        if (_activeTypeFilter == null) {
          _filteredPokemonList = [];
        } else {
          // Reapply type filter without search
          _filterByType(_activeTypeFilter!);
          return; // _filterByType akan mengatur isLoading = false
        }
      } else {
        // Apply search filter
        _filterBySearch(query);
      }

      _isLoading = false;
    }, properties: ['searchQuery', 'filteredPokemonList', 'isLoading']);
  }

  // Private method to filter by search query
  void _filterBySearch(String query) {
    final lowercaseQuery = query.toLowerCase();

    if (_pokemonList.isEmpty) {
      // Jika data pokemons belum dimuat, muat data terlebih dahulu
      loadPokemonList();
      return;
    }

    // List to filter - either all Pokemon or type-filtered list
    final listToFilter =
        _activeTypeFilter != null ? _filteredPokemonList : _pokemonList;

    // Filter by query
    _filteredPokemonList = listToFilter.where((pokemon) {
      return pokemon.name.toLowerCase().contains(lowercaseQuery) ||
          pokemon.id.toString().contains(lowercaseQuery);
    }).toList();

    // Notifikasi listener bahwa filtered list telah diupdate
    notifyPropertyListeners('filteredPokemonList');
  }

  // Reset semua filter
  void resetFilters() {
    run('resetFilters', () {
      _isLoading = true;
      notifyPropertyListeners('isLoading');

      _activeTypeFilter = null;
      _searchQuery = '';
      _filteredPokemonList = [];
      searchController.clear();

      _isLoading = false;
    }, properties: [
      'activeTypeFilter',
      'searchQuery',
      'filteredPokemonList',
      'isLoading'
    ]);
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }
}
