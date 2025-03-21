import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/base/provider_widget.dart';
import '../../../../core/mahas/widget/mahas_loader.dart';
import '../../../../core/mahas/widget/mahas_button.dart';
import '../../../../core/mahas/widget/mahas_card.dart';
import '../../../../core/mahas/widget/mahas_tab.dart';
import '../../../../core/mahas/mahas_type.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_typografi.dart';
import '../../../../data/datasource/models/pokemon_model.dart';
import '../../../../core/utils/pokemon_type_utils.dart';
import '../../../../core/utils/mahas.dart';
import '../../../../core/utils/image_cache_utils.dart';
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

    return _buildPokemonDetails(context, provider, pokemon);
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

  Widget _buildPokemonDetails(
      BuildContext context, PokemonDetailProvider provider, Pokemon pokemon) {
    final primaryType = pokemon.types?.firstOrNull?.type.name ?? 'normal';
    final Color appBarColor = PokemonTypeUtils.getTypeColor(primaryType);

    return DefaultTabController(
      length: 4, // Number of tabs
      child: Scaffold(
        body: Column(
          children: [
            // App Bar section in a CustomScrollView
            SizedBox(
              height: 330,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildSliverAppBar(context, provider, pokemon, appBarColor),

                  // Add padding at the bottom
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 16),
                  ),
                ],
              ),
            ),

            // Tabbed content using MahasPillTabBar
            Expanded(
              child: MahasPillTabBar(
                tabLabels: const ['About', 'Stats', 'Evolution', 'Moves'],
                activeColor: appBarColor,
                backgroundColor: Colors.grey.shade200,
                activeTextColor: Colors.white,
                inactiveTextColor: Colors.grey.shade700,
                height: 45.0,
                borderRadius: 15,
                tabViews: [
                  // About Tab
                  SingleChildScrollView(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppTheme.spacing8),
                    child: MahasCustomizableCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'About',
                                  style: AppTypography.headline6,
                                ),
                                const Divider(),
                                _buildAboutInfo(pokemon),

                                const SizedBox(height: 16),

                                // Show description
                                if (provider.speciesData != null &&
                                    provider.speciesData![
                                            'flavor_text_entries'] !=
                                        null &&
                                    provider.speciesData!['flavor_text_entries']
                                        .isNotEmpty) ...[
                                  const Text('Description:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  Text(
                                    _cleanDescription(
                                      provider.speciesData![
                                              'flavor_text_entries'][0]
                                          ['flavor_text'],
                                    ),
                                    style: AppTypography.bodyText2,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Stats Tab
                  SingleChildScrollView(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppTheme.spacing8),
                    child: MahasCustomizableCard(
                      child: pokemon.stats != null
                          ? PokemonStatsWidget(stats: pokemon.stats!)
                          : const Center(child: Text('No stats available')),
                    ),
                  ),

                  // Evolution Tab
                  SingleChildScrollView(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppTheme.spacing8),
                    child: MahasCustomizableCard(
                      child: PokemonEvolutionWidget(
                        pokemonId: provider.currentPokemonId,
                        evolutionStages: provider.parseEvolutionChain(),
                      ),
                    ),
                  ),

                  // Moves Tab
                  SingleChildScrollView(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppTheme.spacing8),
                    child: MahasCustomizableCard(
                      child: pokemon.moves != null
                          ? PokemonMovesWidget(moves: pokemon.moves!)
                          : const Center(child: Text('No moves available')),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build the About info section
  Widget _buildAboutInfo(Pokemon pokemon) {
    final height = pokemon.height != null
        ? pokemon.height! / 10
        : null; // Convert to meters
    final weight =
        pokemon.weight != null ? pokemon.weight! / 10 : null; // Convert to kg

    return Column(
      children: [
        // Basic information row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildInfoItem('Height',
                height != null ? '${height.toString()} m' : 'Unknown'),
            _buildInfoItem('Weight',
                weight != null ? '${weight.toString()} kg' : 'Unknown'),
            _buildInfoItem('ID', '#${pokemon.id.toString().padLeft(3, '0')}'),
          ],
        ),

        const SizedBox(height: 16),

        // Pokemon types
        if (pokemon.types != null && pokemon.types!.isNotEmpty) ...[
          const Text('Types:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: pokemon.types!
                .map((type) => PokemonTypeBadge(typeName: type.type.name))
                .toList(),
          ),
        ],

        const SizedBox(height: 16),

        // Pokemon abilities
        if (pokemon.abilities != null && pokemon.abilities!.isNotEmpty) ...[
          const Text('Abilities:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: pokemon.abilities!.map((ability) {
              return Chip(
                backgroundColor: Colors.grey.shade200,
                label: Text(
                  _capitalizeFirstLetter(
                      ability.ability.name.replaceAll('-', ' ')),
                  style: const TextStyle(fontSize: 12),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  // Helper method to build info item
  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
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
                  ],
                ),
              ),
            ),

            // Pokemon image in the center
            Align(
              alignment: Alignment.center,
              child: Hero(
                tag: 'pokemon-${pokemon.id}',
                child: ImageCacheUtils.buildPokemonImage(
                  imageUrl: pokemon.sprites?.frontDefault ??
                      (pokemon.sprites?.other?.officialArtwork?.frontDefault ??
                          ''),
                  height: 200,
                  width: 200,
                  progressColor: Colors.white,
                  errorWidget: (context, url, error) {
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
