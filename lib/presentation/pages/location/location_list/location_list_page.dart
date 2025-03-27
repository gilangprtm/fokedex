import 'package:flutter/material.dart';
import '../../../../core/base/provider_widget.dart';
import '../../../../core/mahas/widget/mahas_searchbar.dart';
import '../../../../core/mahas/widget/mahas_loader.dart';
import '../../../../core/mahas/widget/mahas_button.dart';
import '../../../../core/mahas/widget/mahas_tile.dart';
import '../../../../core/mahas/mahas_type.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typografi.dart';
import '../../../../core/utils/mahas.dart';
import '../../../../data/datasource/models/api_response_model.dart';
import '../../../providers/location/location_list_provider.dart';
import '../../../routes/app_routes.dart';

class LocationListPage extends StatelessWidget {
  const LocationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderPage<LocationListProvider>(
      createProvider: () => LocationListProvider(),
      builder: (context, provider) => _buildLocationListPage(context, provider),
    );
  }

  Widget _buildLocationListPage(
      BuildContext context, LocationListProvider provider) {
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
          MahasSearchBar(
            controller: provider.searchController,
            hintText: 'Search Locations',
            onChanged: provider.onSearchChanged,
            onClear: provider.clearSearch,
          ),

          // Location list
          Expanded(
            child: _buildLocationList(context, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationList(
      BuildContext context, LocationListProvider provider) {
    return PropertySelector<LocationListProvider, Map<String, dynamic>>(
      property: 'filteredLocations',
      selector: (provider) => {
        'isLoading': provider.isLoading,
        'hasError': provider.hasError,
        'errorMessage': provider.errorMessage,
        'filteredLocations': provider.filteredLocations,
        'hasMore': provider.hasMore,
      },
      builder: (context, data) {
        final isLoading = data['isLoading'] as bool;
        final hasError = data['hasError'] as bool;
        final errorMessage = data['errorMessage'] as String;
        final filteredLocations =
            data['filteredLocations'] as List<ResourceListItem>;
        final hasMore = data['hasMore'] as bool;

        if (hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: AppColors.errorColor),
                const SizedBox(height: 16),
                Text(
                  'Error loading Locations',
                  style: AppTypography.headline6,
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  style: AppTypography.bodyText2,
                ),
                const SizedBox(height: 16),
                MahasButton(
                  text: 'Retry',
                  onPressed: () => provider.refresh(),
                  type: ButtonType.primary,
                  color: AppColors.pokemonRed,
                ),
              ],
            ),
          );
        }

        if (isLoading && filteredLocations.isEmpty) {
          return const MahasLoader(isLoading: true);
        }

        if (filteredLocations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_off,
                    size: 48, color: AppColors.pokemonGray),
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
            itemCount: filteredLocations.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < filteredLocations.length) {
                final location = filteredLocations[index];
                return _buildLocationItem(context, location);
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

  Widget _buildLocationItem(BuildContext context, ResourceListItem location) {
    // Extract the location ID from the URL to potentially customize the tile
    final url = location.url;
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    final locationId = int.parse(pathSegments[pathSegments.length - 2]);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MahasTile(
        onTap: () => _navigateToLocationDetail(context, location),
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
              '#${locationId.toString().padLeft(3, '0')}',
              style: const TextStyle(
                color: AppColors.pokemonRed,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        title: Text(
          _formatLocationName(location.name),
          style: AppTypography.subtitle1.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.pokemonRed),
      ),
    );
  }

  void _navigateToLocationDetail(
      BuildContext context, ResourceListItem location) {
    // Extract the location ID from the URL
    final url = location.url;
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    final locationId = pathSegments[pathSegments.length - 2];

    // Navigate to location detail page
    Mahas.routeTo(
      AppRoutes.locationDetail,
      arguments: {
        'id': locationId,
        'name': location.name,
      },
    );
  }

  String _formatLocationName(String name) {
    // Format nama lokasi (contoh: "kanto-route-1" menjadi "Kanto Route 1")
    return name
        .split('-')
        .map((word) =>
            word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }
}
