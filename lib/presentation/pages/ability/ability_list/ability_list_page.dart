import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import '../../../providers/ability/ability_list/ability_list_provider.dart';
import '../../../routes/app_routes.dart';

class AbilityListPage extends ConsumerWidget {
  const AbilityListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only watch essential state properties at the top level
    final notifier = ref.read(abilityListProvider.notifier);

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
          // Search bar - uses Consumer for independent updates
          Consumer(
            builder: (context, ref, _) {
              final searchController = ref.watch(abilityListProvider
                  .select((state) => state.searchController));
              return MahasSearchBar(
                controller: searchController,
                hintText: 'Search Abilities',
                onChanged: notifier.onSearchChanged,
                onClear: notifier.clearSearch,
              );
            },
          ),

          // Ability list
          Expanded(
            child: _buildAbilityList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAbilityList(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final state = ref.watch(abilityListProvider);
        final notifier = ref.read(abilityListProvider.notifier);

        final isLoading = state.isLoading;
        final error = state.error;
        final abilities = state.displayAbilities;
        final hasMore = state.hasMore;

        if (error != null) {
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
                  error.toString(),
                  style: AppTypography.bodyText2,
                ),
                const SizedBox(height: 16),
                MahasButton(
                  text: 'Retry',
                  onPressed: () => notifier.loadAbilities(refresh: true),
                  type: ButtonType.primary,
                  color: AppColors.pokemonRed,
                ),
              ],
            ),
          );
        }

        if (isLoading && abilities.isEmpty) {
          return const MahasLoader(isLoading: true);
        }

        if (abilities.isEmpty) {
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
                  onPressed: () => notifier.clearSearch(),
                  type: ButtonType.primary,
                  color: AppColors.pokemonRed,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => notifier.refresh(),
          child: ListView.builder(
            controller: state.scrollController,
            padding: const EdgeInsets.all(AppTheme.spacing16),
            itemCount: abilities.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < abilities.length) {
                final ability = abilities[index];
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
