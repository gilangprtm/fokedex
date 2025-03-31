import 'package:flutter/material.dart';
import '../../../core/base/base_provider.dart';
import '../../../data/datasource/network/service/ability_service.dart';
import '../../../data/models/api_response_model.dart';

class AbilityListProvider extends BaseProvider {
  // Service
  final AbilityService _service = AbilityService();

  // Controllers
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  // Data state
  List<ResourceListItem> _abilities = [];
  List<ResourceListItem> get abilities => _abilities;

  // Filtered list
  List<ResourceListItem> _filteredAbilities = [];
  List<ResourceListItem> get filteredAbilities =>
      _filteredAbilities.isEmpty ? _abilities : _filteredAbilities;

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
    searchController.clear();
    searchAbilities('');
  }

  // Notify about ability list changes
  void _notifyAbilityListChange() {
    notifyPropertyListeners('abilities');
    notifyPropertyListeners('filteredAbilities');
  }

  // Load initial data
  Future<void> loadInitialData() async {
    await loadAbilities();
  }

  // Load daftar Ability dengan pagination
  Future<void> loadAbilities({bool refresh = false}) async {
    if (refresh) {
      _offset = 0;
      _abilities = [];
      _hasMore = true;
      _filteredAbilities = [];
      _notifyAbilityListChange();
    }

    // Jangan load lagi jika sudah tidak ada data lagi atau sedang loading
    if (!_hasMore || (_isLoading && !refresh)) {
      return;
    }

    _setLoading(true);
    _setHasError(false);

    try {
      final response =
          await _service.getAbilityList(offset: _offset, limit: 500);

      // Update pagination state
      _hasMore = response.hasMore;
      _offset = response.nextOffset ?? _offset;

      // Add new Abilities to the list
      _abilities = [..._abilities, ...response.results];

      // Apply search if query exists
      if (_searchQuery.isNotEmpty) {
        _filterBySearch(_searchQuery);
      }

      _notifyAbilityListChange();
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setHasError(true);
      _setErrorMessage(e.toString());
      logger.e('Error loading Ability list: $e');
    }
  }

  // Load lebih banyak Ability (infinite scroll)
  Future<void> loadMoreAbilities() async {
    if (_isLoading || !_hasMore) {
      return;
    }

    await loadAbilities();
  }

  // Filter Ability berdasarkan pencarian nama
  void searchAbilities(String query) {
    _setLoading(true);
    _setSearchQuery(query.toLowerCase());
    _filterBySearch(_searchQuery);
    _setLoading(false);
  }

  // Helper method untuk filter berdasarkan pencarian
  void _filterBySearch(String query) {
    if (query.isEmpty) {
      _filteredAbilities = [];
    } else {
      _filteredAbilities = _abilities
          .where(
              (ability) => ability.normalizedName.toLowerCase().contains(query))
          .toList();
    }

    _notifyAbilityListChange();
  }

  // Refresh data
  Future<void> refresh() async {
    await loadAbilities(refresh: true);
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }
}
