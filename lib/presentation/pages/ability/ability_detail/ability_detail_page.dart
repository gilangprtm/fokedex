import 'package:flutter/material.dart';
import '../../../../core/base/provider_widget.dart';
import '../../../../core/mahas/mahas_type.dart';
import '../../../../core/mahas/widget/mahas_loader.dart';
import '../../../../core/mahas/widget/mahas_button.dart';
import '../../../../core/mahas/widget/mahas_card.dart';
import '../../../../core/mahas/widget/mahas_tab.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_typografi.dart';
import '../../../../data/datasource/models/pokemon_model.dart';
import '../../../providers/ability/ability_detail_provider.dart';
import '../../../widgets/pokemon_grid_tab.dart';

class AbilityDetailPage extends StatelessWidget {
  const AbilityDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderPage<AbilityDetailProvider>(
      createProvider: () => AbilityDetailProvider(),
      builder: (context, provider) => _buildDetailPage(context, provider),
    );
  }

  Widget _buildDetailPage(
      BuildContext context, AbilityDetailProvider provider) {
    // Show loading state
    if (provider.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            _capitalizeFirstLetter(provider.currentAbilityName),
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
            _capitalizeFirstLetter(provider.currentAbilityName),
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
                'Error loading ability details',
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
                onPressed: () => provider.loadAbilityDetail(
                    provider.currentAbilityId.isNotEmpty
                        ? provider.currentAbilityId
                        : provider.currentAbilityName),
                type: ButtonType.primary,
                color: AppColors.pokemonRed,
              ),
            ],
          ),
        ),
      );
    }

    // No data loaded yet
    if (provider.abilityDetail == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            _capitalizeFirstLetter(provider.currentAbilityName),
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

    // Show Ability details
    return Scaffold(
      body: _buildBody(context, provider),
    );
  }

  Widget _buildBody(BuildContext context, AbilityDetailProvider provider) {
    return CustomScrollView(
      slivers: [
        // Custom app bar with Ability basic info
        _buildSliverAppBar(context, provider),
        // Add padding at the bottom
        const SliverToBoxAdapter(
          child: SizedBox(height: 16),
        ),
        // Tab Bar with content
        SliverToBoxAdapter(
          child: SizedBox(
            height: MediaQuery.of(context).size.height -
                100, // Subtract app bar height
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

  Widget _buildSliverAppBar(
      BuildContext context, AbilityDetailProvider provider) {
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

            // Ability name
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  Text(
                    _capitalizeFirstLetter(
                        provider.currentAbilityName.replaceAll('-', ' ')),
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

  Widget _buildOverviewTab(AbilityDetailProvider provider) {
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
                  provider.getAbilityDescription(),
                  style: AppTypography.bodyText1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPokemonTab(
      BuildContext context, AbilityDetailProvider provider) {
    final pokemonList = provider.getPokemonWithAbility();
    final gridItems = pokemonList
        .map((pokemon) => PokemonReference(
            name: pokemon.pokemon.name, url: pokemon.pokemon.url))
        .toList();

    return PokemonGridTab(
      title: 'Pokémon with this ability',
      pokemons: gridItems,
    );
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return '';

    // Split by dash or space and capitalize each word
    final words = text.split(RegExp(r'[-\s]'));
    final capitalizedWords = words.map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1);
    });

    return capitalizedWords.join(' ');
  }
}
