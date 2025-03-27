import 'package:flutter/material.dart';
import '../../../core/base/base_provider.dart';
import '../../../data/datasource/models/api_response_model.dart';
import '../../../data/datasource/network/service/location_service.dart';

class LocationListProvider extends BaseProvider {
  // Service
  final LocationService _service = LocationService();

  // Controllers
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  // Data state
  List<ResourceListItem> _locations = [];
  List<ResourceListItem> get locations => _locations;

  // Filtered list
  List<ResourceListItem> _filteredLocations = [];
  List<ResourceListItem> get filteredLocations =>
      _filteredLocations.isEmpty ? _locations : _filteredLocations;

  // Pagination state
  int _offset = 0;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  void _setHasMore(bool value) {
    if (_hasMore != value) {
      _hasMore = value;
      notifyPropertyListeners('hasMore');
    }
  }

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
        // Load more locations
        loadMoreLocations();
      }
    });
  }

  // Handle search text changes
  void onSearchChanged(String value) {
    searchLocations(value);
  }

  // Clear search
  void clearSearch() {
    searchController.clear();
    searchLocations('');
  }

  // Update the locations list and notify listeners with proper property names
  void _updateLocationsList() {
    // Using beginBatch and endBatch to notify multiple properties at once
    beginBatch();
    notifyPropertyListeners('locations');
    notifyPropertyListeners('filteredLocations');
    endBatch();
  }

  // Load initial data
  Future<void> loadInitialData() async {
    await loadLocations();
  }

  // Load daftar Location dengan pagination
  Future<void> loadLocations({bool refresh = false}) async {
    if (refresh) {
      _offset = 0;
      _locations = [];
      _setHasMore(true);
      _filteredLocations = [];
      _updateLocationsList();
    }

    // Jangan load lagi jika sudah tidak ada data lagi atau sedang loading
    if (!_hasMore || (_isLoading && !refresh)) {
      return;
    }

    _setLoading(true);
    _setHasError(false);

    try {
      final response =
          await _service.getLocationList(offset: _offset, limit: 1200);

      // Update pagination state
      _setHasMore(response.hasMore);
      _offset = response.nextOffset ?? _offset;

      // Add new Locations to the list
      _locations = [..._locations, ...response.results];

      // Apply search if query exists
      if (_searchQuery.isNotEmpty) {
        _filterBySearch(_searchQuery);
      } else {
        _updateLocationsList();
      }

      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setHasError(true);
      _setErrorMessage(e.toString());
      logger.e('Error loading Location list: $e');
    }
  }

  // Load lebih banyak Location (infinite scroll)
  Future<void> loadMoreLocations() async {
    if (_isLoading || !_hasMore) {
      return;
    }

    await loadLocations();
  }

  // Filter Location berdasarkan pencarian nama
  void searchLocations(String query) {
    _setLoading(true);
    _setSearchQuery(query.toLowerCase());
    _filterBySearch(_searchQuery);
    _setLoading(false);
  }

  // Helper method untuk filter berdasarkan pencarian
  void _filterBySearch(String query) {
    if (query.isEmpty) {
      _filteredLocations = [];
    } else {
      _filteredLocations = _locations
          .where((location) =>
              location.normalizedName.toLowerCase().contains(query))
          .toList();
    }

    notifyPropertyListeners('filteredLocations');
  }

  // Refresh data
  Future<void> refresh() async {
    await loadLocations(refresh: true);
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }
}
