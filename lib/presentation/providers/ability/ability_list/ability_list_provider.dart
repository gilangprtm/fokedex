import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import 'ability_list_notifier.dart';
import 'ability_list_state.dart';

final abilityListProvider =
    StateNotifierProvider.autoDispose<AbilityListNotifier, AbilityListState>(
        (ref) {
  final abilityService = ref.watch(abilityServiceProvider);

  final scrollController = ScrollController();
  final searchController = TextEditingController();

  // Create the initial state
  final initialState = AbilityListState(
    scrollController: scrollController,
    searchController: searchController,
  );

  return AbilityListNotifier(initialState, ref, abilityService);
});
