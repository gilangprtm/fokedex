import '../../../../core/base/base_state_notifier.dart';
import '../../../../core/utils/mahas.dart';
import '../../../../data/datasource/network/service/item_service.dart';
import 'item_detail_state.dart';

class ItemDetailNotifier extends BaseStateNotifier<ItemDetailState> {
  final ItemService _service;

  ItemDetailNotifier(super.initialState, super.ref, this._service);

  @override
  void onInit() {
    super.onInit();
    // Get args without notification during build phase
    // Convert id to string since it might be an integer
    var idArg = Mahas.argument('id');
    final currentItemId = idArg != null ? idArg.toString() : '';
    final currentItemName = Mahas.argument<String>('name') ?? '';

    // Use microtask to delay loading until after build phase
    Future.microtask(() {
      // Update state with initial values
      state = state.copyWith(
        currentItemId: currentItemId,
        currentItemName: currentItemName,
      );

      // Load data
      loadInitialData();
    });
  }

  void getArgs() {
    var idArg = Mahas.argument('id');
    final currentItemId = idArg != null ? idArg.toString() : '';
    final currentItemName = Mahas.argument<String>('name') ?? '';

    state = state.copyWith(
      currentItemId: currentItemId,
      currentItemName: currentItemName,
    );
  }

  Future<void> loadInitialData() async {
    await loadItemDetail(state.currentItemId.isNotEmpty
        ? state.currentItemId
        : state.currentItemName);
  }

  Future<void> loadItemDetail(String identifier) async {
    // Skip if already loading the same Item
    if (state.isLoading &&
        (state.currentItemId == identifier ||
            state.currentItemName == identifier)) {
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final item = await _service.getItemDetail(identifier);
      state = state.copyWith(
        itemDetail: item,
        currentItemId: item.id.toString(),
        currentItemName: item.name,
        isLoading: false,
      );
    } catch (e, stackTrace) {
      logger.e('Error loading item detail: $e', stackTrace: stackTrace);
      state = state.copyWith(
        error: 'Failed to load item details',
        stackTrace: stackTrace,
        isLoading: false,
      );
    }
  }

  Future<void> refresh() async {
    await loadItemDetail(state.currentItemId.isNotEmpty
        ? state.currentItemId
        : state.currentItemName);
  }
}
