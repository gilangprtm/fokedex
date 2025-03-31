import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/mahas/widget/mahas_searchbar.dart';
import '../../../../core/mahas/widget/mahas_loader.dart';
import '../../../../core/mahas/widget/mahas_button.dart';
import '../../../../core/mahas/mahas_type.dart';
import '../../../../core/utils/mahas.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_typografi.dart';
import '../../../../data/models/api_response_model.dart';
import '../../../providers/move/move_list/move_list_provider.dart';
import '../../../routes/app_routes.dart';
import '../../../../core/mahas/widget/mahas_tile.dart';

class MoveListPage extends ConsumerWidget {
  const MoveListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(moveListProvider.notifier);
    final state = ref.watch(moveListProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pokémon Moves',
          style: AppTypography.headline6.copyWith(color: Colors.white),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.pokemonRed,
      ),
      body: Column(
        children: [
          // Search bar
          Consumer(
            builder: (context, ref, child) {
              return MahasSearchBar(
                controller: state.searchController,
                hintText: 'Search moves',
                onChanged: (value) => notifier.onSearchChanged(value),
                onClear: notifier.clearSearch,
              );
            },
          ),

          // Move list
          Expanded(
            child: _buildMoveList(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildMoveList(BuildContext context, WidgetRef ref) {
    return Consumer(
      builder: (context, ref, _) {
        final state = ref.watch(moveListProvider);
        final notifier = ref.read(moveListProvider.notifier);
        final error = state.error;
        final isLoading = state.isLoading;
        final scrollController = state.scrollController;
        final activeMoves = state.filteredMoves;

        if (error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: AppColors.errorColor),
                const SizedBox(height: 16),
                Text(
                  'Error loading Moves',
                  style: AppTypography.headline6,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: AppTypography.bodyText2,
                ),
                const SizedBox(height: 16),
                MahasButton(
                  text: 'Retry',
                  onPressed: () => notifier.loadMoves(refresh: true),
                  type: ButtonType.primary,
                  color: AppColors.pokemonRed,
                ),
              ],
            ),
          );
        }

        if (isLoading && activeMoves.isEmpty) {
          return const MahasLoader(isLoading: true);
        }

        if (activeMoves.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.model_training,
                    size: 48, color: AppColors.pokemonGray),
                const SizedBox(height: 16),
                Text(
                  'No Moves Found',
                  style: AppTypography.headline6,
                ),
                const SizedBox(height: 8),
                Text(
                  'Try changing your search criteria',
                  style: AppTypography.bodyText2,
                ),
                const SizedBox(height: 16),
                MahasButton(
                  text: 'Clear Search',
                  onPressed: notifier.clearSearch,
                  type: ButtonType.primary,
                  color: AppColors.pokemonRed,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => notifier.loadMoves(refresh: true),
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.all(AppTheme.spacing16),
            itemCount: activeMoves.length,
            itemBuilder: (context, index) {
              if (index < activeMoves.length) {
                final move = activeMoves[index];
                return _buildMoveItem(context, move);
              } else {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.pokemonRed),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildMoveItem(BuildContext context, ResourceListItem move) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MahasTile(
        onTap: () => _navigateToMoveDetail(context, move),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        backgroundColor: Colors.white,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.pokemonRed.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              '#${move.id.toString().padLeft(3, '0')}',
              style: const TextStyle(
                color: AppColors.pokemonRed,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        title: Text(
          _formatMoveName(move.name),
          style: AppTypography.subtitle1.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.pokemonRed),
      ),
    );
  }

  void _navigateToMoveDetail(BuildContext context, ResourceListItem move) {
    Mahas.routeTo(
      AppRoutes.moveDetail,
      arguments: {
        'id': move.id.toString(),
        'name': move.name,
      },
    );
  }

  String _formatMoveName(String name) {
    return name
        .split('-')
        .map((word) =>
            word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }
}
