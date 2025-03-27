import 'package:flutter/material.dart';
import '../../../core/base/base_provider.dart';
import '../../../core/utils/mahas.dart';
import '../../../data/datasource/models/location_model.dart';
import '../../../data/datasource/network/service/location_service.dart';

class LocationDetailProvider extends BaseProvider {
  // Service
  final LocationService _service = LocationService();

  // Data state
  Location? _location;
  Location? get location => _location;

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasError = false;
  bool get hasError => _hasError;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  String _currentLocationId = '';
  String get currentLocationId => _currentLocationId;

  String _currentLocationName = '';
  String get currentLocationName => _currentLocationName;

  // Lifecycle methods
  @override
  void onInit() {
    super.onInit();
    getArgs();
    loadInitialData();
  }

  void getArgs() {
    _currentLocationId = Mahas.argument<String>('id') ?? '';
    _currentLocationName = Mahas.argument<String>('name') ?? '';
  }

  // Load initial data
  Future<void> loadInitialData() async {
    await runAsync('loadInitialData', () async {
      await loadLocationDetail(_currentLocationId.isNotEmpty
          ? _currentLocationId
          : _currentLocationName);
    });
  }

  // Load detail Location
  Future<void> loadLocationDetail(String identifier) async {
    // Skip if already loading the same Location
    if (_isLoading &&
        (_currentLocationId == identifier ||
            _currentLocationName == identifier)) {
      return;
    }

    await runAsync('loadLocationDetail', () async {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';

      try {
        if (identifier.isEmpty) {
          throw Exception('Location ID or name is required');
        }

        _location = await _service.getLocationDetail(identifier);
        _currentLocationId = _location?.id.toString() ?? '';
        _currentLocationName = _location?.name ?? '';
      } catch (e, stackTrace) {
        logger.e('Error loading location detail: $e', stackTrace: stackTrace);
        _hasError = true;
        _errorMessage = 'Failed to load location details';
      } finally {
        _isLoading = false;
      }
    });
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
