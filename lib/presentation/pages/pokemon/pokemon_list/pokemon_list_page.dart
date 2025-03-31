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
import '../../../../core/utils/pokemon_type_utils.dart';
import '../../../../data/models/pokemon_list_item_model.dart';
import '../../../providers/pokemon/pokemon_list/pokemon_list_provider.dart';
import '../../../providers/pokemon/pokemon_list/pokemon_list_notifier.dart';
import '../../../routes/app_routes.dart';
import 'widgets/pokemon_grid_item.dart';
import 'widgets/type_filter_chip.dart';
import 'widgets/type_icon_grid.dart';

class PokemonListPage extends ConsumerWidget {
  const PokemonListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We'll only get the notifier here, not watch the state
    final notifier = ref.read(pokemonListProvider.notifier);
    final state = ref.watch(pokemonListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pokémon',
          style: AppTypography.headline6.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.pokemonRed,
      ),
      body: Column(
        children: [
          // Search bar - only rebuilds when the controller changes
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

          // Type filter - only rebuilds when types or active filter changes
          Consumer(
            builder: (context, ref, child) {
              final state = ref.watch(pokemonListProvider.select((state) => {
                    'types': state.pokemonTypes,
                    'activeFilter': state.activeTypeFilter,
                  }));
              return _buildTypeFilter(context, state['types'] as List<dynamic>,
                  state['activeFilter'] as String?, notifier);
            },
          ),

          // Pokemon grid - only rebuilds when relevant data changes
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final gridState =
                    ref.watch(pokemonListProvider.select((state) => {
                          'isLoading': state.isLoading,
                          'error': state.error,
                          'displayPokemonList': state.displayPokemonList,
                          'hasMoreData': state.hasMoreData,
                          'scrollController': state.scrollController,
                          'activeTypeFilter': state.activeTypeFilter,
                        }));
                return _buildPokemonGrid(context, gridState, notifier);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeFilter(BuildContext context, List<dynamic> types,
      String? activeFilter, PokemonListNotifier notifier) {
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
              onSelected: (_) => notifier.filterByType(null),
              backgroundColor: AppColors.lightSecondaryColor,
              selectedColor: AppColors.pokemonRed.withValues(alpha: 0.2),
              labelStyle: activeFilter == null
                  ? AppTypography.button.copyWith(color: AppColors.pokemonRed)
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
                onSelected: () => notifier.filterByType(type.name),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPokemonGrid(BuildContext context, Map<String, dynamic> gridState,
      PokemonListNotifier notifier) {
    final isLoading = gridState['isLoading'] as bool;
    final error = gridState['error'];
    final hasError = error != null;
    final errorMessage = error?.toString() ?? "Unknown error";
    final pokemonList = gridState['displayPokemonList'] as List;
    final hasMoreData = gridState['hasMoreData'] as bool;
    final scrollController = gridState['scrollController'] as ScrollController;
    final activeTypeFilter = gridState['activeTypeFilter'] as String?;

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
              onPressed: () => notifier.loadPokemonList(refresh: true),
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
              onPressed: () => notifier.resetFilters(),
              type: ButtonType.primary,
              color: AppColors.pokemonRed,
            ),
          ],
        ),
      );
    }

    // Build grid items
    return GridView.builder(
      controller: scrollController,
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

        // We'll make each grid item listen only for its own pokemon details
        return PokemonGridItem(
          pokemon: pokemon,
        );
      },
    );
  }
}
