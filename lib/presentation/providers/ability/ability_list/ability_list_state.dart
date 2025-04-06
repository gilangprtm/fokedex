import 'package:flutter/material.dart';
import '../../../../core/base/base_state_notifier.dart';
import '../../../../data/models/api_response_model.dart';

class AbilityListState extends BaseState {
  // Data state
  final List<ResourceListItem> abilities;
  final List<ResourceListItem> filteredAbilities;

  // Pagination state
  final int offset;
  final bool hasMore;
  final ScrollController scrollController;
  final TextEditingController searchController;

  // Search state
  final String searchQuery;

  const AbilityListState({
    super.isLoading = false,
    super.error,
    super.stackTrace,
    this.abilities = const [],
    this.filteredAbilities = const [],
    this.offset = 0,
    this.hasMore = true,
    required this.scrollController,
    required this.searchController,
    this.searchQuery = '',
  });

  // Get the abilities to display (filtered or all)
  List<ResourceListItem> get displayAbilities {
    return filteredAbilities.isEmpty ? abilities : filteredAbilities;
  }

  @override
  AbilityListState copyWith({
    bool? isLoading,
    Object? error,
    StackTrace? stackTrace,
    bool clearError = false,
    List<ResourceListItem>? abilities,
    List<ResourceListItem>? filteredAbilities,
    int? offset,
    bool? hasMore,
    ScrollController? scrollController,
    TextEditingController? searchController,
    String? searchQuery,
  }) {
    return AbilityListState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      stackTrace: clearError ? null : stackTrace ?? this.stackTrace,
      abilities: abilities ?? this.abilities,
      filteredAbilities: filteredAbilities ?? this.filteredAbilities,
      offset: offset ?? this.offset,
      hasMore: hasMore ?? this.hasMore,
      scrollController: scrollController ?? this.scrollController,
      searchController: searchController ?? this.searchController,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
