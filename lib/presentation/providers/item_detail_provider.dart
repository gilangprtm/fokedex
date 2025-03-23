import '../../core/base/base_provider.dart';
import '../../core/utils/mahas.dart';
import '../../data/datasource/models/item_model.dart';
import '../../data/datasource/network/service/item_service.dart';

class ItemDetailProvider extends BaseProvider {
  final ItemService _service = ItemService();

  Item? _itemDetail;
  Item? get itemDetail => _itemDetail;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  bool _hasError = false;
  bool get hasError => _hasError;

  String _currentItemName = '';
  String get currentItemName => _currentItemName;

  String _currentItemId = '';
  String get currentItemId => _currentItemId;

  @override
  void onInit() {
    super.onInit();
    getArgs();
    loadInitialData();
  }

  void getArgs() {
    _currentItemId = Mahas.argument<String>('id') ?? '';
    _currentItemName = Mahas.argument<String>('name') ?? '';
  }

  Future<void> loadInitialData() async {
    await runAsync('loadInitialData', () async {
      await loadItemDetail(
          _currentItemId.isNotEmpty ? _currentItemId : _currentItemName);
    });
  }

  Future<void> loadItemDetail(String identifier) async {
    // Skip if already loading the same Item
    if (_isLoading &&
        (_currentItemId == identifier || _currentItemName == identifier)) {
      return;
    }

    await runAsync('loadItemDetail', () async {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';

      try {
        _itemDetail = await _service.getItemDetail(identifier);
        _currentItemId = _itemDetail?.id.toString() ?? '';
        _currentItemName = _itemDetail?.name ?? '';
      } catch (e, stackTrace) {
        logger.e('Error loading item detail: $e', stackTrace: stackTrace);
        _hasError = true;
        _errorMessage = 'Failed to load item details';
      } finally {
        _isLoading = false;
      }
    });
  }

  String getItemDescription() {
    if (_itemDetail?.effectEntries == null ||
        _itemDetail!.effectEntries!.isEmpty) {
      return 'No description available';
    }

    final englishEffect = _itemDetail!.effectEntries!.firstWhere(
      (effect) => effect.language.name == 'en',
      orElse: () => _itemDetail!.effectEntries!.first,
    );
    return englishEffect.effect;
  }

  String getItemShortEffect() {
    if (_itemDetail?.effectEntries == null ||
        _itemDetail!.effectEntries!.isEmpty) {
      return 'No effect available';
    }

    final englishEffect = _itemDetail!.effectEntries!.firstWhere(
      (effect) => effect.language.name == 'en',
      orElse: () => _itemDetail!.effectEntries!.first,
    );
    return englishEffect.shortEffect;
  }

  String getItemCategory() {
    return _itemDetail?.category?.name ?? 'Unknown';
  }

  List<ItemHolderPokemon> getPokemonWithItem() {
    if (_itemDetail?.heldByPokemon == null) return [];
    return _itemDetail!.heldByPokemon!;
  }

  String getItemCost() {
    return '₽${_itemDetail?.cost ?? 0}';
  }

  String? getItemImageUrl() {
    if (_itemDetail?.sprites == null) {
      return null;
    }
    return _itemDetail!.sprites!.default_;
  }
}
