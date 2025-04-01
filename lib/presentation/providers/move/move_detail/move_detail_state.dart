import 'package:flutter/material.dart';
import '../../../../core/base/base_state_notifier.dart';
import '../../../../data/models/move_model.dart';

class MoveDetailState extends BaseState {
  final Move? move;
  final ScrollController scrollController;
  final TextEditingController searchController;
  final String searchQuery;
  final bool isLoadingSearch;

  const MoveDetailState({
    super.isLoading = false,
    super.error,
    super.stackTrace,
    this.move,
    required this.scrollController,
    required this.searchController,
    this.searchQuery = '',
    this.isLoadingSearch = false,
  });

  @override
  MoveDetailState copyWith({
    bool? isLoading,
    Object? error,
    StackTrace? stackTrace,
    bool clearError = false,
    Move? move,
    ScrollController? scrollController,
    TextEditingController? searchController,
    String? searchQuery,
    bool? isLoadingSearch,
  }) {
    return MoveDetailState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      stackTrace: clearError ? null : stackTrace ?? this.stackTrace,
      move: move ?? this.move,
      scrollController: scrollController ?? this.scrollController,
      searchController: searchController ?? this.searchController,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoadingSearch: isLoadingSearch ?? this.isLoadingSearch,
    );
  }
}
