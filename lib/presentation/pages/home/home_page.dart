import 'package:flutter/material.dart';
import '../../../core/base/provider_widget.dart';
import '../../providers/home_provider.dart';
import 'widgets/pokemon_grid_item.dart';
import 'widgets/type_filter_chip.dart';
import 'widgets/type_icon_grid.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderPage<HomeProvider>(
      createProvider: () => HomeProvider(),
      builder: (context, provider) => _buildHomePage(context, provider),
    );
  }

  Widget _buildHomePage(BuildContext context, HomeProvider provider) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex'),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
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
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: provider.searchController,
              decoration: InputDecoration(
                hintText: 'Search Pokémon',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: provider.searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => provider.clearSearch(),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: provider.onSearchChanged,
            ),
          ),

          // Type filter
          _buildTypeFilter(context, provider),

          // Type Icons Grid (conditionally shown)
          if (provider.showTypeIcons)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pokémon Type Icons',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
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

  Widget _buildTypeFilter(BuildContext context, HomeProvider provider) {
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
              label: const Text('All'),
              selected: provider.activeTypeFilter == null,
              onSelected: (_) => provider.filterByType(null),
              backgroundColor: Colors.grey.shade200,
              selectedColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
          ),

          // Type filters
          ...provider.pokemonTypes.map((type) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: TypeFilterChip(
                  typeName: type.name,
                  isSelected: provider.activeTypeFilter == type.name,
                  onSelected: () => provider.filterByType(type.name),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildPokemonGrid(BuildContext context, HomeProvider provider) {
    if (provider.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading Pokémon',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(provider.errorMessage),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.loadInitialData(),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (provider.pokemonList.isEmpty && provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final pokemonList = provider.filteredPokemonList;

    if (pokemonList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.catching_pokemon, size: 48),
            const SizedBox(height: 16),
            Text(
              'No Pokémon found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (provider.activeTypeFilter != null ||
                provider.searchController.text.isNotEmpty)
              ElevatedButton(
                onPressed: () => provider.resetFilters(),
                child: const Text('Clear Filters'),
              ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () => provider.loadPokemonList(refresh: true),
          child: GridView.builder(
            controller: provider.scrollController,
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: pokemonList.length +
                (provider.hasMoreData && provider.activeTypeFilter == null
                    ? 1
                    : 0),
            itemBuilder: (context, index) {
              if (index == pokemonList.length) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final pokemon = pokemonList[index];
              return PokemonGridItem(pokemon: pokemon);
            },
          ),
        ),

        // Loading indicator at the top
        if (provider.isLoading && provider.pokemonList.isNotEmpty)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white.withOpacity(0.7),
              child: const LinearProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
