import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import 'ability_detail_notifier.dart';
import 'ability_detail_state.dart';

final abilityDetailProvider = StateNotifierProvider.autoDispose<
    AbilityDetailNotifier, AbilityDetailState>((ref) {
  final abilityService = ref.watch(abilityServiceProvider);

  final scrollController = ScrollController();
  final searchController = TextEditingController();

  // Create the initial state
  final initialState = AbilityDetailState(
    scrollController: scrollController,
    searchController: searchController,
  );

  return AbilityDetailNotifier(
    initialState,
    ref,
    abilityService,
  );
});
