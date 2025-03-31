import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/mahas/widget/mahas_loader.dart';
import '../../../../core/mahas/widget/mahas_button.dart';
import '../../../../core/mahas/widget/mahas_card.dart';
import '../../../../core/mahas/widget/mahas_tab.dart';
import '../../../../core/mahas/mahas_type.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_typografi.dart';
import '../../../../data/models/pokemon_model.dart';
import '../../../../data/models/evolution_stage_model.dart';
import '../../../../core/utils/pokemon_type_utils.dart';
import '../../../../core/utils/mahas.dart';
import '../../../../core/utils/image_cache_utils.dart';
import '../../../providers/pokemon/pokemon_detail/pokemon_detail_provider.dart';
import '../../../providers/pokemon/pokemon_detail/pokemon_detail_notifier.dart';
import 'widgets/pokemon_stats_widget.dart';
import 'widgets/pokemon_type_badge.dart';
import 'widgets/pokemon_evolution_widget.dart';
import 'widgets/pokemon_moves_widget.dart';

class PokemonDetailPage extends ConsumerWidget {
  const PokemonDetailPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Access the notifier for method calls
    final notifier = ref.read(pokemonDetailProvider.notifier);

    // Watch only base state properties for main UI render decisions
    return Consumer(
      builder: (context, ref, child) {
        final baseState = ref.watch(pokemonDetailProvider.select((state) => ({
              'isLoading': state.isLoading,
              'error': state.error,
              'pokemon': state.pokemon,
              'currentPokemonName': state.currentPokemonName,
              'currentPokemonId': state.currentPokemonId,
            })));

        final isLoading = baseState['isLoading'] as bool;
        final error = baseState['error'];
        final hasError = error != null;
        final errorMessage = error?.toString() ?? '';
        final pokemon = baseState['pokemon'] as Pokemon?;
        final currentPokemonName = baseState['currentPokemonName'] as String;
        final currentPokemonId = baseState['currentPokemonId'] as String;

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
                        notifier.loadPokemonDetail(currentPokemonId),
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
        return _buildPokemonDetails(context, ref, pokemon);
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
      BuildContext context, WidgetRef ref, Pokemon pokemon) {
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
                  _buildSliverAppBar(context, ref, pokemon, appBarColor),

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
                onTabChanged: (index) => ref
                    .read(pokemonDetailProvider.notifier)
                    .setSelectedTab(index),
                tabViews: [
                  // About Tab
                  _buildAboutTab(context, ref, pokemon),

                  // Stats Tab
                  _buildStatsTab(pokemon),

                  // Evolution Tab
                  _buildEvolutionTab(ref),

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
  Widget _buildAboutTab(BuildContext context, WidgetRef ref, Pokemon pokemon) {
    return Consumer(
      builder: (context, ref, child) {
        final speciesData = ref
            .watch(pokemonDetailProvider.select((state) => state.speciesData));
        final description = ref
            .watch(pokemonDetailProvider.select((state) => state.description));
        final category =
            ref.watch(pokemonDetailProvider.select((state) => state.category));

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
                      if (description != null) ...[
                        Text(
                          'Description',
                          style: AppTypography.subtitle1
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
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
  Widget _buildEvolutionTab(WidgetRef ref) {
    return Consumer(
      builder: (context, ref, child) {
        final evolutionStages = ref.watch(
            pokemonDetailProvider.select((state) => state.evolutionStages));
        final currentPokemonId = ref.watch(
            pokemonDetailProvider.select((state) => state.currentPokemonId));
        // We use notifier's isLoadingEvolution to avoid rebuilds when main isLoading changes
        final isLoading =
            ref.read(pokemonDetailProvider.notifier).isLoadingEvolution;

        if (isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

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

  Widget _buildSliverAppBar(
      BuildContext context, WidgetRef ref, Pokemon pokemon, Color appBarColor) {
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
                      style: AppTypography.headline6.copyWith(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    // Pokemon Name
                    Text(
                      _capitalizeFirstLetter(pokemon.name),
                      style: AppTypography.headline5.copyWith(
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
                  imageUrl: pokemon.officialArtworkImageUrl,
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
}
