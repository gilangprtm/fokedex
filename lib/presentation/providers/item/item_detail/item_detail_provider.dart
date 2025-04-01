import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import 'item_detail_notifier.dart';
import 'item_detail_state.dart';

final itemDetailProvider =
    StateNotifierProvider.autoDispose<ItemDetailNotifier, ItemDetailState>(
        (ref) {
  final itemService = ref.watch(itemServiceProvider);

  // Create the initial state
  const initialState = ItemDetailState();

  return ItemDetailNotifier(initialState, ref, itemService);
});
