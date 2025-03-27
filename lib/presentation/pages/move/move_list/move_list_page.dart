import 'package:flutter/material.dart';
import '../../../../core/base/provider_widget.dart';
import '../../../../core/mahas/widget/mahas_searchbar.dart';
import '../../../../core/mahas/widget/mahas_loader.dart';
import '../../../../core/mahas/widget/mahas_button.dart';
import '../../../../core/mahas/mahas_type.dart';
import '../../../../core/utils/mahas.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_typografi.dart';
import '../../../../data/datasource/models/api_response_model.dart';
import '../../../providers/move/move_list_provider.dart';
import '../../../routes/app_routes.dart';
import '../../../../core/mahas/widget/mahas_tile.dart';

class MoveListPage extends StatelessWidget {
  const MoveListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderPage<MoveListProvider>(
      createProvider: () => MoveListProvider(),
      builder: (context, provider) => _buildMoveListPage(context, provider),
    );
  }

  Widget _buildMoveListPage(BuildContext context, MoveListProvider provider) {
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
          MahasSearchBar(
            controller: provider.searchController,
            hintText: 'Search Moves',
            onChanged: provider.onSearchChanged,
            onClear: provider.clearSearch,
          ),

          // Move list
          Expanded(
            child: _buildMoveList(context, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildMoveList(BuildContext context, MoveListProvider provider) {
    if (provider.hasError) {
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
              provider.errorMessage,
              style: AppTypography.bodyText2,
            ),
            const SizedBox(height: 16),
            MahasButton(
              text: 'Retry',
              onPressed: () => provider.loadMoveList(refresh: true),
              type: ButtonType.primary,
              color: AppColors.pokemonRed,
            ),
          ],
        ),
      );
    }

    if (provider.isLoading && provider.filteredMoveList.isEmpty) {
      return const MahasLoader(isLoading: true);
    }

    if (provider.filteredMoveList.isEmpty) {
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
              onPressed: () => provider.clearSearch(),
              type: ButtonType.primary,
              color: AppColors.pokemonRed,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.refresh(),
      child: ListView.builder(
        controller: provider.scrollController,
        padding: const EdgeInsets.all(AppTheme.spacing16),
        itemCount:
            provider.filteredMoveList.length + (provider.hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < provider.filteredMoveList.length) {
            final move = provider.filteredMoveList[index];
            return _buildMoveItem(context, move);
          } else {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.pokemonRed),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildMoveItem(BuildContext context, ResourceListItem move) {
    // Extract the move ID from the URL to potentially customize the tile
    final url = move.url;
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    final moveId = int.parse(pathSegments[pathSegments.length - 2]);

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
              '#${moveId.toString().padLeft(3, '0')}',
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
    // Extract the move ID from the URL
    final url = move.url;
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    final moveId = pathSegments[pathSegments.length - 2];

    // Navigate to move detail page
    Mahas.routeTo(
      AppRoutes.moveDetail,
      arguments: {
        'id': moveId,
        'name': move.name,
      },
    );
  }

  String _formatMoveName(String name) {
    // Format nama move (contoh: "thunder-punch" menjadi "Thunder Punch")
    return name
        .split('-')
        .map((word) =>
            word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }
}
