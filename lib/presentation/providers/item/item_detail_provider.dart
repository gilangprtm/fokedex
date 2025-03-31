import '../../../core/base/base_provider.dart';
import '../../../core/utils/mahas.dart';
import '../../../data/models/item_model.dart';
import '../../../data/datasource/network/service/item_service.dart';

class ItemDetailProvider extends BaseProvider {
  final ItemService _service = ItemService();

  Item? _itemDetail;
  Item? get itemDetail => _itemDetail;

  void _setItemDetail(Item? value) {
    if (_itemDetail != value) {
      _itemDetail = value;
      notifyPropertyListeners('itemDetail');
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

  String _currentItemName = '';
  String get currentItemName => _currentItemName;

  void _setCurrentItemName(String value) {
    if (_currentItemName != value) {
      _currentItemName = value;
      notifyPropertyListeners('currentItemName');
    }
  }

  String _currentItemId = '';
  String get currentItemId => _currentItemId;

  void _setCurrentItemId(String value) {
    if (_currentItemId != value) {
      _currentItemId = value;
      notifyPropertyListeners('currentItemId');
    }
  }

  @override
  void onInit() {
    super.onInit();

    // Get args without notification during build phase
    // Convert id to string since it might be an integer
    var idArg = Mahas.argument('id');
    _currentItemId = idArg != null ? idArg.toString() : '';
    _currentItemName = Mahas.argument<String>('name') ?? '';

    // Use microtask to delay loading until after build phase
    Future.microtask(() {
      // Now it's safe to notify
      notifyPropertyListeners('currentItemId');
      notifyPropertyListeners('currentItemName');

      // Load data
      loadInitialData();
    });
  }

  void getArgs() {
    _setCurrentItemId(Mahas.argument<String>('id') ?? '');
    _setCurrentItemName(Mahas.argument<String>('name') ?? '');
  }

  Future<void> loadInitialData() async {
    await loadItemDetail(
        _currentItemId.isNotEmpty ? _currentItemId : _currentItemName);
  }

  Future<void> loadItemDetail(String identifier) async {
    // Skip if already loading the same Item
    if (_isLoading &&
        (_currentItemId == identifier || _currentItemName == identifier)) {
      return;
    }

    _setLoading(true);
    _setHasError(false);
    _setErrorMessage('');

    try {
      final item = await _service.getItemDetail(identifier);
      _setItemDetail(item);
      _setCurrentItemId(item.id.toString());
      _setCurrentItemName(item.name);
    } catch (e, stackTrace) {
      logger.e('Error loading item detail: $e', stackTrace: stackTrace);
      _setHasError(true);
      _setErrorMessage('Failed to load item details');
    } finally {
      _setLoading(false);
    }
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
