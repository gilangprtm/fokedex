import 'package:flutter/material.dart';
import '../../../../core/base/base_state_notifier.dart';
import '../../../../data/models/api_response_model.dart';

class LocationListState extends BaseState {
  // Data state
  final List<ResourceListItem> locations;
  final List<ResourceListItem> filteredLocations;

  // Pagination state
  final int offset;
  final bool hasMore;
  final ScrollController scrollController;
  final TextEditingController searchController;

  // Search state
  final String searchQuery;

  const LocationListState({
    super.isLoading = false,
    super.error,
    super.stackTrace,
    this.locations = const [],
    this.filteredLocations = const [],
    this.offset = 0,
    this.hasMore = true,
    required this.scrollController,
    required this.searchController,
    this.searchQuery = '',
  });

  // Get the locations to display (filtered or all)
  List<ResourceListItem> get displayLocations {
    return filteredLocations.isEmpty ? locations : filteredLocations;
  }

  @override
  LocationListState copyWith({
    bool? isLoading,
    Object? error,
    StackTrace? stackTrace,
    bool clearError = false,
    List<ResourceListItem>? locations,
    List<ResourceListItem>? filteredLocations,
    int? offset,
    bool? hasMore,
    ScrollController? scrollController,
    TextEditingController? searchController,
    String? searchQuery,
  }) {
    return LocationListState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      stackTrace: clearError ? null : stackTrace ?? this.stackTrace,
      locations: locations ?? this.locations,
      filteredLocations: filteredLocations ?? this.filteredLocations,
      offset: offset ?? this.offset,
      hasMore: hasMore ?? this.hasMore,
      scrollController: scrollController ?? this.scrollController,
      searchController: searchController ?? this.searchController,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
