import 'package:flutter/material.dart';
import '../../../../core/base/base_state_notifier.dart';
import '../../../../data/models/api_response_model.dart';

class MoveListState extends BaseState {
  // Data state
  final List<ResourceListItem> moves;
  final List<ResourceListItem> filteredMoves;

  // Pagination state
  final ScrollController scrollController;
  final TextEditingController searchController;

  const MoveListState({
    super.isLoading = false,
    super.error,
    super.stackTrace,
    this.moves = const [],
    this.filteredMoves = const [],
    required this.scrollController,
    required this.searchController,
  });

  @override
  MoveListState copyWith({
    bool? isLoading,
    Object? error,
    StackTrace? stackTrace,
    bool clearError = false,
    List<ResourceListItem>? moves,
    List<ResourceListItem>? filteredMoves,
    ScrollController? scrollController,
    TextEditingController? searchController,
  }) {
    return MoveListState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      stackTrace: clearError ? null : stackTrace ?? this.stackTrace,
      moves: moves ?? this.moves,
      filteredMoves: filteredMoves ?? this.filteredMoves,
      scrollController: scrollController ?? this.scrollController,
      searchController: searchController ?? this.searchController,
    );
  }
}
