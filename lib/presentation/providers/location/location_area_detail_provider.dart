import '../../../core/base/base_provider.dart';
import '../../../core/utils/mahas.dart';
import '../../../data/datasource/models/location_model.dart';
import '../../../data/datasource/network/service/location_service.dart';

class LocationAreaDetailProvider extends BaseProvider {
  // Service
  final LocationService _service = LocationService();

  // Data state
  LocationAreaDetail? _areaDetail;
  LocationAreaDetail? get areaDetail => _areaDetail;

  void _setAreaDetail(LocationAreaDetail? value) {
    if (_areaDetail != value) {
      _areaDetail = value;
      notifyPropertyListeners('areaDetail');
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

  String _currentAreaId = '';
  String get currentAreaId => _currentAreaId;

  void _setCurrentAreaId(String value) {
    if (_currentAreaId != value) {
      _currentAreaId = value;
      notifyPropertyListeners('currentAreaId');
    }
  }

  String _currentAreaName = '';
  String get currentAreaName => _currentAreaName;

  void _setCurrentAreaName(String value) {
    if (_currentAreaName != value) {
      _currentAreaName = value;
      notifyPropertyListeners('currentAreaName');
    }
  }

  String _locationName = '';
  String get locationName => _locationName;

  void _setLocationName(String value) {
    if (_locationName != value) {
      _locationName = value;
      notifyPropertyListeners('locationName');
    }
  }

  // Lifecycle methods
  @override
  void onInit() {
    super.onInit();

    // Get args without notification during build phase
    var idArg = Mahas.argument('id');
    _currentAreaId = idArg != null ? idArg.toString() : '';
    _currentAreaName = Mahas.argument<String>('name') ?? '';
    _locationName = Mahas.argument<String>('locationName') ?? '';

    // Use microtask to delay loading until after build phase
    Future.microtask(() {
      // Now it's safe to notify
      notifyPropertyListeners('currentAreaId');
      notifyPropertyListeners('currentAreaName');
      notifyPropertyListeners('locationName');

      // Load data
      loadInitialData();
    });
  }

  void getArgs() {
    var idArg = Mahas.argument('id');
    _setCurrentAreaId(idArg != null ? idArg.toString() : '');
    _setCurrentAreaName(Mahas.argument<String>('name') ?? '');
    _setLocationName(Mahas.argument<String>('locationName') ?? '');
  }

  // Load initial data
  Future<void> loadInitialData() async {
    await loadAreaDetail(
        _currentAreaId.isNotEmpty ? _currentAreaId : _currentAreaName);
  }

  // Load detail Location Area
  Future<void> loadAreaDetail(String identifier) async {
    // Skip if already loading the same Area
    if (_isLoading &&
        (_currentAreaId == identifier || _currentAreaName == identifier)) {
      return;
    }

    _setLoading(true);
    _setHasError(false);
    _setErrorMessage('');
    _setCurrentAreaName(identifier);

    try {
      if (identifier.isEmpty) {
        throw Exception('Location Area ID or name is required');
      }

      final areaData = await _service.getLocationAreaDetail(identifier);
      _setAreaDetail(areaData);
      _setCurrentAreaId(areaData.id.toString());

      // Update location name if it's empty and we have areaDetail
      if (_locationName.isEmpty) {
        _setLocationName(_capitalizeFirstLetter(areaData.location.name));
      }
    } catch (e, stackTrace) {
      logger.e('Error loading location area detail: $e',
          stackTrace: stackTrace);
      _setHasError(true);
      _setErrorMessage('Failed to load location area details');
    } finally {
      _setLoading(false);
    }
  }

  // Refresh data
  Future<void> refresh() async {
    await loadAreaDetail(
        _currentAreaId.isNotEmpty ? _currentAreaId : _currentAreaName);
  }

  // Helper method to get pokemon encounters
  List<PokemonEncounter> getPokemonEncounters() {
    if (_areaDetail?.pokemonEncounters == null) return [];
    return _areaDetail!.pokemonEncounters!;
  }

  // Helper method to get location name
  String getLocationName() {
    if (_locationName.isNotEmpty) return _locationName;
    if (_areaDetail?.location.name != null) {
      return _capitalizeFirstLetter(_areaDetail!.location.name);
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
