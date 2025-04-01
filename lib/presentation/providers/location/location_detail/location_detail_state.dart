import '../../../../core/base/base_state_notifier.dart';
import '../../../../data/models/location_model.dart';

class LocationDetailState extends BaseState {
  // Data state
  final Location? location;
  final String currentLocationId;
  final String currentLocationName;

  const LocationDetailState({
    super.isLoading = false,
    super.error,
    super.stackTrace,
    this.location,
    this.currentLocationId = '',
    this.currentLocationName = '',
  });

  @override
  LocationDetailState copyWith({
    bool? isLoading,
    Object? error,
    StackTrace? stackTrace,
    bool clearError = false,
    Location? location,
    String? currentLocationId,
    String? currentLocationName,
  }) {
    return LocationDetailState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      stackTrace: clearError ? null : stackTrace ?? this.stackTrace,
      location: location ?? this.location,
      currentLocationId: currentLocationId ?? this.currentLocationId,
      currentLocationName: currentLocationName ?? this.currentLocationName,
    );
  }

  // Helper method to get region name (preserving original functionality)
  String getRegionName() {
    if (location?.region == null) return 'Unknown Region';
    return location!.region!.name;
  }
}
