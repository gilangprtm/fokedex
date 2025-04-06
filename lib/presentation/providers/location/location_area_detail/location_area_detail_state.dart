import '../../../../core/base/base_state_notifier.dart';
import '../../../../data/models/location_model.dart';

class LocationAreaDetailState extends BaseState {
  // Data state
  final LocationAreaDetail? areaDetail;
  final String currentAreaId;
  final String currentAreaName;
  final String locationName;

  const LocationAreaDetailState({
    super.isLoading = false,
    super.error,
    super.stackTrace,
    this.areaDetail,
    this.currentAreaId = '',
    this.currentAreaName = '',
    this.locationName = '',
  });

  @override
  LocationAreaDetailState copyWith({
    bool? isLoading,
    Object? error,
    StackTrace? stackTrace,
    bool clearError = false,
    LocationAreaDetail? areaDetail,
    String? currentAreaId,
    String? currentAreaName,
    String? locationName,
  }) {
    return LocationAreaDetailState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      stackTrace: clearError ? null : stackTrace ?? this.stackTrace,
      areaDetail: areaDetail ?? this.areaDetail,
      currentAreaId: currentAreaId ?? this.currentAreaId,
      currentAreaName: currentAreaName ?? this.currentAreaName,
      locationName: locationName ?? this.locationName,
    );
  }

  // Helper method to get pokemon encounters
  List<PokemonEncounter> getPokemonEncounters() {
    if (areaDetail?.pokemonEncounters == null) return [];
    return areaDetail!.pokemonEncounters!;
  }

  // Helper method to get location name
  String getLocationName() {
    if (locationName.isNotEmpty) return locationName;
    if (areaDetail?.location.name != null) {
      return _capitalizeFirstLetter(areaDetail!.location.name);
    }
    return '';
  }

  // Helper method to capitalize first letter
  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return '';

    // Split by dash or space and capitalize each word
    final words = text.split(RegExp(r'[-\s]'));
    final capitalizedWords = words.map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1);
    }).toList();

    return capitalizedWords.join(' ');
  }
}
