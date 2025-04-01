import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import 'location_area_detail_notifier.dart';
import 'location_area_detail_state.dart';

final locationAreaDetailProvider = StateNotifierProvider.autoDispose<
    LocationAreaDetailNotifier, LocationAreaDetailState>((ref) {
  final locationService = ref.watch(locationServiceProvider);

  // Create the initial state
  const initialState = LocationAreaDetailState();

  return LocationAreaDetailNotifier(initialState, ref, locationService);
});
