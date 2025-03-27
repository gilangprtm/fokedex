import '../../../core/base/base_provider.dart';
import '../../../core/utils/mahas.dart';
import '../../../data/datasource/models/api_response_model.dart';
import '../../../data/datasource/models/type_model.dart' hide ResourceListItem;
import '../../../data/datasource/network/service/type_service.dart';

class TypeChartProvider extends BaseProvider {
  final TypeService _typeService = TypeService();

  // Data state
  List<ResourceListItem> _typesList = [];
  List<ResourceListItem> get typesList => _typesList;

  Map<String, TypeDetail> _typeDetails = {};
  Map<String, TypeDetail> get typeDetails => _typeDetails;

  // UI state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasError = false;
  bool get hasError => _hasError;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    await runAsync('loadInitialData', () async {
      await loadTypesList();
    });
  }

  Future<void> loadTypesList() async {
    await runAsync('loadTypesList', () async {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';

      try {
        final response = await _typeService.getTypeList();
        _typesList = response.results ?? [];

        // Load detail for each type
        if (_typesList.isNotEmpty) {
          await loadTypeDetails();
        }
      } catch (e, stackTrace) {
        logger.e('Error loading types list: $e', stackTrace: stackTrace);
        _hasError = true;
        _errorMessage = 'Failed to load types list';
      } finally {
        _isLoading = false;
      }
    });
  }

  Future<void> loadTypeDetails() async {
    await runAsync('loadTypeDetails', () async {
      _isLoading = true;

      try {
        // Load details for each type in parallel
        final futures =
            _typesList.map((type) => _loadSingleTypeDetail(type.name));
        await Future.wait(futures);
      } catch (e, stackTrace) {
        logger.e('Error loading type details: $e', stackTrace: stackTrace);
        // We'll continue even if some types fail to load
      } finally {
        _isLoading = false;
      }
    });
  }

  Future<void> _loadSingleTypeDetail(String typeName) async {
    try {
      final typeDetail = await _typeService.getTypeDetail(typeName);
      _typeDetails[typeName] = typeDetail;
    } catch (e) {
      logger.e('Error loading detail for type $typeName: $e');
      // Continue with other types
    }
  }

  Future<void> refresh() async {
    _typeDetails.clear();
    await loadTypesList();
  }

  // Helper methods for the chart

  // Get the damage multiplier that attacking type does to defending type
  double getDamageMultiplier(String attackingType, String defendingType) {
    if (!_typeDetails.containsKey(attackingType) ||
        !_typeDetails.containsKey(defendingType)) {
      return 1.0; // Default if types not loaded
    }

    final attackerDetail = _typeDetails[attackingType]!;

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
