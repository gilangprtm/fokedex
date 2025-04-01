import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import 'location_detail_notifier.dart';
import 'location_detail_state.dart';

final locationDetailProvider = StateNotifierProvider.autoDispose<
    LocationDetailNotifier, LocationDetailState>((ref) {
  final locationService = ref.watch(locationServiceProvider);

  // Create the initial state
  const initialState = LocationDetailState();

  return LocationDetailNotifier(initialState, ref, locationService);
});
