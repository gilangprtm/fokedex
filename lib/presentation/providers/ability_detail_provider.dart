import '../../core/base/base_provider.dart';
import '../../core/utils/mahas.dart';
import '../../data/datasource/network/service/ability_service.dart';
import '../../data/datasource/models/ability_model.dart';

class AbilityDetailProvider extends BaseProvider {
  final AbilityService _service = AbilityService();

  Ability? _abilityDetail;
  Ability? get abilityDetail => _abilityDetail;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  bool _hasError = false;
  bool get hasError => _hasError;

  String _currentAbilityName = '';
  String get currentAbilityName => _currentAbilityName;

  String _currentAbilityId = '';
  String get currentAbilityId => _currentAbilityId;

  @override
  void onInit() {
    super.onInit();
    getArgs();
    loadInitialData();
  }

  void getArgs() {
    _currentAbilityId = Mahas.argument<String>('id') ?? '';
    _currentAbilityName = Mahas.argument<String>('name') ?? '';
  }

  Future<void> loadInitialData() async {
    await runAsync('loadInitialData', () async {
      await loadAbilityDetail(_currentAbilityId.isNotEmpty
          ? _currentAbilityId
          : _currentAbilityName);
    });
  }

  Future<void> loadAbilityDetail(String identifier) async {
    // Skip if already loading the same Ability
    if (_isLoading &&
        (_currentAbilityId == identifier ||
            _currentAbilityName == identifier)) {
      return;
    }

    await runAsync('loadAbilityDetail', () async {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
      _currentAbilityName = identifier;

      try {
        _abilityDetail = await _service.getAbilityDetail(identifier);
        _currentAbilityId = _abilityDetail?.id.toString() ?? '';
      } catch (e, stackTrace) {
        logger.e('Error loading ability detail: $e', stackTrace: stackTrace);
        _hasError = true;
        _errorMessage = 'Failed to load ability details';
      } finally {
        _isLoading = false;
      }
    });
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
