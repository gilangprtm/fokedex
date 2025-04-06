import '../../../../core/base/base_state_notifier.dart';
import '../../../../data/models/item_model.dart';

class ItemDetailState extends BaseState {
  // Data state
  final Item? itemDetail;
  final String currentItemId;
  final String currentItemName;

  const ItemDetailState({
    super.isLoading = false,
    super.error,
    super.stackTrace,
    this.itemDetail,
    this.currentItemId = '',
    this.currentItemName = '',
  });

  @override
  ItemDetailState copyWith({
    bool? isLoading,
    Object? error,
    StackTrace? stackTrace,
    bool clearError = false,
    Item? itemDetail,
    String? currentItemId,
    String? currentItemName,
  }) {
    return ItemDetailState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      stackTrace: clearError ? null : stackTrace ?? this.stackTrace,
      itemDetail: itemDetail ?? this.itemDetail,
      currentItemId: currentItemId ?? this.currentItemId,
      currentItemName: currentItemName ?? this.currentItemName,
    );
  }

  // Helper methods to access item data
  String getItemDescription() {
    if (itemDetail?.effectEntries == null ||
        itemDetail!.effectEntries!.isEmpty) {
      return 'No description available';
    }

    final englishEffect = itemDetail!.effectEntries!.firstWhere(
      (effect) => effect.language.name == 'en',
      orElse: () => itemDetail!.effectEntries!.first,
    );
    return englishEffect.effect;
  }

  String getItemShortEffect() {
    if (itemDetail?.effectEntries == null ||
        itemDetail!.effectEntries!.isEmpty) {
      return 'No effect available';
    }

    final englishEffect = itemDetail!.effectEntries!.firstWhere(
      (effect) => effect.language.name == 'en',
      orElse: () => itemDetail!.effectEntries!.first,
    );
    return englishEffect.shortEffect;
  }

  String getItemCategory() {
    return itemDetail?.category?.name ?? 'Unknown';
  }

  List<ItemHolderPokemon> getPokemonWithItem() {
    if (itemDetail?.heldByPokemon == null) return [];
    return itemDetail!.heldByPokemon!;
  }

  String getItemCost() {
    return '₽${itemDetail?.cost ?? 0}';
  }

  String? getItemImageUrl() {
    if (itemDetail?.sprites == null) {
      return null;
    }
    return itemDetail!.sprites!.default_;
  }
}
