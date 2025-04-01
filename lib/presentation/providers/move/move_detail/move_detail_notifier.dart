import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/base/base_state_notifier.dart';
import '../../../../core/utils/mahas.dart';
import '../../../../data/models/move_model.dart';
import '../../../../data/datasource/network/service/move_service.dart';
import 'move_detail_state.dart';

class MoveDetailNotifier extends BaseStateNotifier<MoveDetailState> {
  final MoveService _moveService;

  MoveDetailNotifier(super.initialState, super.ref, this._moveService);

  @override
  void dispose() {
    state.scrollController.dispose();
    state.searchController.dispose();
    super.dispose();
  }

  @override
  void onInit() {
    super.onInit();
    getArgs();
  }

  void getArgs() {
    final args = Mahas.arguments();
    if (args.isNotEmpty) {
      final String id = args['id'] ?? '';
      loadMoveDetail(id);
    }
  }

  void _onSearchChanged() {
    state = state.copyWith(
      searchQuery: state.searchController.text,
      isLoadingSearch: true,
    );

    // Simulasi delay untuk animasi loading
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      state = state.copyWith(isLoadingSearch: false);
    });
  }

  Future<void> loadMoveDetail(String id) async {
    if (id.isEmpty) return;

    try {
      state = state.copyWith(isLoading: true, clearError: true);
      final move = await _moveService.getMoveDetail(id);
      if (!mounted) return;
      state = state.copyWith(
        move: move,
        isLoading: false,
      );
    } catch (e, stackTrace) {
      if (!mounted) return;
      state = state.copyWith(
        error: e.toString(),
        stackTrace: stackTrace,
        isLoading: false,
      );
      rethrow;
    }
  }
}
