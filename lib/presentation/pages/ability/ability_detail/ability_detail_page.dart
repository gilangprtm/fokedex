import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/mahas/mahas_type.dart';
import '../../../../core/mahas/widget/mahas_loader.dart';
import '../../../../core/mahas/widget/mahas_button.dart';
import '../../../../core/mahas/widget/mahas_card.dart';
import '../../../../core/mahas/widget/mahas_tab.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_typografi.dart';
import '../../../../data/models/pokemon_model.dart';
import '../../../../data/models/ability_model.dart';
import '../../../providers/ability/ability_detail/ability_detail_provider.dart';
import '../../../widgets/pokemon_grid_tab.dart';

class AbilityDetailPage extends ConsumerWidget {
  const AbilityDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only watch loading, error states and ability existence at the top level
    // This prevents unnecessary rebuilds of the entire screen
    final isLoading =
        ref.watch(abilityDetailProvider.select((state) => state.isLoading));
    final error =
        ref.watch(abilityDetailProvider.select((state) => state.error));
    final hasAbility = ref
        .watch(abilityDetailProvider.select((state) => state.ability != null));
    final notifier = ref.read(abilityDetailProvider.notifier);

    // Show loading state
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Consumer(
            builder: (context, ref, _) {
              final abilityName = ref.watch(abilityDetailProvider
                  .select((state) => state.currentAbilityName));
              return Text(
                _capitalizeFirstLetter(abilityName),
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
              final abilityName = ref.watch(abilityDetailProvider
                  .select((state) => state.currentAbilityName));
              return Text(
                _capitalizeFirstLetter(abilityName),
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
                'Error loading ability details',
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
    if (!hasAbility) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Ability Details',
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

    // We only get here when we have ability data and no errors
    return Scaffold(
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Custom app bar with Ability basic info
        _buildSliverAppBar(context),
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
                _buildOverviewTab(),
                // Pokémon Tab
                _buildPokemonTab(context),
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

  Widget _buildSliverAppBar(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final abilityName = ref.watch(
            abilityDetailProvider.select((state) => state.currentAbilityName));

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
                            abilityName.replaceAll('-', ' ')),
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
      },
    );
  }

  Widget _buildOverviewTab() {
    return Consumer(
      builder: (context, ref, _) {
        final notifier = ref.read(abilityDetailProvider.notifier);
        final ability =
            ref.watch(abilityDetailProvider.select((state) => state.ability));

        final description = ability != null
            ? notifier.getAbilityDescription()
            : 'No description available';

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

  Widget _buildPokemonTab(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final notifier = ref.read(abilityDetailProvider.notifier);
        final ability =
            ref.watch(abilityDetailProvider.select((state) => state.ability));

        final pokemonList = ability != null
            ? notifier.getPokemonWithAbility()
            : <AbilityPokemon>[];

        final gridItems = pokemonList
            .map((pokemon) => PokemonReference(
                name: pokemon.pokemon.name, url: pokemon.pokemon.url))
            .toList();

        return PokemonGridTab(
          title: 'Pokémon with this ability',
          pokemons: gridItems,
        );
      },
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
