import '../../../core/base/base_provider.dart';
import '../../../core/utils/mahas.dart';
import '../../../data/datasource/network/service/ability_service.dart';
import '../../../data/models/ability_model.dart';

class AbilityDetailProvider extends BaseProvider {
  final AbilityService _service = AbilityService();

  Ability? _abilityDetail;
  Ability? get abilityDetail => _abilityDetail;

  void _setAbilityDetail(Ability? value) {
    if (_abilityDetail != value) {
      _abilityDetail = value;
      notifyPropertyListeners('abilityDetail');
    }
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyPropertyListeners('isLoading');
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

  bool _hasError = false;
  bool get hasError => _hasError;

  void _setHasError(bool value) {
    if (_hasError != value) {
      _hasError = value;
      notifyPropertyListeners('hasError');
    }
  }

  String _currentAbilityName = '';
  String get currentAbilityName => _currentAbilityName;

  void _setCurrentAbilityName(String value) {
    if (_currentAbilityName != value) {
      _currentAbilityName = value;
      notifyPropertyListeners('currentAbilityName');
    }
  }

  String _currentAbilityId = '';
  String get currentAbilityId => _currentAbilityId;

  void _setCurrentAbilityId(String value) {
    if (_currentAbilityId != value) {
      _currentAbilityId = value;
      notifyPropertyListeners('currentAbilityId');
    }
  }

  @override
  void onInit() {
    super.onInit();

    // Get args without notification during build phase
    _currentAbilityId = Mahas.argument<String>('id') ?? '';
    _currentAbilityName = Mahas.argument<String>('name') ?? '';

    // Use microtask to delay loading until after build phase
    Future.microtask(() {
      // Now it's safe to notify
      notifyPropertyListeners('currentAbilityId');
      notifyPropertyListeners('currentAbilityName');

      // Load data
      loadInitialData();
    });
  }

  void getArgs() {
    _setCurrentAbilityId(Mahas.argument<String>('id') ?? '');
    _setCurrentAbilityName(Mahas.argument<String>('name') ?? '');
  }

  Future<void> loadInitialData() async {
    await loadAbilityDetail(
        _currentAbilityId.isNotEmpty ? _currentAbilityId : _currentAbilityName);
  }

  Future<void> loadAbilityDetail(String identifier) async {
    // Skip if already loading the same Ability
    if (_isLoading &&
        (_currentAbilityId == identifier ||
            _currentAbilityName == identifier)) {
      return;
    }

    _setLoading(true);
    _setHasError(false);
    _setErrorMessage('');
    _setCurrentAbilityName(identifier);

    try {
      final ability = await _service.getAbilityDetail(identifier);
      _setAbilityDetail(ability);
      _setCurrentAbilityId(ability.id.toString());
    } catch (e, stackTrace) {
      logger.e('Error loading ability detail: $e', stackTrace: stackTrace);
      _setHasError(true);
      _setErrorMessage('Failed to load ability details');
    } finally {
      _setLoading(false);
    }
  }

  String getAbilityDescription() {
    if (_abilityDetail?.effectEntries == null ||
        _abilityDetail!.effectEntries!.isEmpty) {
      return 'No description available';
    }

    final englishEffect = _abilityDetail!.effectEntries!.firstWhere(
      (effect) => effect.language.name == 'en',
      orElse: () => _abilityDetail!.effectEntries!.first,
    );
    return englishEffect.effect;
  }

  List<AbilityPokemon> getPokemonWithAbility() {
    if (_abilityDetail?.pokemon == null) return [];
    return _abilityDetail!.pokemon!;
  }
}
