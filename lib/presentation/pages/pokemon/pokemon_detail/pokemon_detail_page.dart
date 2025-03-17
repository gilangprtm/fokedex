import 'package:flutter/material.dart';
import '../../../../core/base/provider_widget.dart';
import '../../../../core/mahas/widget/mahas_loader.dart';
import '../../../../core/mahas/widget/mahas_button.dart';
import '../../../../core/mahas/widget/mahas_card.dart';
import '../../../../core/mahas/mahas_type.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_typografi.dart';
import '../../../../data/datasource/models/pokemon_model.dart';
import '../../../../core/utils/pokemon_type_utils.dart';
import '../../../../core/utils/mahas.dart';
import '../../../providers/pokemon_detail_provider.dart';
import 'widgets/pokemon_stats_widget.dart';
import 'widgets/pokemon_type_badge.dart';
import 'widgets/pokemon_evolution_widget.dart';
import 'widgets/pokemon_moves_widget.dart';

class PokemonDetailPage extends StatelessWidget {
  const PokemonDetailPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ProviderPage<PokemonDetailProvider>(
      createProvider: () => PokemonDetailProvider(),
      builder: (context, provider) => _buildDetailPage(context, provider),
    );
  }

  Widget _buildDetailPage(
      BuildContext context, PokemonDetailProvider provider) {
    // Show loading state
    if (provider.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            _capitalizeFirstLetter(provider.currentPokemonName),
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
            _capitalizeFirstLetter(provider.currentPokemonName),
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
                'Error loading Pokémon details',
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
                onPressed: () =>
                    provider.loadPokemonDetail(provider.currentPokemonId),
                type: ButtonType.primary,
                color: AppColors.pokemonRed,
              ),
            ],
          ),
        ),
      );
    }

    // No data loaded yet
    if (provider.pokemon == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            _capitalizeFirstLetter(provider.currentPokemonName),
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

    // Show Pokemon details
    final pokemon = provider.pokemon!;
    final Color appBarColor = _getAppBarColor(provider);

    return Scaffold(
      body: _buildBody(context, provider, pokemon, appBarColor),
    );
  }

  // Determine app bar color based on Pokemon type or species
  Color _getAppBarColor(PokemonDetailProvider provider) {
    // Get the primary type color if available
    if (provider.pokemon?.types != null &&
        provider.pokemon!.types!.isNotEmpty) {
      final primaryType = provider.pokemon!.types!.first.type.name;
      return PokemonTypeUtils.getTypeColor(primaryType);
    }
    // Default to red if no type info
    return AppColors.pokemonRed;
  }

  Widget _buildBody(BuildContext context, PokemonDetailProvider provider,
      Pokemon pokemon, Color appBarColor) {
    return CustomScrollView(
      slivers: [
        // Custom app bar with Pokemon image and basic info
        _buildSliverAppBar(context, provider, pokemon, appBarColor),

        // Pokemon Stats
        SliverToBoxAdapter(
          child: MahasCustomizableCard(
            margin: AppTheme.spacing16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stats',
                  style: AppTypography.headline6,
                ),
                const Divider(),
                if (pokemon.stats != null)
                  PokemonStatsWidget(stats: pokemon.stats!)
                else
                  const Center(child: Text('No stats available')),
              ],
            ),
          ),
        ),

        // Pokemon Evolution Chain
        SliverToBoxAdapter(
          child: MahasCustomizableCard(
            margin: AppTheme.spacing16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Evolution Chain',
                  style: AppTypography.headline6,
                ),
                const Divider(),
                PokemonEvolutionWidget(
                  pokemonId: provider.currentPokemonId,
                  evolutionStages: provider.parseEvolutionChain(),
                ),
              ],
            ),
          ),
        ),

        // Pokemon Moves
        SliverToBoxAdapter(
          child: MahasCustomizableCard(
            margin: AppTheme.spacing16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Moves',
                  style: AppTypography.headline6,
                ),
                const Divider(),
                if (pokemon.moves != null)
                  PokemonMovesWidget(moves: pokemon.moves!)
                else
                  const Center(child: Text('No moves available')),
              ],
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

  Widget _buildSliverAppBar(BuildContext context,
      PokemonDetailProvider provider, Pokemon pokemon, Color appBarColor) {
    return SliverAppBar(
      expandedHeight: 300.0,
      floating: false,
      pinned: true,
      backgroundColor: appBarColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Background color
            Container(
              color: appBarColor,
            ),

            // Decorative Poké Ball pattern in the background
            Positioned(
              right: -50,
              top: -50,
              child: Icon(
                Icons.catching_pokemon,
                size: 200,
                color: Colors.white.withOpacity(0.2),
              ),
            ),

            // Pokemon image in the center
            Align(
              alignment: Alignment.center,
              child: Hero(
                tag: 'pokemon-${pokemon.id}',
                child: Image.network(
                  pokemon.sprites?.frontDefault ??
                      (pokemon.sprites?.other?.officialArtwork?.frontDefault ??
                          ''),
                  height: 200,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: appBarColor.withOpacity(0.5),
                      child: const Icon(
                        Icons.catching_pokemon,
                        size: 100,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ),

            // Pokemon info at the bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                color: appBarColor.withOpacity(0.7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pokemon ID
                    Text(
                      '#${pokemon.id.toString().padLeft(3, '0')}',
                      style: AppTypography.pokemonId.copyWith(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    // Pokemon Name
                    Text(
                      _capitalizeFirstLetter(pokemon.name),
                      style: AppTypography.pokemonName.copyWith(
                        color: Colors.white,
                        fontSize: 30,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Pokemon Types
                    if (pokemon.types != null) _buildPokemonTypes(pokemon),
                    // Pokemon Description
                    if (provider.speciesData != null &&
                        provider.speciesData!['flavor_text_entries'] != null &&
                        provider.speciesData!['flavor_text_entries'].isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _cleanDescription(
                            provider.speciesData!['flavor_text_entries'][0]
                                ['flavor_text'],
                          ),
                          style: AppTypography.bodyText2.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Mahas.back(),
      ),
    );
  }

  Widget _buildPokemonTypes(Pokemon pokemon) {
    return Row(
      children: pokemon.types!
          .map((type) => Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: PokemonTypeBadge(typeName: type.type.name),
              ))
          .toList(),
    );
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }

  String _cleanDescription(String description) {
    // Remove newlines and duplicate spaces
    return description
        .replaceAll('\n', ' ')
        .replaceAll('\f', ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}
