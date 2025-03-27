import 'package:flutter/material.dart';
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
import '../../../../data/datasource/models/evolution_stage_model.dart';
import '../../../../core/utils/pokemon_type_utils.dart';
import '../../../../core/utils/mahas.dart';
import '../../../../core/utils/image_cache_utils.dart';
import '../../../providers/pokemon/pokemon_detail_provider.dart';
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
    return PropertySelector<PokemonDetailProvider, Map<String, dynamic>>(
      property: 'pokemon',
      selector: (provider) => {
        'isLoading': provider.isLoading,
        'hasError': provider.hasError,
        'errorMessage': provider.errorMessage,
        'pokemon': provider.pokemon,
        'currentPokemonName': provider.currentPokemonName,
        'currentPokemonId': provider.currentPokemonId,
      },
      builder: (context, data) {
        final isLoading = data['isLoading'] as bool;
        final hasError = data['hasError'] as bool;
        final errorMessage = data['errorMessage'] as String;
        final pokemon = data['pokemon'] as Pokemon?;
        final currentPokemonName = data['currentPokemonName'] as String;
        final currentPokemonId = data['currentPokemonId'] as String;

        // Show loading state
        if (isLoading) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                _capitalizeFirstLetter(currentPokemonName),
                style: AppTypography.headline6.copyWith(color: Colors.white),
              ),
              backgroundColor: AppColors.pokemonRed,
              elevation: 0,
            ),
            body: const MahasLoader(isLoading: true),
          );
        }

        // Show error state
        if (hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                _capitalizeFirstLetter(currentPokemonName),
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
                    errorMessage,
                    style: AppTypography.bodyText2,
                  ),
                  const SizedBox(height: 16),
                  MahasButton(
                    text: 'Try Again',
                    onPressed: () =>
                        provider.loadPokemonDetail(currentPokemonId),
                    type: ButtonType.primary,
                    color: AppColors.pokemonRed,
                  ),
                ],
              ),
            ),
          );
        }

        // No data loaded yet
        if (pokemon == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                _capitalizeFirstLetter(currentPokemonName),
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
        return _buildPokemonDetails(context, provider, pokemon);
      },
    );
  }

  // Determine app bar color based on Pokemon type
  Color _getTypeColor(Pokemon pokemon) {
    // Get the primary type color if available
    if (pokemon.types != null && pokemon.types!.isNotEmpty) {
      final primaryType = pokemon.types!.first.type.name;
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

            const SizedBox(height: 16),

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
                  _buildAboutTab(context, provider, pokemon),

                  // Stats Tab
                  _buildStatsTab(pokemon),

                  // Evolution Tab
                  _buildEvolutionTab(provider),

                  // Moves Tab
                  _buildMovesTab(pokemon),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // About Tab
  Widget _buildAboutTab(
      BuildContext context, PokemonDetailProvider provider, Pokemon pokemon) {
    return PropertySelector<PokemonDetailProvider, Map<String, dynamic>>(
      property: 'speciesData',
      selector: (provider) => {
        'speciesData': provider.speciesData,
      },
      builder: (context, data) {
        final speciesData = data['speciesData'] as Map<String, dynamic>?;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing8),
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
                      const SizedBox(
                        height: 10,
                      ),
                      _buildAboutInfo(pokemon),

                      const SizedBox(height: 16),

                      // Show description
                      if (speciesData != null &&
                          speciesData['flavor_text_entries'] != null &&
                          speciesData['flavor_text_entries'].isNotEmpty) ...[
                        Text(
                          'Description',
                          style: AppTypography.subtitle1
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.getDescription(),
                          style: AppTypography.bodyText1,
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Type effectiveness
                      Text(
                        'Type Effectiveness',
                        style: AppTypography.subtitle1
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _buildTypeEffectiveness(pokemon),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Stats Tab
  Widget _buildStatsTab(Pokemon pokemon) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing8),
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
                    'Stats',
                    style: AppTypography.headline6,
                  ),
                  const SizedBox(height: 16),
                  if (pokemon.stats != null && pokemon.stats!.isNotEmpty)
                    PokemonStatsWidget(stats: pokemon.stats!)
                  else
                    const Center(
                      child: Text('No stats available'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Evolution Tab
  Widget _buildEvolutionTab(PokemonDetailProvider provider) {
    return PropertySelector<PokemonDetailProvider, Map<String, dynamic>>(
      property: 'evolutionStages',
      selector: (provider) => {
        'evolutionStages': provider.evolutionStages,
        'currentPokemonId': provider.currentPokemonId,
      },
      builder: (context, data) {
        final evolutionStages = data['evolutionStages'] as List<EvolutionStage>;
        final currentPokemonId = data['currentPokemonId'] as String;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing8),
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
                        'Evolution Chain',
                        style: AppTypography.headline6,
                      ),
                      const SizedBox(height: 16),
                      if (evolutionStages.isNotEmpty)
                        PokemonEvolutionWidget(
                          evolutionStages: evolutionStages,
                          pokemonId: currentPokemonId,
                        )
                      else
                        Center(
                          child: Text(
                            'No evolution data available',
                            style: AppTypography.bodyText1,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Moves Tab
  Widget _buildMovesTab(Pokemon pokemon) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing8),
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
                    'Moves',
                    style: AppTypography.headline6,
                  ),
                  const SizedBox(height: 16),
                  if (pokemon.moves != null && pokemon.moves!.isNotEmpty)
                    PokemonMovesWidget(moves: pokemon.moves!)
                  else
                    Center(
                      child: Text(
                        'No move data available',
                        style: AppTypography.bodyText1,
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

  Widget _buildSliverAppBar(BuildContext context,
      PokemonDetailProvider provider, Pokemon pokemon, Color appBarColor) {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: appBarColor,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          _capitalizeFirstLetter(pokemon.name),
          style: AppTypography.headline6.copyWith(color: Colors.white),
        ),
        background: Stack(
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    appBarColor,
                    appBarColor.withOpacity(0.8),
                  ],
                ),
              ),
            ),
            // Pokeball background pattern
            Positioned(
              right: -50,
              top: -50,
              child: Opacity(
                opacity: 0.2,
                child: Image.network(
                  'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/poke-ball.png',
                  width: 200,
                  height: 200,
                  color: Colors.white,
                ),
              ),
            ),
            // Pokemon image
            Align(
              alignment: Alignment.bottomCenter,
              child: Hero(
                tag: 'pokemon-${pokemon.id}',
                child: ImageCacheUtils.buildPokemonImage(
                  imageUrl:
                      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${pokemon.id}.png',
                  height: 180,
                  width: 180,
                  progressColor: appBarColor.withOpacity(0.5),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.catching_pokemon,
                    size:
                        80, // Larger size for the error icon in the app bar image
                    color: Colors.white54,
                  ),
                ),
              ),
            ),
            // ID number
            Positioned(
              top: 60,
              right: 16,
              child: Text(
                '#${pokemon.id.toString().padLeft(3, '0')}',
                style: AppTypography.headline5.copyWith(
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          Text(
            'Types',
            style:
                AppTypography.subtitle1.copyWith(fontWeight: FontWeight.bold),
          ),
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
          Text(
            'Abilities',
            style:
                AppTypography.subtitle1.copyWith(fontWeight: FontWeight.bold),
          ),
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

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
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

  Widget _buildTypeEffectiveness(Pokemon pokemon) {
    // Simplified placeholder - in a real app this would compute actual type effectiveness
    return Text('Type effectiveness information would be displayed here.',
        style: TextStyle(color: Colors.grey.shade700));
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
