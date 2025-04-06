import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import 'location_list_notifier.dart';
import 'location_list_state.dart';

final locationListProvider =
    StateNotifierProvider.autoDispose<LocationListNotifier, LocationListState>(
        (ref) {
  final locationService = ref.watch(locationServiceProvider);

  final scrollController = ScrollController();
  final searchController = TextEditingController();

  // Create the initial state
  final initialState = LocationListState(
    scrollController: scrollController,
    searchController: searchController,
  );

  return LocationListNotifier(initialState, ref, locationService);
});
