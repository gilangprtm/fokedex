import 'package:flutter/material.dart';
import '../../../../core/base/provider_widget.dart';
import '../../../../core/mahas/widget/mahas_loader.dart';
import '../../../../core/mahas/widget/mahas_button.dart';
import '../../../../core/mahas/widget/mahas_card.dart';
import '../../../../core/mahas/widget/mahas_tab.dart';
import '../../../../core/mahas/mahas_type.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_typografi.dart';
import '../../../../data/datasource/models/pokemon_model.dart';
import '../../../providers/item/item_detail_provider.dart';
import '../../../widgets/pokemon_grid_tab.dart';

class ItemDetailPage extends StatelessWidget {
  const ItemDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderPage<ItemDetailProvider>(
      createProvider: () => ItemDetailProvider(),
      builder: (context, provider) => _buildDetailPage(context, provider),
    );
  }

  Widget _buildDetailPage(BuildContext context, ItemDetailProvider provider) {
    // Show loading state
    if (provider.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            _formatItemName(provider.currentItemName),
            style: AppTypography.headline6.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.pokemonRed,
          elevation: 0,
        ),
        body: const MahasLoader(isLoading: true),
      );
    }

    // Show error state
    if (provider.hasError) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            _formatItemName(provider.currentItemName),
            style: AppTypography.headline6.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.pokemonRed,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.errorColor),
              const SizedBox(height: 16),
              Text(
                'Error loading item details',
                style: AppTypography.headline6,
              ),
              const SizedBox(height: 8),
              Text(
                provider.errorMessage,
                style: AppTypography.bodyText2,
              ),
              const SizedBox(height: 16),
              MahasButton(
                text: 'Try Again',
                onPressed: () => provider.loadItemDetail(
                    provider.currentItemId.isNotEmpty
                        ? provider.currentItemId
                        : provider.currentItemName),
                type: ButtonType.primary,
                color: AppColors.pokemonRed,
              ),
            ],
          ),
        ),
      );
    }

    // No data loaded yet
    if (provider.itemDetail == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            _formatItemName(provider.currentItemName),
            style: AppTypography.headline6.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.pokemonRed,
          elevation: 0,
        ),
        body: Center(
          child: Text(
            'No data available',
            style: AppTypography.bodyText1,
          ),
        ),
      );
    }

    // Show Item details
    return Scaffold(
      body: _buildBody(context, provider),
    );
  }

  Widget _buildBody(BuildContext context, ItemDetailProvider provider) {
    return CustomScrollView(
      slivers: [
        // Custom app bar with Item basic info
        _buildSliverAppBar(context, provider),
        // Add padding at the bottom
        const SliverToBoxAdapter(
          child: SizedBox(height: 16),
        ),
        // Tab Bar with content
        SliverToBoxAdapter(
          child: SizedBox(
            height: MediaQuery.of(context).size.height -
                200, // Subtract app bar height
            child: MahasPillTabBar(
              tabLabels: const ['Overview', 'Pokémon'],
              tabViews: [
                // Overview Tab
                _buildOverviewTab(provider),
                // Pokémon Tab
                _buildPokemonTab(context, provider),
              ],
              activeColor: AppColors.pokemonRed,
              backgroundColor: Colors.grey[200]!,
              activeTextColor: Colors.white,
              inactiveTextColor: Colors.black87,
              height: 45,
              borderRadius: 15,
            ),
          ),
        ),

        // Add padding at the bottom
        const SliverToBoxAdapter(
          child: SizedBox(height: 32),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(BuildContext context, ItemDetailProvider provider) {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.pokemonRed,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Background color
            Container(
              color: AppColors.pokemonRed,
            ),

            // Decorative Poké Ball pattern in the background
            Positioned(
              right: -50,
              top: -50,
              child: Icon(
                Icons.catching_pokemon,
                size: 200,
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),

            // Item name and image
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  if (provider.getItemImageUrl() != null)
                    Image.network(
                      provider.getItemImageUrl()!,
                      height: 80,
                      width: 80,
                      fit: BoxFit.contain,
                    ),
                  const SizedBox(height: 16),
                  Text(
                    _formatItemName(provider.currentItemName),
                    style: AppTypography.headline5.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(ItemDetailProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MahasCustomizableCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Description',
                  style: AppTypography.headline6,
                ),
                const SizedBox(height: 10),
                Text(
                  provider.getItemDescription(),
                  style: AppTypography.bodyText1,
                ),
                const SizedBox(height: 16),
                Text(
                  'Effect',
                  style: AppTypography.headline6,
                ),
                const SizedBox(height: 10),
                Text(
                  provider.getItemShortEffect(),
                  style: AppTypography.bodyText1,
                ),
                const SizedBox(height: 16),
                Text(
                  'Details',
                  style: AppTypography.headline6,
                ),
                const SizedBox(height: 10),
                _buildDetailRow('Category', provider.getItemCategory()),
                _buildDetailRow('Cost', provider.getItemCost()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTypography.bodyText1.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTypography.bodyText1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPokemonTab(BuildContext context, ItemDetailProvider provider) {
    final pokemonList = provider.getPokemonWithItem();
    final gridItems = pokemonList
        .map((pokemon) => PokemonReference(
            name: pokemon.pokemon.name, url: pokemon.pokemon.url))
        .toList();

    return PokemonGridTab(
      title: 'Pokémon that can hold this item',
      pokemons: gridItems,
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
