import 'package:flutter/material.dart';
import '../../core/base/base_provider.dart';
import '../../data/datasource/models/api_response_model.dart';
import '../../data/datasource/models/pokemon_model.dart';
import '../../data/datasource/network/service/pokemon_service.dart';

class HomeProvider extends BaseProvider {
  // Service dan repository
  final PokemonService _pokemonService = PokemonService();

  // Controllers
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  // UI state
  bool _showTypeIcons = false;
  bool get showTypeIcons => _showTypeIcons;

  void toggleTypeIcons() {
    _showTypeIcons = !_showTypeIcons;
    notifyListeners();
  }

  // Data state
  List<ResourceListItem> _pokemonList = [];
  List<ResourceListItem> get pokemonList => _pokemonList;

  List<ResourceListItem> _pokemonTypes = [];
  List<ResourceListItem> get pokemonTypes => _pokemonTypes;

  // Filtered list
  List<ResourceListItem> _filteredPokemonList = [];
  List<ResourceListItem> get filteredPokemonList =>
      _filteredPokemonList.isEmpty && _activeTypeFilter == null
          ? _pokemonList
          : _filteredPokemonList;

  // Pagination state
  int _offset = 0;
  final int _limit = 20;
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

  @override
  void onClose() {
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
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
      _offset = 0;
      _pokemonList = [];
      _hasMoreData = true;
      _filteredPokemonList = [];
      _activeTypeFilter = null;
      notifyListeners();
    }

    // Jangan load lagi jika sudah tidak ada data lagi atau sedang loading
    if (!_hasMoreData || (_isLoading && !refresh)) {
      return;
    }

    await runAsync('loadPokemonList', () async {
      _isLoading = true;
      _hasError = false;

      try {
        final response = await _pokemonService.getPokemonList(offset: _offset);

        // Update pagination state
        _hasMoreData = response.hasMore;
        _offset = response.nextOffset ?? _offset;

        // Add new Pokemon to the list
        _pokemonList = [..._pokemonList, ...response.results];

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
    });
  }

  // Load lebih banyak Pokemon (infinite scroll)
  Future<void> loadMorePokemon() async {
    if (_isLoading || !_hasMoreData || _activeTypeFilter != null) {
      return;
    }

    await loadPokemonList();
  }

  // Load daftar tipe Pokemon
  Future<void> loadPokemonTypes() async {
    await runAsync('loadPokemonTypes', () async {
      try {
        final response = await _pokemonService.getPokemonTypes();
        _pokemonTypes = response.results;
      } catch (e) {
        logger.e('Error loading Pokemon types: $e');
        // Don't set hasError to true as this is not a critical failure
      }
    });
  }

  // Filter Pokemon berdasarkan tipe
  Future<void> filterByType(String? typeName) async {
    if (typeName == _activeTypeFilter) {
      // Jika tipe yang sama diklik lagi, hapus filter
      _activeTypeFilter = null;
      _filteredPokemonList = [];
      notifyListeners();
      return;
    }

    await runAsync('filterByType', () async {
      _isLoading = true;
      _activeTypeFilter = typeName;

      try {
        if (typeName == null) {
          _filteredPokemonList = [];
        } else {
          await _filterByType(typeName);
        }
        _isLoading = false;
      } catch (e) {
        _isLoading = false;
        logger.e('Error filtering Pokemon by type: $e');
      }
    });
  }

  // Helper method untuk filter berdasarkan tipe
  Future<void> _filterByType(String typeName) async {
    final pokemonByType = await _pokemonService.getPokemonByType(typeName);
    _filteredPokemonList = pokemonByType;

    // Apply search if query exists
    if (_searchQuery.isNotEmpty) {
      _filterBySearch(_searchQuery);
    }
  }

  // Filter Pokemon berdasarkan pencarian nama
  void searchPokemon(String query) {
    _searchQuery = query.toLowerCase();
    _filterBySearch(_searchQuery);
    notifyListeners();
  }

  // Helper method untuk filter berdasarkan pencarian
  void _filterBySearch(String query) {
    if (query.isEmpty) {
      if (_activeTypeFilter != null) {
        // Jika ada filter tipe, kembalikan ke filtered list sebelumnya
        runAsync('reapplyTypeFilter', () async {
          await _filterByType(_activeTypeFilter!);
        });
      } else {
        _filteredPokemonList = [];
      }
      return;
    }

    final sourceList =
        _activeTypeFilter != null ? _filteredPokemonList : _pokemonList;

    _filteredPokemonList = sourceList
        .where((pokemon) =>
            pokemon.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Reset semua filter
  void resetFilters() {
    _activeTypeFilter = null;
    _filteredPokemonList = [];
    _searchQuery = '';
    searchController.clear();
    notifyListeners();
  }

  // Get Pokemon detail by ID or name
  Future<Pokemon> getPokemonDetail(String idOrName) async {
    return await runAsyncWithResult('getPokemonDetail', () async {
      return await _pokemonService.getPokemonDetail(idOrName);
    });
  }
}
