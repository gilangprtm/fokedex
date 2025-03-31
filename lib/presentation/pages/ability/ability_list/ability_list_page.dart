import 'package:flutter/material.dart';
import '../../../../core/base/provider_widget.dart';
import '../../../../core/mahas/mahas_type.dart';
import '../../../../core/mahas/widget/mahas_searchbar.dart';
import '../../../../core/mahas/widget/mahas_loader.dart';
import '../../../../core/mahas/widget/mahas_button.dart';
import '../../../../core/mahas/widget/mahas_tile.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typografi.dart';
import '../../../../core/utils/mahas.dart';
import '../../../../data/models/api_response_model.dart';
import '../../../providers/ability/ability_list_provider.dart';
import '../../../routes/app_routes.dart';

class AbilityListPage extends StatelessWidget {
  const AbilityListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderPage<AbilityListProvider>(
      createProvider: () => AbilityListProvider(),
      builder: (context, provider) => _buildAbilityListPage(context, provider),
    );
  }

  Widget _buildAbilityListPage(
      BuildContext context, AbilityListProvider provider) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pokémon Abilities',
          style: AppTypography.headline6.copyWith(color: Colors.white),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.pokemonRed,
      ),
      body: Column(
        children: [
          // Search bar
          PropertySelector<AbilityListProvider, String>(
            property: 'searchQuery',
            selector: (provider) => provider.searchQuery,
            builder: (context, searchQuery) {
              return MahasSearchBar(
                controller: provider.searchController,
                hintText: 'Search Abilities',
                onChanged: provider.onSearchChanged,
                onClear: provider.clearSearch,
              );
            },
          ),

          // Ability list
          Expanded(
            child: _buildAbilityList(context, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildAbilityList(BuildContext context, AbilityListProvider provider) {
    return PropertySelector<AbilityListProvider, Map<String, dynamic>>(
      property: 'filteredAbilities',
      selector: (provider) => {
        'isLoading': provider.isLoading,
        'hasError': provider.hasError,
        'errorMessage': provider.errorMessage,
        'filteredAbilities': provider.filteredAbilities,
        'hasMore': provider.hasMore,
      },
      builder: (context, data) {
        final isLoading = data['isLoading'] as bool;
        final hasError = data['hasError'] as bool;
        final errorMessage = data['errorMessage'] as String;
        final filteredAbilities =
            data['filteredAbilities'] as List<ResourceListItem>;
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
                  'Error loading Abilities',
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
                  onPressed: () => provider.loadAbilities(refresh: true),
                  type: ButtonType.primary,
                  color: AppColors.pokemonRed,
                ),
              ],
            ),
          );
        }

        if (isLoading && filteredAbilities.isEmpty) {
          return const MahasLoader(isLoading: true);
        }

        if (filteredAbilities.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome,
                    size: 48, color: AppColors.pokemonGray),
                const SizedBox(height: 16),
                Text(
                  'No Abilities Found',
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
            itemCount: filteredAbilities.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < filteredAbilities.length) {
                final ability = filteredAbilities[index];
                return _buildAbilityItem(context, ability);
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

  Widget _buildAbilityItem(BuildContext context, ResourceListItem ability) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MahasTile(
        onTap: () => _navigateToAbilityDetail(context, ability),
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
              '#${ability.id.toString().padLeft(3, '0')}',
              style: const TextStyle(
                color: AppColors.pokemonRed,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        title: Text(
          _formatAbilityName(ability.name),
          style: AppTypography.subtitle1.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.pokemonRed),
      ),
    );
  }

  void _navigateToAbilityDetail(
      BuildContext context, ResourceListItem ability) {
    Mahas.routeTo(
      AppRoutes.abilityDetail,
      arguments: {
        'name': ability.name,
      },
    );
  }

  String _formatAbilityName(String name) {
    // Format nama ability (contoh: "overgrow" menjadi "Overgrow")
    return name
        .split('-')
        .map((word) =>
            word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }
}
