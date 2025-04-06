import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import 'item_list_notifier.dart';
import 'item_list_state.dart';

final itemListProvider =
    StateNotifierProvider.autoDispose<ItemListNotifier, ItemListState>((ref) {
  final itemService = ref.watch(itemServiceProvider);

  final scrollController = ScrollController();
  final searchController = TextEditingController();

  // Create the initial state
  final initialState = ItemListState(
    scrollController: scrollController,
    searchController: searchController,
  );

  return ItemListNotifier(initialState, ref, itemService);
});
