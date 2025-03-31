import 'package:flutter/material.dart';
import '../../../core/base/base_provider.dart';
import '../../../data/models/api_response_model.dart';
import '../../../data/datasource/network/service/item_service.dart';

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

  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyPropertyListeners('isLoading');
    }
  }

  bool _hasError = false;
  bool get hasError => _hasError;

  void _setHasError(bool value) {
    if (_hasError != value) {
      _hasError = value;
      notifyPropertyListeners('hasError');
    }
  }

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  void _setErrorMessage(String value) {
    if (_errorMessage != value) {
      _errorMessage = value;
      notifyPropertyListeners('errorMessage');
    }
  }

  // Search query
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  void _setSearchQuery(String value) {
    if (_searchQuery != value) {
      _searchQuery = value;
      notifyPropertyListeners('searchQuery');
    }
  }

  // Lifecycle methods
  @override
  void onInit() {
    super.onInit();
    _setupScrollListener();

    // Use microtask to delay loading until after build phase
    Future.microtask(() {
      loadInitialData();
    });
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

  // Notify about item list changes
  void _notifyItemListChange() {
    notifyPropertyListeners('items');
    notifyPropertyListeners('filteredItems');
  }

  // Load initial data
  Future<void> loadInitialData() async {
    await loadItems();
  }

  // Load daftar Item dengan pagination
  Future<void> loadItems({bool refresh = false}) async {
    if (refresh) {
      _offset = 0;
      _items = [];
      _hasMore = true;
      _filteredItems = [];
      _notifyItemListChange();
    }

    // Jangan load lagi jika sudah tidak ada data lagi atau sedang loading
    if (!_hasMore || (_isLoading && !refresh)) {
      return;
    }

    _setLoading(true);
    _setHasError(false);

    try {
      final response = await _service.getItemList(offset: _offset, limit: 2200);

      // Update pagination state
      _hasMore = response.hasMore;
      _offset = response.nextOffset ?? _offset;

      // Add new Items to the list
      _items = [..._items, ...response.results];

      // Apply search if query exists
      if (_searchQuery.isNotEmpty) {
        _filterBySearch(_searchQuery);
      }

      _notifyItemListChange();
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setHasError(true);
      _setErrorMessage(e.toString());
      logger.e('Error loading Item list: $e');
    }
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
    _setLoading(true);
    _setSearchQuery(query.toLowerCase());
    _filterBySearch(_searchQuery);
    _setLoading(false);
  }

  // Helper method untuk filter berdasarkan pencarian
  void _filterBySearch(String query) {
    if (query.isEmpty) {
      _filteredItems = [];
    } else {
      _filteredItems = _items
          .where((item) => item.normalizedName.toLowerCase().contains(query))
          .toList();
    }

    _notifyItemListChange();
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
