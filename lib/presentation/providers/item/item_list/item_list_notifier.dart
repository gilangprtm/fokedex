import '../../../../core/base/base_state_notifier.dart';
import '../../../../data/datasource/network/service/item_service.dart';
import 'item_list_state.dart';

class ItemListNotifier extends BaseStateNotifier<ItemListState> {
  final ItemService _itemService;

  ItemListNotifier(super.initialState, super.ref, this._itemService);

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
        // Load more items
        loadMoreItems();
      }
    });
  }

  // Handle search text changes
  void onSearchChanged(String value) {
    searchItems(value);
  }

  // Clear search
  void clearSearch() {
    state.searchController.clear();
    searchItems('');
  }

  // Load initial data
  Future<void> loadInitialData() async {
    await loadItems();
  }

  // Load items with pagination
  Future<void> loadItems({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        offset: 0,
        items: [],
        hasMore: true,
        filteredItems: [],
        isLoading: true,
      );
    }

    // Don't load more if there are no more items or already loading
    if (!state.hasMore || (state.isLoading && !refresh)) {
      return;
    }

    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final response = await _itemService.getItemList(
        offset: state.offset,
        limit: 2200,
      );

      // Create the new state
      state = state.copyWith(
        hasMore: response.hasMore,
        offset: response.nextOffset ?? state.offset,
        items: [...state.items, ...response.results],
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

      logger.e('Error loading item list: $e', stackTrace: stackTrace);
    }
  }

  // Load more items (infinite scroll)
  Future<void> loadMoreItems() async {
    if (state.isLoading || !state.hasMore) {
      return;
    }

    await loadItems();
  }

  // Filter items based on search query
  void searchItems(String query) {
    // First update state to indicate we're searching
    state = state.copyWith(
      isLoading: true,
      searchQuery: query.toLowerCase(),
    );

    // Then filter the items
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
        filteredItems: [],
      );
    } else {
      final filtered = state.items
          .where((item) => item.normalizedName.toLowerCase().contains(query))
          .toList();

      state = state.copyWith(
        filteredItems: filtered,
      );
    }
  }

  // Refresh data
  Future<void> refresh() async {
    await loadItems(refresh: true);
  }
}
