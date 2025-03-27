import 'package:flutter/material.dart';
import '../../../../core/base/provider_widget.dart';
import '../../../../core/mahas/widget/mahas_loader.dart';
import '../../../../core/mahas/widget/mahas_button.dart';
import '../../../../core/mahas/widget/mahas_card.dart';
import '../../../../core/mahas/widget/mahas_tab.dart';
import '../../../../core/mahas/mahas_type.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_typografi.dart';
import '../../../../core/utils/pokemon_type_utils.dart';
import '../../../../data/datasource/models/pokemon_model.dart';
import '../../../providers/move/move_detail_provider.dart';
import '../../../pages/pokemon/pokemon_detail/widgets/pokemon_type_badge.dart';
import '../../../widgets/pokemon_grid_tab.dart';

class MoveDetailPage extends StatelessWidget {
  const MoveDetailPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ProviderPage<MoveDetailProvider>(
      createProvider: () => MoveDetailProvider(),
      builder: (context, provider) => _buildDetailPage(context, provider),
    );
  }

  Widget _buildDetailPage(BuildContext context, MoveDetailProvider provider) {
    return PropertySelector<MoveDetailProvider, Map<String, dynamic>>(
      property: 'moveDetail',
      selector: (provider) => {
        'isLoading': provider.isLoading,
        'hasError': provider.hasError,
        'errorMessage': provider.errorMessage,
        'moveDetail': provider.moveDetail,
        'currentMoveName': provider.currentMoveName,
        'currentMoveId': provider.currentMoveId,
      },
      builder: (context, data) {
        final isLoading = data['isLoading'] as bool;
        final hasError = data['hasError'] as bool;
        final errorMessage = data['errorMessage'] as String;
        final moveDetail = data['moveDetail'];
        final currentMoveName = data['currentMoveName'] as String;
        final currentMoveId = data['currentMoveId'] as String;

        // Show loading state
        if (isLoading) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                _capitalizeFirstLetter(currentMoveName),
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
                _capitalizeFirstLetter(currentMoveName),
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
                    'Error loading move details',
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
                    onPressed: () => provider.loadMoveDetail(
                        currentMoveId.isNotEmpty
                            ? currentMoveId
                            : currentMoveName),
                    type: ButtonType.primary,
                    color: AppColors.pokemonRed,
                  ),
                ],
              ),
            ),
          );
        }

        // No data loaded yet
        if (moveDetail == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                _capitalizeFirstLetter(currentMoveName),
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

        // Show Move details
        final Color appBarColor =
            PokemonTypeUtils.getTypeColor(provider.getMoveType());

        return Scaffold(
          body: _buildBody(context, provider, appBarColor),
        );
      },
    );
  }

  Widget _buildBody(
      BuildContext context, MoveDetailProvider provider, Color appBarColor) {
    return CustomScrollView(
      slivers: [
        // Custom app bar with Move basic info
        _buildSliverAppBar(context, provider, appBarColor),
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
                _buildOverviewTab(provider),
                // Stats Tab
                _buildStatsTab(provider),
                // Pokémon Tab
                _buildPokemonTab(context, provider),
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
  }

  Widget _buildSliverAppBar(
      BuildContext context, MoveDetailProvider provider, Color appBarColor) {
    final moveType = provider.getMoveType();

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
                    _capitalizeFirstLetter(
                        provider.currentMoveName.replaceAll('-', ' ')),
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
  }

  Widget _buildOverviewTab(MoveDetailProvider provider) {
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
                  provider.getMoveDescription(),
                  style: AppTypography.bodyText1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab(MoveDetailProvider provider) {
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
                _buildStatRow('Power', provider.getMovePower()),
                _buildStatRow('Accuracy', provider.getMoveAccuracy()),
                _buildStatRow('PP', provider.getMovePP()),
                _buildStatRow('Damage Class',
                    _capitalizeFirstLetter(provider.getMoveDamageClass())),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPokemonTab(BuildContext context, MoveDetailProvider provider) {
    final pokemonList = provider.getPokemonWithMove();
    final gridItems = pokemonList
        .map(
            (pokemon) => PokemonReference(name: pokemon.name, url: pokemon.url))
        .toList();

    return PokemonGridTab(
      title: 'Pokémon that can learn this move',
      pokemons: gridItems,
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
