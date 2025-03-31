import '../../../../core/base/base_state_notifier.dart';
import '../../../../data/models/api_response_model.dart';
import '../../../../data/models/pokemon_list_item_model.dart';
import '../../../../data/models/type_model.dart';
import '../../../../data/datasource/local/services/local_pokemon_service.dart';
import '../../../../data/datasource/network/service/pokemon_service.dart';
import 'pokemon_list_state.dart';

/// StateNotifier for the Pokemon List screen
class PokemonListNotifier extends BaseStateNotifier<PokemonListState> {
  // Service and repository
  final PokemonService _pokemonService;
  final LocalPokemonService _localService;

  PokemonListNotifier(
    super.initialState,
    super.ref,
    this._pokemonService,
    this._localService,
  );

  @override
  void onInit() {
    super.onInit();
    _setupScrollListener();
    loadInitialData();
  }

  @override
  void onClose() {
    // Clean up controllers
    if (state.scrollController.hasClients) {
      state.scrollController.removeListener(() {});
    }

    // Set a final state indicating we're cleaning up
    try {
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          clearError: true,
        );
      }
    } catch (e) {
      logger.e("Error while cleaning up state: $e");
    }

    super.onClose();
  }

  // Setup scroll controller listener
  void _setupScrollListener() {
    state.scrollController.addListener(() {
      // Check if we're near the bottom of the list
      if (state.scrollController.position.pixels >=
          state.scrollController.position.maxScrollExtent - 200) {
        // Load more Pokemon
        loadMorePokemon();
      }
    });
  }

  /// Toggle type icons display
  void toggleTypeIcons() {
    state = state.copyWith(showTypeIcons: !state.showTypeIcons);
  }

  /// Handle search text changes
  void onSearchChanged(String value) {
    searchPokemon(value);
  }

  /// Clear search
  void clearSearch() {
    state.searchController.clear();
    searchPokemon('');
  }

  /// Load initial data
  Future<void> loadInitialData() async {
    // Set loading state at the beginning
    setLoading(true);

    await runAsync('loadInitialData', () async {
      try {
        // First load the Pokemon list from local or network

        // Then load the Pokemon types
        loadPokemonTypes();

        await loadPokemonList();
        // Apply filtering if needed
        if (state.activeTypeFilter != null) {
          await _filterByType(state.activeTypeFilter!);
        }

        // Apply search if query exists
        if (state.searchQuery.isNotEmpty) {
          _filterBySearch(state.searchQuery);
        }
      } catch (e) {
        logger.e("Error in loadInitialData: $e");
      }
    });

    // Ensure loading is set to false when complete
    setLoading(false);
  }

  /// Load Pokemon list with pagination
  Future<void> loadPokemonList({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        offset: 0,
        pokemonList: [],
        hasMoreData: true,
        filteredPokemonList: [],
        activeTypeFilter: null,
        clearActiveTypeFilter: true,
        pokemonDetails: {},
      );
    }

    // Force the first load regardless of state conditions
    bool isFirstLoad = state.pokemonList.isEmpty;

    // Don't load more if there are no more Pokemon or if already loading
    if ((!state.hasMoreData || (state.isLoading && !refresh)) && !isFirstLoad) {
      return;
    }

    // Set loading state explicitly before starting the async operation
    setLoading(true);

    await runAsync('loadPokemonList', () async {
      try {
        // Check if data is available in local storage
        final localData = await _localService.getPokemonList();

        if (localData.isNotEmpty) {
          // Use data from local storage
          state = state.copyWith(
            pokemonList: localData,
            hasMoreData: false, // All data already loaded
          );

          // Load details for Pokemon in the list
          await _loadPokemonDetailsFromLocalStorage();
        } else {
          // Fallback to API if local data is not available
          final limit = 20;
          final offset = state.offset;

          final response = await _pokemonService.getPokemonList(
              offset: offset, limit: limit);

          // Map the results to Pokemon objects
          List<ResourceListItem> newItems = response.results;

          // Add to existing list
          List<ResourceListItem> updatedList = [
            ...state.pokemonList,
            ...newItems
          ];

          // Update state with new Pokemon list and pagination info
          state = state.copyWith(
            pokemonList: updatedList,
            offset: offset + limit,
            hasMoreData: response.hasMore,
          );

          // Load details from local storage
          await _loadPokemonDetailsFromLocalStorage();
        }
      } finally {
        // Ensure loading state is reset even if there's an error
        setLoading(false);
      }
    });
  }

  /// Load Pokemon details from local storage
  Future<void> _loadPokemonDetailsFromLocalStorage() async {
    try {
      int processedCount = 0;
      Map<int, PokemonList> updatedDetails = Map.from(state.pokemonDetails);

      for (var pokemon in state.pokemonList) {
        // Check if the notifier is still mounted
        if (!mounted) {
          return;
        }

        if (!updatedDetails.containsKey(pokemon.id)) {
          final detail = await _localService.getPokemonDetailList(pokemon.id);
          processedCount++;

          if (detail != null) {
            updatedDetails[pokemon.id] = detail;

            // Update state periodically for better UX
            if (processedCount % 10 == 0 && mounted) {
              state = state.copyWith(pokemonDetails: updatedDetails);
            }
          }
        }
      }

      // Final update with all details
      if (mounted) {
        state = state.copyWith(pokemonDetails: updatedDetails);
      }
    } catch (e) {
      logger.e('Error loading Pokemon details from local storage: $e');
    }
  }

  /// Load more Pokemon with pagination
  Future<void> loadMorePokemon() async {
    // Skip if already loading, no more data, or type filter is active
    if (state.isLoading ||
        !state.hasMoreData ||
        state.activeTypeFilter != null) {
      return;
    }

    await loadPokemonList();
  }

  /// Load Pokemon types
  Future<void> loadPokemonTypes() async {
    // Skip if types are already loaded
    if (state.pokemonTypes.isNotEmpty) {
      return;
    }

    await runAsync('loadPokemonTypes', () async {
      try {
        // Fetch Pokemon types
        final response = await _pokemonService.getPokemonTypes();

        if (response.results.isNotEmpty) {
          state = state.copyWith(
            pokemonTypes: response.results,
          );
        }
      } catch (e) {
        logger.e('Error loading Pokemon types: $e');
      }
    });
  }

  /// Filter Pokemon by type
  Future<void> filterByType(String? typeName) async {
    await runAsync('filterByType', () async {
      // If selecting the same type again, treat as toggle
      if (state.activeTypeFilter == typeName && typeName != null) {
        state = state.copyWith(
          activeTypeFilter: null,
          clearActiveTypeFilter: true,
          filteredPokemonList: [],
        );
        return;
      }

      setLoading(true);

      state = state.copyWith(activeTypeFilter: typeName);

      // Reset filtered list if no filter (All)
      if (typeName == null) {
        state = state.copyWith(
          filteredPokemonList: [],
          clearActiveTypeFilter: true,
        );

        // If there's a search query, apply search filter to full list
        if (state.searchQuery.isNotEmpty) {
          _filterBySearch(state.searchQuery);
        }

        setLoading(false);
        return;
      }

      await _filterByType(typeName);
    });
  }

  /// Internal method for filtering by type
  Future<void> _filterByType(String typeName) async {
    try {
      setLoading(true);

      // Get Pokemon of this type
      final typeDetail = await _pokemonService.getPokemonTypeDetail(typeName);
      final TypeDetail typeData = TypeDetail.fromJson(typeDetail);

      if (typeData.pokemon != null) {
        // Map to ResourceListItem format
        final filteredList = typeData.pokemon!.map((p) {
          RegExp(r'\/(\d+)\/$').firstMatch(p.pokemon.url);

          return ResourceListItem(
            name: p.pokemon.name,
            url: p.pokemon.url,
          );
        }).toList();

        // Sort by ID
        filteredList.sort((a, b) => a.id.compareTo(b.id));

        // Update state
        state = state.copyWith(filteredPokemonList: filteredList);
      } else {
        // No Pokemon for this type
        state = state.copyWith(filteredPokemonList: []);
      }

      // Apply search filter if needed
      if (state.searchQuery.isNotEmpty) {
        _filterBySearch(state.searchQuery);
      }
    } catch (e) {
      logger.e('Error filtering by type $typeName: $e');
      state = state.copyWith(filteredPokemonList: []);
    } finally {
      setLoading(false);
    }
  }

  /// Search Pokemon by name
  void searchPokemon(String query) {
    run('searchPokemon', () {
      setLoading(true);

      state = state.copyWith(searchQuery: query.toLowerCase());

      if (query.isEmpty) {
        // If search is cleared, just reset filter if type filter is not active
        if (state.activeTypeFilter == null) {
          state = state.copyWith(filteredPokemonList: []);
        } else {
          // Reapply type filter without search
          _filterByType(state.activeTypeFilter!);
          return; // _filterByType will set isLoading = false
        }
      } else {
        // Apply search filter
        _filterBySearch(query);
      }

      setLoading(false);
    });
  }

  /// Private method to filter by search query
  void _filterBySearch(String query) {
    final lowercaseQuery = query.toLowerCase();

    if (state.pokemonList.isEmpty) {
      // If Pokemon list not loaded yet, load it first
      loadPokemonList();
      return;
    }

    // List to filter - either all Pokemon or type-filtered list
    final listToFilter = state.activeTypeFilter != null
        ? state.filteredPokemonList
        : state.pokemonList;

    // Filter by query
    final newFilteredList = listToFilter.where((pokemon) {
      return pokemon.normalizedName.toLowerCase().contains(lowercaseQuery) ||
          pokemon.id.toString().contains(lowercaseQuery);
    }).toList();

    // Update state
    state = state.copyWith(filteredPokemonList: newFilteredList);
  }

  /// Reset all filters
  void resetFilters() {
    run('resetFilters', () {
      setLoading(true);

      state.searchController.clear();

      state = state.copyWith(
        activeTypeFilter: null,
        clearActiveTypeFilter: true,
        searchQuery: '',
        filteredPokemonList: [],
      );

      setLoading(false);
    });
  }
}
