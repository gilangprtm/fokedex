import '../../../../core/base/base_state_notifier.dart';
import '../../../../core/utils/mahas.dart';
import '../../../../data/datasource/network/service/location_service.dart';
import 'location_detail_state.dart';

class LocationDetailNotifier extends BaseStateNotifier<LocationDetailState> {
  final LocationService _locationService;

  LocationDetailNotifier(super.initialState, super.ref, this._locationService);

  @override
  void onInit() {
    super.onInit();

    // Get args without notification during build phase
    // Handle possible integer ID
    var idArg = Mahas.argument('id');
    final currentLocationId = idArg != null ? idArg.toString() : '';
    final currentLocationName = Mahas.argument<String>('name') ?? '';

    // Update state with initial values
    state = state.copyWith(
      currentLocationId: currentLocationId,
      currentLocationName: currentLocationName,
    );

    // Use microtask to delay loading until after build phase
    Future.microtask(() => loadInitialData());
  }

  void getArgs() {
    var idArg = Mahas.argument('id');
    final currentLocationId = idArg != null ? idArg.toString() : '';
    final currentLocationName = Mahas.argument<String>('name') ?? '';

    state = state.copyWith(
      currentLocationId: currentLocationId,
      currentLocationName: currentLocationName,
    );

    loadInitialData();
  }

  // Load initial data
  Future<void> loadInitialData() async {
    await loadLocationDetail(state.currentLocationId.isNotEmpty
        ? state.currentLocationId
        : state.currentLocationName);
  }

  // Load detail Location
  Future<void> loadLocationDetail(String identifier) async {
    // Skip if already loading the same Location
    if (state.isLoading &&
        (state.currentLocationId == identifier ||
            state.currentLocationName == identifier)) {
      return;
    }

    try {
      state = state.copyWith(isLoading: true, clearError: true);

      if (identifier.isEmpty) {
        throw Exception('Location ID or name is required');
      }

      final locationData = await _locationService.getLocationDetail(identifier);

      state = state.copyWith(
        isLoading: false,
        location: locationData,
        currentLocationId: locationData.id.toString(),
        currentLocationName: locationData.name,
      );
    } catch (e, stackTrace) {
      logger.e('Error loading location detail: $e', stackTrace: stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  // Refresh data
  Future<void> refresh() async {
    await loadLocationDetail(state.currentLocationId.isNotEmpty
        ? state.currentLocationId
        : state.currentLocationName);
  }
}
