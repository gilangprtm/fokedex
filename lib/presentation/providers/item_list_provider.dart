import 'package:flutter/material.dart';
import '../../core/base/base_provider.dart';
import '../../data/datasource/models/api_response_model.dart';
import '../../data/datasource/network/service/item_service.dart';

class ItemListProvider extends BaseProvider {
  // Service
  final ItemService _service = ItemService();

  // Controllers
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  // Data state
  List<ResourceListItem> _items = [];
  List<ResourceListItem> get items => _items;

  // Filtered list
  List<ResourceListItem> _filteredItems = [];
  List<ResourceListItem> get filteredItems =>
      _filteredItems.isEmpty ? _items : _filteredItems;

  // Pagination state
  int _offset = 0;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasError = false;
  bool get hasError => _hasError;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // Search query
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
    searchController.clear();
    searchItems('');
  }

  // Load initial data
  Future<void> loadInitialData() async {
    await runAsync('loadInitialData', () async {
      await loadItems();
    });
  }

  // Load daftar Item dengan pagination
  Future<void> loadItems({bool refresh = false}) async {
    if (refresh) {
      _offset = 0;
      _items = [];
      _hasMore = true;
      _filteredItems = [];
      notifyListeners();
    }

    // Jangan load lagi jika sudah tidak ada data lagi atau sedang loading
    if (!_hasMore || (_isLoading && !refresh)) {
      return;
    }

    await runAsync('loadItems', () async {
      _isLoading = true;
      _hasError = false;

      try {
        final response =
            await _service.getItemList(offset: _offset, limit: 2200);

        // Update pagination state
        _hasMore = response.hasMore;
        _offset = response.nextOffset ?? _offset;

        // Add new Items to the list
        _items = [..._items, ...response.results];

        // Apply search if query exists
        if (_searchQuery.isNotEmpty) {
          _filterBySearch(_searchQuery);
        }

        _isLoading = false;
      } catch (e) {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
        logger.e('Error loading Item list: $e');
      }
    });
  }

  // Load lebih banyak Item (infinite scroll)
  Future<void> loadMoreItems() async {
    if (_isLoading || !_hasMore) {
      return;
    }

    await loadItems();
  }

  // Filter Item berdasarkan pencarian nama
  void searchItems(String query) {
    _searchQuery = query.toLowerCase();
    _filterBySearch(_searchQuery);
    notifyListeners();
  }

  // Helper method untuk filter berdasarkan pencarian
  void _filterBySearch(String query) {
    if (query.isEmpty) {
      _filteredItems = [];
      return;
    }

    _filteredItems = _items
        .where((item) => item.normalizedName.toLowerCase().contains(query))
        .toList();
  }

  // Refresh data
  Future<void> refresh() async {
    await loadItems(refresh: true);
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }
}
