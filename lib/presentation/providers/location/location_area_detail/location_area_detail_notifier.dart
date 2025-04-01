import '../../../../core/base/base_state_notifier.dart';
import '../../../../core/utils/mahas.dart';
import '../../../../data/datasource/network/service/location_service.dart';
import 'location_area_detail_state.dart';

class LocationAreaDetailNotifier
    extends BaseStateNotifier<LocationAreaDetailState> {
  final LocationService _locationService;

  LocationAreaDetailNotifier(
      super.initialState, super.ref, this._locationService);

  @override
  void onInit() {
    super.onInit();

    // Get args without notification during build phase
    var idArg = Mahas.argument('id');
    final currentAreaId = idArg != null ? idArg.toString() : '';
    final currentAreaName = Mahas.argument<String>('name') ?? '';
    final locationName = Mahas.argument<String>('locationName') ?? '';

    // Update state with initial values
    state = state.copyWith(
      currentAreaId: currentAreaId,
      currentAreaName: currentAreaName,
      locationName: locationName,
    );

    // Use microtask to delay loading until after build phase
    Future.microtask(() => loadInitialData());
  }

  void getArgs() {
    var idArg = Mahas.argument('id');
    final currentAreaId = idArg != null ? idArg.toString() : '';
    final currentAreaName = Mahas.argument<String>('name') ?? '';
    final locationName = Mahas.argument<String>('locationName') ?? '';

    state = state.copyWith(
      currentAreaId: currentAreaId,
      currentAreaName: currentAreaName,
      locationName: locationName,
    );

    loadInitialData();
  }

  // Load initial data
  Future<void> loadInitialData() async {
    await loadAreaDetail(state.currentAreaId.isNotEmpty
        ? state.currentAreaId
        : state.currentAreaName);
  }

  // Load detail Location Area
  Future<void> loadAreaDetail(String identifier) async {
    // Skip if already loading the same Area
    if (state.isLoading &&
        (state.currentAreaId == identifier ||
            state.currentAreaName == identifier)) {
      return;
    }

    try {
      state = state.copyWith(
        isLoading: true,
        clearError: true,
        currentAreaName: identifier,
      );

      if (identifier.isEmpty) {
        throw Exception('Location Area ID or name is required');
      }

      final areaData = await _locationService.getLocationAreaDetail(identifier);

      // Update location name if it's empty and we have areaDetail
      String updatedLocationName = state.locationName;
      if (state.locationName.isEmpty) {
        updatedLocationName = _capitalizeFirstLetter(areaData.location.name);
      }

      state = state.copyWith(
        isLoading: false,
        areaDetail: areaData,
        currentAreaId: areaData.id.toString(),
        locationName: updatedLocationName,
      );
    } catch (e, stackTrace) {
      logger.e('Error loading location area detail: $e',
          stackTrace: stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  // Refresh data
  Future<void> refresh() async {
    await loadAreaDetail(state.currentAreaId.isNotEmpty
        ? state.currentAreaId
        : state.currentAreaName);
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
