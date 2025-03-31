import 'package:flutter_pokedex/core/utils/mahas.dart';
import '../../../core/base/base_provider.dart';
import '../../../data/models/move_model.dart';
import '../../../data/datasource/network/service/move_service.dart';

class MoveDetailProvider extends BaseProvider {
  // Service untuk mengambil data Move
  final MoveService _moveService = MoveService();

  // State untuk detail Move
  Move? _moveDetail;
  Move? get moveDetail => _moveDetail;

  void _setMoveDetail(Move? value) {
    if (_moveDetail != value) {
      _moveDetail = value;
      notifyPropertyListeners('moveDetail');

      // Also notify derived properties
      if (value != null) {
        notifyPropertyListeners('movePower');
        notifyPropertyListeners('moveAccuracy');
        notifyPropertyListeners('movePP');
        notifyPropertyListeners('moveType');
        notifyPropertyListeners('moveDamageClass');
        notifyPropertyListeners('moveDescription');
        notifyPropertyListeners('pokemonWithMove');
      }
    }
  }

  // State untuk loading dan error
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

  // Untuk menyimpan ID dan Nama Move yang sedang ditampilkan
  String _currentMoveId = '';
  String get currentMoveId => _currentMoveId;

  void _setCurrentMoveId(String value) {
    if (_currentMoveId != value) {
      _currentMoveId = value;
      notifyPropertyListeners('currentMoveId');
    }
  }

  String _currentMoveName = '';
  String get currentMoveName => _currentMoveName;

  void _setCurrentMoveName(String value) {
    if (_currentMoveName != value) {
      _currentMoveName = value;
      notifyPropertyListeners('currentMoveName');
    }
  }

  @override
  void onInit() {
    super.onInit();

    // Get args without notification during build phase
    _currentMoveId = Mahas.argument<String>('id') ?? '';
    _currentMoveName = Mahas.argument<String>('name') ?? '';

    // Use microtask to delay loading until after build phase
    Future.microtask(() {
      // Now it's safe to notify
      notifyPropertyListeners('currentMoveId');
      notifyPropertyListeners('currentMoveName');

      // Start loading
      loadMoveDetail(
          _currentMoveId.isNotEmpty ? _currentMoveId : _currentMoveName);
    });
  }

  void getArgs() {
    _setCurrentMoveId(Mahas.argument<String>('id') ?? '');
    _setCurrentMoveName(Mahas.argument<String>('name') ?? '');
  }

  // Load detail Move berdasarkan ID atau nama
  Future<void> loadMoveDetail(String idOrName) async {
    // Skip if already loading the same Move
    if (_isLoading &&
        (_currentMoveId == idOrName || _currentMoveName == idOrName)) {
      return;
    }

    _setLoading(true);
    _setHasError(false);
    _setErrorMessage('');

    try {
      // Load Move detail
      final moveData = await _moveService.getMoveDetail(idOrName);

      // Update current ID and name
      _setCurrentMoveId(moveData.id.toString());
      _setCurrentMoveName(moveData.name);

      // Set move detail at the end to trigger a single notification for the detail
      _setMoveDetail(moveData);

      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setHasError(true);
      _setErrorMessage('Failed to load Move detail: $e');
      logger.e(_errorMessage);
    }
  }

  // Get the formatted move power
  String getMovePower() {
    if (_moveDetail == null || _moveDetail!.power == null) {
      return 'N/A';
    }
    return _moveDetail!.power.toString();
  }

  // Get the formatted move accuracy
  String getMoveAccuracy() {
    if (_moveDetail == null || _moveDetail!.accuracy == null) {
      return 'N/A';
    }
    return '${_moveDetail!.accuracy}%';
  }

  // Get the formatted move PP (Power Points)
  String getMovePP() {
    if (_moveDetail == null || _moveDetail!.pp == null) {
      return 'N/A';
    }
    return _moveDetail!.pp.toString();
  }

  // Get move type
  String getMoveType() {
    if (_moveDetail == null || _moveDetail!.type == null) {
      return 'normal';
    }
    return _moveDetail!.type!.name;
  }

  // Get move damage class (physical, special, status)
  String getMoveDamageClass() {
    if (_moveDetail == null || _moveDetail!.damageClass == null) {
      return 'unknown';
    }
    return _moveDetail!.damageClass!.name;
  }

  // Get move description
  String getMoveDescription() {
    if (_moveDetail == null ||
        _moveDetail!.flavorTextEntries == null ||
        _moveDetail!.flavorTextEntries!.isEmpty) {
      return 'No description available.';
    }

    // Find English flavor text
    final englishEntries = _moveDetail!.flavorTextEntries!
        .where((entry) => entry.language.name == 'en')
        .toList();

    if (englishEntries.isEmpty) {
      return 'No English description available.';
    }

    // Get the most recent English flavor text
    String flavorText = englishEntries.last.flavorText;

    // Clean up the text by removing newlines and multiple spaces
    flavorText = flavorText.replaceAll('\n', ' ').replaceAll('\f', ' ');
    flavorText = flavorText.replaceAll(RegExp(r'\s{2,}'), ' ');

    return flavorText;
  }

  // Get pokemon that can learn this move
  List<MoveLearnedByPokemon> getPokemonWithMove() {
    if (_moveDetail == null ||
        _moveDetail!.learnedByPokemon == null ||
        _moveDetail!.learnedByPokemon!.isEmpty) {
      return [];
    }

    return _moveDetail!.learnedByPokemon!;
  }
}
