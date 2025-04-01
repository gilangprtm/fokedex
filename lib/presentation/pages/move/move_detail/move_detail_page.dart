import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/mahas/widget/mahas_loader.dart';
import '../../../../core/mahas/widget/mahas_button.dart';
import '../../../../core/mahas/widget/mahas_card.dart';
import '../../../../core/mahas/widget/mahas_tab.dart';
import '../../../../core/mahas/mahas_type.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_typografi.dart';
import '../../../../core/utils/pokemon_type_utils.dart';
import '../../../../data/models/pokemon_model.dart';
import '../../../../data/models/move_model.dart';
import '../../../providers/move/move_detail/move_detail_provider.dart';
import '../../../providers/move/move_detail/move_detail_state.dart';
import '../../../pages/pokemon/pokemon_detail/widgets/pokemon_type_badge.dart';
import '../../../widgets/pokemon_grid_tab.dart';

class MoveDetailPage extends ConsumerWidget {
  const MoveDetailPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only watch loading, error states and move existence at the top level
    // This prevents unnecessary rebuilds of the entire screen
    final isLoading =
        ref.watch(moveDetailProvider.select((state) => state.isLoading));
    final error = ref.watch(moveDetailProvider.select((state) => state.error));
    final hasMove =
        ref.watch(moveDetailProvider.select((state) => state.move != null));
    final notifier = ref.read(moveDetailProvider.notifier);

    // Show loading state
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Consumer(
            builder: (context, ref, _) {
              final moveName = ref.watch(
                  moveDetailProvider.select((state) => state.move?.name ?? ''));
              return Text(
                _capitalizeFirstLetter(moveName),
                style: AppTypography.headline6.copyWith(color: Colors.white),
              );
            },
          ),
          backgroundColor: AppColors.pokemonRed,
          elevation: 0,
        ),
        body: const MahasLoader(isLoading: true),
      );
    }

    // Show error state
    if (error != null) {
      return Scaffold(
        appBar: AppBar(
          title: Consumer(
            builder: (context, ref, _) {
              final moveName = ref.watch(
                  moveDetailProvider.select((state) => state.move?.name ?? ''));
              return Text(
                _capitalizeFirstLetter(moveName),
                style: AppTypography.headline6.copyWith(color: Colors.white),
              );
            },
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
                'Error loading move details',
                style: AppTypography.headline6,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: AppTypography.bodyText2,
              ),
              const SizedBox(height: 16),
              MahasButton(
                text: 'Try Again',
                onPressed: () => notifier.getArgs(),
                type: ButtonType.primary,
                color: AppColors.pokemonRed,
              ),
            ],
          ),
        ),
      );
    }

    // No data loaded yet
    if (!hasMove) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Move Details',
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

    // We only get here when we have move data and no errors
    return Scaffold(
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    // AppBarColor is dynamically determined by the move type
    return Consumer(
      builder: (context, ref, _) {
        final moveType = ref.watch(moveDetailProvider
            .select((state) => state.move?.type?.name ?? 'normal'));
        final appBarColor = PokemonTypeUtils.getTypeColor(moveType);

        return CustomScrollView(
          slivers: [
            // Custom app bar with Move basic info
            _buildSliverAppBar(context, appBarColor),
            // Add padding at the bottom
            const SliverToBoxAdapter(
              child: SizedBox(height: 16),
            ),
            // Tab Bar with content
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).size.height -
                    220, // Subtract app bar height
                child: MahasPillTabBar(
                  tabLabels: const ['Overview', 'Stats', 'Pokémon'],
                  tabViews: [
                    // Overview Tab
                    _buildOverviewTab(),
                    // Stats Tab
                    _buildStatsTab(),
                    // Pokémon Tab
                    _buildPokemonTab(context),
                  ],
                  activeColor: appBarColor,
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
      },
    );
  }

  Widget _buildSliverAppBar(BuildContext context, Color appBarColor) {
    return Consumer(
      builder: (context, ref, _) {
        final moveType = ref.watch(moveDetailProvider
            .select((state) => state.move?.type?.name ?? 'normal'));
        final moveName = ref.watch(
            moveDetailProvider.select((state) => state.move?.name ?? ''));

        return SliverAppBar(
          expandedHeight: 200.0,
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
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),

                // Move name and type
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),
                      Text(
                        _capitalizeFirstLetter(moveName.replaceAll('-', ' ')),
                        style: AppTypography.headline5.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      PokemonTypeBadge(typeName: moveType),
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

  Widget _buildOverviewTab() {
    return Consumer(
      builder: (context, ref, _) {
        final description = ref.watch(
            moveDetailProvider.select((state) => _getMoveDescription(state)));

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
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      description,
                      style: AppTypography.bodyText1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsTab() {
    return Consumer(
      builder: (context, ref, _) {
        final state = ref.watch(moveDetailProvider);

        // Only extract the stats we need
        final power = _getMovePower(state);
        final accuracy = _getMoveAccuracy(state);
        final pp = _getMovePP(state);
        final damageClass = _getMoveDamageClass(state);

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
                      'Move Stats',
                      style: AppTypography.headline6,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    _buildStatRow('Power', power),
                    _buildStatRow('Accuracy', accuracy),
                    _buildStatRow('PP', pp),
                    _buildStatRow(
                        'Damage Class', _capitalizeFirstLetter(damageClass)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPokemonTab(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final pokemonList = ref.watch(
            moveDetailProvider.select((state) => _getPokemonWithMove(state)));

        final gridItems = pokemonList
            .map((pokemon) =>
                PokemonReference(name: pokemon.name, url: pokemon.url))
            .toList();

        return PokemonGridTab(
          title: 'Pokémon that can learn this move',
          pokemons: gridItems,
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value) {
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

  // Helper methods to access state data
  String _getMovePower(MoveDetailState state) {
    if (state.move == null || state.move!.power == null) {
      return 'N/A';
    }
    return state.move!.power.toString();
  }

  String _getMoveAccuracy(MoveDetailState state) {
    if (state.move == null || state.move!.accuracy == null) {
      return 'N/A';
    }
    return '${state.move!.accuracy}%';
  }

  String _getMovePP(MoveDetailState state) {
    if (state.move == null || state.move!.pp == null) {
      return 'N/A';
    }
    return state.move!.pp.toString();
  }

  String _getMoveDamageClass(MoveDetailState state) {
    if (state.move == null || state.move!.damageClass == null) {
      return 'unknown';
    }
    return state.move!.damageClass!.name;
  }

  String _getMoveDescription(MoveDetailState state) {
    if (state.move == null ||
        state.move!.flavorTextEntries == null ||
        state.move!.flavorTextEntries!.isEmpty) {
      return 'No description available.';
    }

    // Find English flavor text
    final englishEntries = state.move!.flavorTextEntries!
        .where((entry) => entry.language.name == 'en')
        .toList();

    if (englishEntries.isEmpty) {
      return 'No English description available.';
    }

    // Get the most recent English flavor text
    String flavorText = englishEntries.last.flavorText;

    // Clean up the text by removing newlines and multiple spaces
    flavorText = flavorText.replaceAll('\n', ' ').replaceAll('\f', ' ');
    flavorText = flavorText.replaceAll(RegExp(r'\s{2,}'), ' ');

    return flavorText;
  }

  List<MoveLearnedByPokemon> _getPokemonWithMove(MoveDetailState state) {
    if (state.move == null ||
        state.move!.learnedByPokemon == null ||
        state.move!.learnedByPokemon!.isEmpty) {
      return [];
    }

    return state.move!.learnedByPokemon!;
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
