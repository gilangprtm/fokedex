import '../../../../core/base/base_state_notifier.dart';
import '../../../../data/datasource/network/service/ability_service.dart';
import 'ability_list_state.dart';

class AbilityListNotifier extends BaseStateNotifier<AbilityListState> {
  final AbilityService _abilityService;

  AbilityListNotifier(super.initialState, super.ref, this._abilityService);

  @override
  void onInit() {
    super.onInit();
    _setupScrollListener();
    loadInitialData();
  }

  @override
  void onClose() {
    state.scrollController.dispose();
    state.searchController.dispose();
    super.onClose();
  }

  // Setup scroll controller listener
  void _setupScrollListener() {
    state.scrollController.addListener(() {
      // Check if we're near the bottom of the list
      if (state.scrollController.position.pixels >=
          state.scrollController.position.maxScrollExtent - 200) {
        // Load more abilities
        loadMoreAbilities();
      }
    });
  }

  // Handle search text changes
  void onSearchChanged(String value) {
    searchAbilities(value);
  }

  // Clear search
  void clearSearch() {
    state.searchController.clear();
    searchAbilities('');
  }

  // Load initial data
  Future<void> loadInitialData() async {
    await loadAbilities();
  }

  // Load abilities with pagination
  Future<void> loadAbilities({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        offset: 0,
        abilities: [],
        hasMore: true,
        filteredAbilities: [],
        isLoading: true,
      );
    }

    // Don't load more if there are no more abilities or already loading
    if (!state.hasMore || (state.isLoading && !refresh)) {
      return;
    }

    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final response = await _abilityService.getAbilityList(
        offset: state.offset,
        limit: 500,
      );

      // Create the new state
      state = state.copyWith(
        hasMore: response.hasMore,
        offset: response.nextOffset ?? state.offset,
        abilities: [...state.abilities, ...response.results],
        isLoading: false,
      );

      // Apply search if query exists
      if (state.searchQuery.isNotEmpty) {
        _filterBySearch(state.searchQuery);
      }
    } catch (e, stackTrace) {
      if (!mounted) return;

      state = state.copyWith(
        error: e.toString(),
        stackTrace: stackTrace,
        isLoading: false,
      );

      logger.e('Error loading ability list: $e', stackTrace: stackTrace);
    }
  }

  // Load more abilities (infinite scroll)
  Future<void> loadMoreAbilities() async {
    if (state.isLoading || !state.hasMore) {
      return;
    }

    await loadAbilities();
  }

  // Filter abilities based on search query
  void searchAbilities(String query) {
    // First update state to indicate we're searching
    state = state.copyWith(
      isLoading: true,
      searchQuery: query.toLowerCase(),
    );

    // Then filter the abilities
    _filterBySearch(state.searchQuery);

    // Update loading state
    state = state.copyWith(
      isLoading: false,
    );
  }

  // Helper method for filtering based on search
  void _filterBySearch(String query) {
    if (query.isEmpty) {
      state = state.copyWith(
        filteredAbilities: [],
      );
    } else {
      final filtered = state.abilities
          .where(
              (ability) => ability.normalizedName.toLowerCase().contains(query))
          .toList();

      state = state.copyWith(
        filteredAbilities: filtered,
      );
    }
  }

  // Refresh data
  Future<void> refresh() async {
    await loadAbilities(refresh: true);
  }
}
