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
import '../../../providers/pokemon/pokemon_list_provider.dart';
import '../../../routes/app_routes.dart';
import 'widgets/pokemon_grid_item.dart';
import 'widgets/type_filter_chip.dart';
import 'widgets/type_icon_grid.dart';

class PokemonListPage extends StatelessWidget {
  const PokemonListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderPage<PokemonListProvider>(
      createProvider: () => PokemonListProvider(),
      builder: (context, provider) => _buildPokemonListPage(context, provider),
    );
  }

  Widget _buildPokemonListPage(
      BuildContext context, PokemonListProvider provider) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pokédex',
          style: AppTypography.headline6.copyWith(color: Colors.white),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.pokemonRed,
        actions: [
          // Add a button to toggle type icons display
          PropertySelector<PokemonListProvider, bool>(
            property: 'showTypeIcons',
            selector: (provider) => provider.showTypeIcons,
            builder: (context, showTypeIcons) {
              return IconButton(
                icon: Icon(showTypeIcons ? Icons.grid_off : Icons.grid_on),
                onPressed: () => provider.toggleTypeIcons(),
                tooltip: 'Toggle Type Icons',
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          MahasSearchBar(
            controller: provider.searchController,
            hintText: 'Search Pokémon',
            onChanged: provider.onSearchChanged,
            onClear: provider.clearSearch,
          ),

          // Type filter
          _buildTypeFilter(context, provider),

          // Type Icons Grid (conditionally shown)
          PropertySelector<PokemonListProvider, bool>(
            property: 'showTypeIcons',
            selector: (provider) => provider.showTypeIcons,
            builder: (context, showTypeIcons) {
              if (!showTypeIcons) return const SizedBox.shrink();

              return Card(
                margin: const EdgeInsets.all(AppTheme.spacing16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                ),
                elevation: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppTheme.spacing16),
                      child: Text(
                        'Pokémon Type Icons',
                        style: AppTypography.headline6,
                      ),
                    ),
                    const Divider(),
                    const TypeIconGrid(),
                  ],
                ),
              );
            },
          ),

          // Pokemon grid
          Expanded(
            child: _buildPokemonGrid(context, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeFilter(BuildContext context, PokemonListProvider provider) {
    return SelectorWidget<PokemonListProvider, Map<String, dynamic>>(
      selector: (context, provider) => {
        'types': provider.pokemonTypes,
        'activeFilter': provider.activeTypeFilter,
      },
      builder: (context, data) {
        final types = data['types'] as List;
        final activeFilter = data['activeFilter'] as String?;

        if (types.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // All types option
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FilterChip(
                  selected: activeFilter == null,
                  label: const Text('All'),
                  onSelected: (_) => provider.filterByType(null),
                  backgroundColor: AppColors.lightSecondaryColor,
                  selectedColor: AppColors.pokemonRed.withValues(alpha: 0.2),
                  labelStyle: activeFilter == null
                      ? AppTypography.button
                          .copyWith(color: AppColors.pokemonRed)
                      : AppTypography.button,
                ),
              ),
              // Type filters
              ...types.map(
                (type) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: TypeFilterChip(
                    typeName: type.name,
                    isSelected: activeFilter == type.name,
                    onSelected: () => provider.filterByType(type.name),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPokemonGrid(BuildContext context, PokemonListProvider provider) {
    return PropertySelector<PokemonListProvider, Map<String, dynamic>>(
      property: 'filteredPokemonList',
      selector: (provider) => {
        'isLoading': provider.isLoading,
        'hasError': provider.hasError,
        'errorMessage': provider.errorMessage,
        'pokemonList': provider.filteredPokemonList,
        'hasMoreData': provider.hasMoreData,
      },
      builder: (context, data) {
        final isLoading = data['isLoading'] as bool;
        final hasError = data['hasError'] as bool;
        final errorMessage = data['errorMessage'] as String;
        final pokemonList = data['pokemonList'] as List;
        final hasMoreData = data['hasMoreData'] as bool;

        if (hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: AppColors.errorColor),
                const SizedBox(height: 16),
                Text(
                  'Error loading Pokémon',
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
                  onPressed: () => provider.loadPokemonList(refresh: true),
                  type: ButtonType.primary,
                  color: AppColors.pokemonRed,
                ),
              ],
            ),
          );
        }

        if (isLoading && pokemonList.isEmpty) {
          return const MahasLoader(isLoading: true);
        }

        if (pokemonList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.catching_pokemon,
                    size: 48, color: AppColors.pokemonGray),
                const SizedBox(height: 16),
                Text(
                  'No Pokémon Found',
                  style: AppTypography.headline6,
                ),
                const SizedBox(height: 8),
                Text(
                  'Try changing your search or filter',
                  style: AppTypography.bodyText2,
                ),
                const SizedBox(height: 16),
                MahasButton(
                  text: 'Clear Filters',
                  onPressed: () => provider.resetFilters(),
                  type: ButtonType.primary,
                  color: AppColors.pokemonRed,
                ),
              ],
            ),
          );
        }

        // Build grid items
        return GridView.builder(
          controller: provider.scrollController,
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.9,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: pokemonList.length + (hasMoreData ? 1 : 0),
          itemBuilder: (context, index) {
            // Show loader at the end when loading more
            if (index == pokemonList.length) {
              return const Center(child: CircularProgressIndicator());
            }

            final pokemon = pokemonList[index];

            // Grid item with Pokemon data
            return PokemonGridItem(
              pokemon: pokemon,
              onTap: () {
                // Navigate to detail page
                Mahas.routeTo(
                  AppRoutes.pokemonDetail,
                  arguments: {
                    'id': pokemon.id.toString(),
                    'name': pokemon.name,
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
