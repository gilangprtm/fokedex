import 'package:flutter/material.dart';
import '../../../../core/base/provider_widget.dart';
import '../../../../core/mahas/widget/mahas_loader.dart';
import '../../../../core/mahas/widget/mahas_button.dart';
import '../../../../core/mahas/mahas_type.dart';
import '../../../../core/utils/mahas.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_typografi.dart';
import '../../../providers/pokemon_list_provider.dart';
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
          IconButton(
            icon: Icon(provider.showTypeIcons ? Icons.grid_off : Icons.grid_on),
            onPressed: () => provider.toggleTypeIcons(),
            tooltip: 'Toggle Type Icons',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              ),
              elevation: 2,
              child: TextField(
                controller: provider.searchController,
                decoration: InputDecoration(
                  hintText: 'Search Pokémon',
                  hintStyle: AppTypography.bodyText2,
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.pokemonGray),
                  suffixIcon: provider.searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear,
                              color: AppColors.pokemonGray),
                          onPressed: () => provider.clearSearch(),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                    borderSide:
                        const BorderSide(color: AppColors.lightBorderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                    borderSide:
                        const BorderSide(color: AppColors.lightBorderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                    borderSide:
                        const BorderSide(color: AppColors.pokemonRed, width: 2),
                  ),
                ),
                onChanged: provider.onSearchChanged,
              ),
            ),
          ),

          // Type filter
          _buildTypeFilter(context, provider),

          // Type Icons Grid (conditionally shown)
          if (provider.showTypeIcons)
            Card(
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
    if (provider.pokemonTypes.isEmpty) {
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
              selected: provider.activeTypeFilter == null,
              label: const Text('All'),
              onSelected: (_) => provider.filterByType(null),
              backgroundColor: AppColors.lightSecondaryColor,
              selectedColor: AppColors.pokemonRed.withValues(alpha: 0.2),
              labelStyle: provider.activeTypeFilter == null
                  ? AppTypography.button.copyWith(color: AppColors.pokemonRed)
                  : AppTypography.button,
            ),
          ),
          // Type filters
          ...provider.pokemonTypes.map(
            (type) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: TypeFilterChip(
                typeName: type.name,
                isSelected: provider.activeTypeFilter == type.name,
                onSelected: () => provider.filterByType(type.name),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPokemonGrid(BuildContext context, PokemonListProvider provider) {
    if (provider.hasError) {
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
              provider.errorMessage,
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

    if (provider.isLoading && provider.filteredPokemonList.isEmpty) {
      return const MahasLoader(isLoading: true);
    }

    if (provider.filteredPokemonList.isEmpty) {
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

    // Build grid items first
    final List<Widget> gridItems = [];

    // Add Pokemon items
    for (int i = 0; i < provider.filteredPokemonList.length; i++) {
      final pokemon = provider.filteredPokemonList[i];
      gridItems.add(
        PokemonGridItem(
          pokemon: pokemon,
          onTap: () => _navigateToPokemonDetail(context, pokemon),
        ),
      );
    }

    // Add loading indicator if more data is available
    if (provider.hasMoreData) {
      gridItems.add(
        const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadPokemonList(refresh: true),
      color: AppColors.pokemonRed,
      child: GridView.builder(
        controller: provider.scrollController,
        padding: const EdgeInsets.all(AppTheme.spacing16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: gridItems.length,
        itemBuilder: (context, index) => gridItems[index],
      ),
    );
  }

  void _navigateToPokemonDetail(BuildContext context, dynamic pokemon) {
    Mahas.routeTo(
      AppRoutes.pokemonDetail,
      arguments: {
        'id': pokemon.id.toString(),
        'name': pokemon.name,
      },
    );
  }
}
