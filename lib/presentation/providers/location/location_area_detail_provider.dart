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

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasError = false;
  bool get hasError => _hasError;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  String _currentAreaId = '';
  String get currentAreaId => _currentAreaId;

  String _currentAreaName = '';
  String get currentAreaName => _currentAreaName;

  String _locationName = '';
  String get locationName => _locationName;

  // Lifecycle methods
  @override
  void onInit() {
    super.onInit();
    getArgs();
    loadInitialData();
  }

  void getArgs() {
    _currentAreaId = Mahas.argument<int>('id')?.toString() ?? '';
    _currentAreaName = Mahas.argument<String>('name') ?? '';
    _locationName = Mahas.argument<String>('locationName') ?? '';
  }

  // Load initial data
  Future<void> loadInitialData() async {
    await runAsync('loadInitialData', () async {
      await loadAreaDetail(
          _currentAreaId.isNotEmpty ? _currentAreaId : _currentAreaName);
    });
  }

  // Load detail Location Area
  Future<void> loadAreaDetail(String identifier) async {
    // Skip if already loading the same Area
    if (_isLoading &&
        (_currentAreaId == identifier || _currentAreaName == identifier)) {
      return;
    }

    await runAsync('loadAreaDetail', () async {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
      _currentAreaName = identifier;

      try {
        if (identifier.isEmpty) {
          throw Exception('Location Area ID or name is required');
        }

        _areaDetail = await _service.getLocationAreaDetail(identifier);
        _currentAreaId = _areaDetail?.id.toString() ?? '';

        // Update location name if it's empty and we have areaDetail
        if (_locationName.isEmpty && _areaDetail != null) {
          _locationName = _capitalizeFirstLetter(_areaDetail!.location.name);
        }
      } catch (e, stackTrace) {
        logger.e('Error loading location area detail: $e',
            stackTrace: stackTrace);
        _hasError = true;
        _errorMessage = 'Failed to load location area details';
      } finally {
        _isLoading = false;
      }
    });
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
