import '../../../core/base/base_provider.dart';
import '../../../core/utils/mahas.dart';
import '../../../data/models/location_model.dart';
import '../../../data/datasource/network/service/location_service.dart';

class LocationDetailProvider extends BaseProvider {
  // Service
  final LocationService _service = LocationService();

  // Data state
  Location? _location;
  Location? get location => _location;

  void _setLocation(Location? value) {
    if (_location != value) {
      _location = value;
      notifyPropertyListeners('location');
    }
  }

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyPropertyListeners('isLoading');
    }
  }

  bool _hasError = false;
  bool get hasError => _hasError;

  void _setHasError(bool value) {
    if (_hasError != value) {
      _hasError = value;
      notifyPropertyListeners('hasError');
    }
  }

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  void _setErrorMessage(String value) {
    if (_errorMessage != value) {
      _errorMessage = value;
      notifyPropertyListeners('errorMessage');
    }
  }

  String _currentLocationId = '';
  String get currentLocationId => _currentLocationId;

  void _setCurrentLocationId(String value) {
    if (_currentLocationId != value) {
      _currentLocationId = value;
      notifyPropertyListeners('currentLocationId');
    }
  }

  String _currentLocationName = '';
  String get currentLocationName => _currentLocationName;

  void _setCurrentLocationName(String value) {
    if (_currentLocationName != value) {
      _currentLocationName = value;
      notifyPropertyListeners('currentLocationName');
    }
  }

  // Lifecycle methods
  @override
  void onInit() {
    super.onInit();

    // Get args without notification during build phase
    // Handle possible integer ID
    var idArg = Mahas.argument('id');
    _currentLocationId = idArg != null ? idArg.toString() : '';
    _currentLocationName = Mahas.argument<String>('name') ?? '';

    // Use microtask to delay loading until after build phase
    Future.microtask(() {
      // Now it's safe to notify
      notifyPropertyListeners('currentLocationId');
      notifyPropertyListeners('currentLocationName');

      // Load data
      loadInitialData();
    });
  }

  void getArgs() {
    _setCurrentLocationId(Mahas.argument<String>('id') ?? '');
    _setCurrentLocationName(Mahas.argument<String>('name') ?? '');
  }

  // Load initial data
  Future<void> loadInitialData() async {
    await loadLocationDetail(_currentLocationId.isNotEmpty
        ? _currentLocationId
        : _currentLocationName);
  }

  // Load detail Location
  Future<void> loadLocationDetail(String identifier) async {
    // Skip if already loading the same Location
    if (_isLoading &&
        (_currentLocationId == identifier ||
            _currentLocationName == identifier)) {
      return;
    }

    _setLoading(true);
    _setHasError(false);
    _setErrorMessage('');

    try {
      if (identifier.isEmpty) {
        throw Exception('Location ID or name is required');
      }

      final locationData = await _service.getLocationDetail(identifier);
      _setLocation(locationData);
      _setCurrentLocationId(locationData.id.toString());
      _setCurrentLocationName(locationData.name);
    } catch (e, stackTrace) {
      logger.e('Error loading location detail: $e', stackTrace: stackTrace);
      _setHasError(true);
      _setErrorMessage('Failed to load location details');
    } finally {
      _setLoading(false);
    }
  }

  // Refresh data
  Future<void> refresh() async {
    await loadLocationDetail(_currentLocationId.isNotEmpty
        ? _currentLocationId
        : _currentLocationName);
  }

  // Helper method to get region name
  String getRegionName() {
    if (_location?.region == null) return 'Unknown Region';
    return _location!.region!.name;
  }
}
