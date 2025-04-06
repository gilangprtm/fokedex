import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import 'move_detail_notifier.dart';
import 'move_detail_state.dart';

final moveDetailProvider =
    StateNotifierProvider.autoDispose<MoveDetailNotifier, MoveDetailState>(
        (ref) {
  final moveService = ref.watch(moveServiceProvider);
  final scrollController = ScrollController();
  final searchController = TextEditingController();

  // Create the initial state
  final initialState = MoveDetailState(
    scrollController: scrollController,
    searchController: searchController,
  );
  return MoveDetailNotifier(
    initialState,
    ref,
    moveService,
  );
});
