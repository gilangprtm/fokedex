import '../../../../core/base/base_state_notifier.dart';
import '../../../../data/datasource/network/service/move_service.dart';
import 'move_list_state.dart';

class MoveListNotifier extends BaseStateNotifier<MoveListState> {
  final MoveService _moveService;

  MoveListNotifier(super.initialState, super.ref, this._moveService);

  @override
  void onInit() {
    state.searchController.addListener(() {
      onSearchChanged(state.searchController.text);
    });
    _setupScrollListener();
    loadMoves();
    super.onInit();
  }

  @override
  void onClose() {
    state.scrollController.dispose();
    state.searchController.dispose();
    super.onClose();
  }

  void _setupScrollListener() {
    state.scrollController.addListener(() {
      if (state.scrollController.position.pixels >=
          state.scrollController.position.maxScrollExtent - 200) {
        loadMoves();
      }
    });
  }

  Future<void> loadMoves({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        moves: [],
        filteredMoves: [],
        isLoading: true,
      );
    }

    if (state.isLoading && !refresh) {
      return;
    }

    try {
      state = state.copyWith(isLoading: true);

      final response = await _moveService.getMoveList(limit: 1000);

      state = state.copyWith(
        moves: [...state.moves, ...response.results],
        filteredMoves: response.results,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  void onSearchChanged(String value) {
    if (value.isEmpty) {
      state = state.copyWith(
        filteredMoves: state.moves,
        isLoading: false,
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
    );

    final query = value.toLowerCase();
    final filteredMoves = state.moves.where((move) {
      return move.normalizedName.toLowerCase().contains(query);
    }).toList();

    state = state.copyWith(
      filteredMoves: filteredMoves,
      isLoading: false,
    );
  }

  void clearSearch() {
    state.searchController.clear();
    state = state.copyWith(
      filteredMoves: state.moves,
      isLoading: false,
    );
  }
}
