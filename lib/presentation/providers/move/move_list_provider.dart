import 'package:flutter/material.dart';
import '../../../core/base/base_provider.dart';
import '../../../data/models/api_response_model.dart';
import '../../../data/datasource/network/service/move_service.dart';

class MoveListProvider extends BaseProvider {
  // Service
  final MoveService _moveService = MoveService();

  // Controllers
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  // Data state
  List<ResourceListItem> _moveList = [];
  List<ResourceListItem> get moveList => _moveList;

  // Filtered list
  List<ResourceListItem> _filteredMoveList = [];
  List<ResourceListItem> get filteredMoveList =>
      _filteredMoveList.isEmpty ? _moveList : _filteredMoveList;

  // Pagination state
  int _offset = 0;
  bool _hasMoreData = true;
  bool get hasMoreData => _hasMoreData;

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
    loadInitialData();
  }

  // Setup scroll controller listener
  void _setupScrollListener() {
    scrollController.addListener(() {
      // Check if we're near the bottom of the list
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        // Load more moves
        loadMoreMoves();
      }
    });
  }

  // Handle search text changes
  void onSearchChanged(String value) {
    searchMoves(value);
  }

  // Clear search
  void clearSearch() {
    searchController.clear();
    searchMoves('');
  }

  // Load initial data
  Future<void> loadInitialData() async {
    // Use microtask to delay the loading until after the build phase
    Future.microtask(() async {
      await loadMoveList();
    });
  }

  // Notify about move list changes
  void _notifyMoveListChange() {
    notifyPropertyListeners('moveList');
    notifyPropertyListeners('filteredMoveList');
  }

  // Load daftar Move dengan pagination
  Future<void> loadMoveList({bool refresh = false}) async {
    if (refresh) {
      _offset = 0;
      _moveList = [];
      _hasMoreData = true;
      _filteredMoveList = [];
      _notifyMoveListChange();
    }

    // Jangan load lagi jika sudah tidak ada data lagi atau sedang loading
    if (!_hasMoreData || (_isLoading && !refresh)) {
      return;
    }

    _setLoading(true);
    _setHasError(false);

    try {
      final response =
          await _moveService.getMoveList(offset: _offset, limit: 1000);

      // Update pagination state
      _hasMoreData = response.hasMore;
      _offset = response.nextOffset ?? _offset;

      // Add new Moves to the list
      _moveList = [..._moveList, ...response.results];

      // Apply search if query exists
      if (_searchQuery.isNotEmpty) {
        _filterBySearch(_searchQuery);
      }

      _notifyMoveListChange();
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setHasError(true);
      _setErrorMessage(e.toString());
      logger.e('Error loading Move list: $e');
    }
  }

  // Load lebih banyak Move (infinite scroll)
  Future<void> loadMoreMoves() async {
    if (_isLoading || !_hasMoreData) {
      return;
    }

    await loadMoveList();
  }

  // Filter Move berdasarkan pencarian nama
  void searchMoves(String query) {
    _setLoading(true);
    _setSearchQuery(query.toLowerCase());
    _filterBySearch(_searchQuery);
    _setLoading(false);
  }

  // Helper method untuk filter berdasarkan pencarian
  void _filterBySearch(String query) {
    if (query.isEmpty) {
      _filteredMoveList = [];
    } else {
      _filteredMoveList = _moveList
          .where((move) => move.normalizedName.toLowerCase().contains(query))
          .toList();
    }

    _notifyMoveListChange();
  }

  // Refresh data
  Future<void> refresh() async {
    await loadMoveList(refresh: true);
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }
}
