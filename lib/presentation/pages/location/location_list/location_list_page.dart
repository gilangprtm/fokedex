import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/mahas/widget/mahas_searchbar.dart';
import '../../../../core/mahas/widget/mahas_loader.dart';
import '../../../../core/mahas/widget/mahas_button.dart';
import '../../../../core/mahas/widget/mahas_tile.dart';
import '../../../../core/mahas/mahas_type.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typografi.dart';
import '../../../../core/utils/mahas.dart';
import '../../../../data/models/api_response_model.dart';
import '../../../providers/location/location_list/location_list_provider.dart';
import '../../../routes/app_routes.dart';

class LocationListPage extends ConsumerWidget {
  const LocationListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only watch loading, error states and items at the top level
    final notifier = ref.read(locationListProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pokémon Locations',
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
            builder: (context, ref, _) {
              final searchController = ref.watch(locationListProvider
                  .select((state) => state.searchController));
              return MahasSearchBar(
                controller: searchController,
                hintText: 'Search Locations',
                onChanged: (value) => notifier.onSearchChanged(value),
                onClear: notifier.clearSearch,
              );
            },
          ),

          // Item list
          Expanded(
            child: _buildItemList(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildItemList(BuildContext context, WidgetRef ref) {
    final isLoading =
        ref.watch(locationListProvider.select((state) => state.isLoading));
    final error =
        ref.watch(locationListProvider.select((state) => state.error));
    final locations = ref
        .watch(locationListProvider.select((state) => state.displayLocations));
    final hasMore =
        ref.watch(locationListProvider.select((state) => state.hasMore));
    final notifier = ref.read(locationListProvider.notifier);

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: AppColors.errorColor),
            const SizedBox(height: 16),
            Text(
              'Error loading Items',
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
              onPressed: () => notifier.refresh(),
              type: ButtonType.primary,
              color: AppColors.pokemonRed,
            ),
          ],
        ),
      );
    }

    if (isLoading && locations.isEmpty) {
      return const MahasLoader(isLoading: true);
    }

    if (locations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.backpack, size: 48, color: AppColors.pokemonGray),
            const SizedBox(height: 16),
            Text(
              'No Locations Found',
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
              onPressed: () => notifier.clearSearch(),
              type: ButtonType.primary,
              color: AppColors.pokemonRed,
            ),
          ],
        ),
      );
    }

    return Consumer(
      builder: (context, ref, _) {
        final scrollController = ref.watch(
            locationListProvider.select((state) => state.scrollController));

        return RefreshIndicator(
          onRefresh: () => notifier.refresh(),
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.all(AppTheme.spacing16),
            itemCount: locations.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < locations.length) {
                final location = locations[index];
                return _buildItemItem(context, location);
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

  Widget _buildItemItem(BuildContext context, ResourceListItem item) {
    // Extract the item ID from the URL to potentially customize the tile
    final url = item.url;
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    final itemId = int.parse(pathSegments[pathSegments.length - 2]);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MahasTile(
        onTap: () => _navigateToLocationDetail(context, item),
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
              '#${itemId.toString().padLeft(3, '0')}',
              style: const TextStyle(
                color: AppColors.pokemonRed,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        title: Text(
          _formatItemName(item.name),
          style: AppTypography.subtitle1.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.pokemonRed),
      ),
    );
  }

  void _navigateToLocationDetail(BuildContext context, ResourceListItem item) {
    // Navigate to item detail page
    Mahas.routeTo(
      AppRoutes.locationDetail,
      arguments: {
        'id': item.id,
        'name': item.name,
      },
    );
  }

  String _formatItemName(String name) {
    // Format nama item (contoh: "master-ball" menjadi "Master Ball")
    return name
        .split('-')
        .map((word) =>
            word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }
}
