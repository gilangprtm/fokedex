import '../../../../core/base/base_state_notifier.dart';
import '../../../../core/utils/mahas.dart';
import '../../../../data/datasource/network/service/ability_service.dart';
import '../../../../data/models/ability_model.dart';
import 'ability_detail_state.dart';

class AbilityDetailNotifier extends BaseStateNotifier<AbilityDetailState> {
  final AbilityService _abilityService;

  AbilityDetailNotifier(super.initialState, super.ref, this._abilityService);

  @override
  void onInit() {
    super.onInit();
    getArgs();
  }

  @override
  void onClose() {
    state.scrollController.dispose();
    state.searchController.dispose();
    super.onClose();
  }

  void getArgs() {
    final args = Mahas.arguments();
    if (args.isNotEmpty) {
      final int id = args['id'] ?? '';
      final String name = args['name'] ?? '';

      state = state.copyWith(
        currentAbilityId: id.toString(),
        currentAbilityName: name,
      );

      loadInitialData();
    }
  }

  Future<void> loadInitialData() async {
    final identifier = state.currentAbilityId.isNotEmpty
        ? state.currentAbilityId
        : state.currentAbilityName;

    await loadAbilityDetail(identifier);
  }

  Future<void> loadAbilityDetail(String identifier) async {
    // Skip if already loading the same Ability
    if (state.isLoading &&
        (state.currentAbilityId == identifier ||
            state.currentAbilityName == identifier)) {
      return;
    }

    try {
      state = state.copyWith(
        isLoading: true,
        clearError: true,
      );

      final ability = await _abilityService.getAbilityDetail(identifier);

      if (!mounted) return;

      state = state.copyWith(
        ability: ability,
        currentAbilityId: ability.id.toString(),
        isLoading: false,
      );
    } catch (e, stackTrace) {
      if (!mounted) return;

      logger.e('Error loading ability detail: $e', stackTrace: stackTrace);

      state = state.copyWith(
        error: 'Failed to load ability details',
        stackTrace: stackTrace,
        isLoading: false,
      );
    }
  }

  String getAbilityDescription() {
    if (state.ability?.effectEntries == null ||
        state.ability!.effectEntries!.isEmpty) {
      return 'No description available';
    }

    final englishEffect = state.ability!.effectEntries!.firstWhere(
      (effect) => effect.language.name == 'en',
      orElse: () => state.ability!.effectEntries!.first,
    );
    return englishEffect.effect;
  }

  List<AbilityPokemon> getPokemonWithAbility() {
    if (state.ability?.pokemon == null) return [];
    return state.ability!.pokemon!;
  }
}
