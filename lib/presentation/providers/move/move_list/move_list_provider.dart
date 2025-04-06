import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import 'move_list_notifier.dart';
import 'move_list_state.dart';

final moveListProvider =
    StateNotifierProvider.autoDispose<MoveListNotifier, MoveListState>((ref) {
  final moveService = ref.watch(moveServiceProvider);

  final scrollController = ScrollController();
  final searchController = TextEditingController();

  // Create the initial state
  final initialState = MoveListState(
    scrollController: scrollController,
    searchController: searchController,
  );

  return MoveListNotifier(initialState, ref, moveService);
});
