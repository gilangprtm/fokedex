import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/base/base_state_notifier.dart';
import '../../../../data/datasource/network/service/type_service.dart';
import 'type_chart_state.dart';

class TypeChartNotifier extends BaseStateNotifier<TypeChartState> {
  final TypeService _typeService;

  TypeChartNotifier(this._typeService, Ref ref)
      : super(const TypeChartState(), ref);

  @override
  void onInit() {
    super.onInit();
    // Use post-frame callback to avoid changing state during build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadInitialData();
    });
  }

  Future<void> loadInitialData() async {
    await loadTypesList();
  }

  Future<void> loadTypesList() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _typeService.getTypeList();
      state = state.copyWith(typesList: response.results);

      // Load detail for each type
      if (state.typesList.isNotEmpty) {
        await loadTypeDetails();
      }
    } catch (e, stackTrace) {
      logger.e('Error loading types list: $e', stackTrace: stackTrace);
      state = state.copyWith(
        error: 'Failed to load types list',
        stackTrace: stackTrace,
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loadTypeDetails() async {
    state = state.copyWith(isLoading: true);

    try {
      // Load details for each type in parallel
      final futures =
          state.typesList.map((type) => _loadSingleTypeDetail(type.name));
      await Future.wait(futures);
    } catch (e, stackTrace) {
      logger.e('Error loading type details: $e', stackTrace: stackTrace);
      // We'll continue even if some types fail to load
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _loadSingleTypeDetail(String typeName) async {
    try {
      final typeDetail = await _typeService.getTypeDetail(typeName);
      state = state.copyWith(
        typeDetails: {...state.typeDetails, typeName: typeDetail},
      );
    } catch (e) {
      logger.e('Error loading detail for type $typeName: $e');
      // Continue with other types
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(typeDetails: {});
    await loadTypesList();
  }

  // Helper methods for the chart

  // Get the damage multiplier that attacking type does to defending type
  double getDamageMultiplier(String attackingType, String defendingType) {
    if (!state.typeDetails.containsKey(attackingType) ||
        !state.typeDetails.containsKey(defendingType)) {
      return 1.0; // Default if types not loaded
    }

    final attackerDetail = state.typeDetails[attackingType]!;

    // Check double damage
    if (attackerDetail.damageRelations.doubleDamageTo
        .any((t) => t.name == defendingType)) {
      return 2.0;
    }

    // Check half damage
    if (attackerDetail.damageRelations.halfDamageTo
        .any((t) => t.name == defendingType)) {
      return 0.5;
    }

    // Check no damage
    if (attackerDetail.damageRelations.noDamageTo
        .any((t) => t.name == defendingType)) {
      return 0.0;
    }

    return 1.0; // Normal damage
  }

  // Get a color representing effectiveness
  int getTypeColor(String typeName) {
    switch (typeName) {
      case 'normal':
        return 0xFFA8A878;
      case 'fire':
        return 0xFFF08030;
      case 'water':
        return 0xFF6890F0;
      case 'electric':
        return 0xFFF8D030;
      case 'grass':
        return 0xFF78C850;
      case 'ice':
        return 0xFF98D8D8;
      case 'fighting':
        return 0xFFC03028;
      case 'poison':
        return 0xFFA040A0;
      case 'ground':
        return 0xFFE0C068;
      case 'flying':
        return 0xFFA890F0;
      case 'psychic':
        return 0xFFF85888;
      case 'bug':
        return 0xFFA8B820;
      case 'rock':
        return 0xFFB8A038;
      case 'ghost':
        return 0xFF705898;
      case 'dragon':
        return 0xFF7038F8;
      case 'dark':
        return 0xFF705848;
      case 'steel':
        return 0xFFB8B8D0;
      case 'fairy':
        return 0xFFEE99AC;
      default:
        return 0xFF999999;
    }
  }

  // Format type name for display
  String formatTypeName(String typeName) {
    if (typeName.isEmpty) return '';
    return typeName[0].toUpperCase() + typeName.substring(1);
  }
}
