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

  // Load initial data
  Future<void> loadInitialData() async {
    await runAsync('loadInitialData', () async {
      await loadLocations();
    });
  }

  // Load daftar Location dengan pagination
  Future<void> loadLocations({bool refresh = false}) async {
    if (refresh) {
      _offset = 0;
      _locations = [];
      _hasMore = true;
      _filteredLocations = [];
      notifyListeners();
    }

    // Jangan load lagi jika sudah tidak ada data lagi atau sedang loading
    if (!_hasMore || (_isLoading && !refresh)) {
      return;
    }

    await runAsync('loadLocations', () async {
      _isLoading = true;
      _hasError = false;

      try {
        final response =
            await _service.getLocationList(offset: _offset, limit: 1200);

        // Update pagination state
        _hasMore = response.hasMore;
        _offset = response.nextOffset ?? _offset;

        // Add new Locations to the list
        _locations = [..._locations, ...response.results];

        // Apply search if query exists
        if (_searchQuery.isNotEmpty) {
          _filterBySearch(_searchQuery);
        }

        _isLoading = false;
      } catch (e) {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
        logger.e('Error loading Location list: $e');
      }
    });
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
    _searchQuery = query.toLowerCase();
    _filterBySearch(_searchQuery);
    notifyListeners();
  }

  // Helper method untuk filter berdasarkan pencarian
  void _filterBySearch(String query) {
    if (query.isEmpty) {
      _filteredLocations = [];
      return;
    }

    _filteredLocations = _locations
        .where(
            (location) => location.normalizedName.toLowerCase().contains(query))
        .toList();
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
