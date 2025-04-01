import 'package:flutter/material.dart';
import '../../../../core/base/base_state_notifier.dart';
import '../../../../data/models/api_response_model.dart';

class ItemListState extends BaseState {
  // Data state
  final List<ResourceListItem> items;
  final List<ResourceListItem> filteredItems;

  // Pagination state
  final int offset;
  final bool hasMore;
  final ScrollController scrollController;
  final TextEditingController searchController;

  // Search state
  final String searchQuery;

  const ItemListState({
    super.isLoading = false,
    super.error,
    super.stackTrace,
    this.items = const [],
    this.filteredItems = const [],
    this.offset = 0,
    this.hasMore = true,
    required this.scrollController,
    required this.searchController,
    this.searchQuery = '',
  });

  // Get the items to display (filtered or all)
  List<ResourceListItem> get displayItems {
    return filteredItems.isEmpty ? items : filteredItems;
  }

  @override
  ItemListState copyWith({
    bool? isLoading,
    Object? error,
    StackTrace? stackTrace,
    bool clearError = false,
    List<ResourceListItem>? items,
    List<ResourceListItem>? filteredItems,
    int? offset,
    bool? hasMore,
    ScrollController? scrollController,
    TextEditingController? searchController,
    String? searchQuery,
  }) {
    return ItemListState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      stackTrace: clearError ? null : stackTrace ?? this.stackTrace,
      items: items ?? this.items,
      filteredItems: filteredItems ?? this.filteredItems,
      offset: offset ?? this.offset,
      hasMore: hasMore ?? this.hasMore,
      scrollController: scrollController ?? this.scrollController,
      searchController: searchController ?? this.searchController,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
