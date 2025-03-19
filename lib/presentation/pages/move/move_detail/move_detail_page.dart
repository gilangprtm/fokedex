import 'package:flutter/material.dart';
import '../../../../core/base/provider_widget.dart';
import '../../../../core/mahas/widget/mahas_loader.dart';
import '../../../../core/mahas/widget/mahas_button.dart';
import '../../../../core/mahas/widget/mahas_card.dart';
import '../../../../core/mahas/mahas_type.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_typografi.dart';
import '../../../../core/utils/pokemon_type_utils.dart';
import '../../../../core/utils/mahas.dart';
import '../../../providers/move_detail_provider.dart';
import '../../../routes/app_routes.dart';
import '../../../pages/pokemon/pokemon_detail/widgets/pokemon_type_badge.dart';

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
    // Show loading state
    if (provider.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            _capitalizeFirstLetter(provider.currentMoveName),
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
            _capitalizeFirstLetter(provider.currentMoveName),
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
                provider.errorMessage,
                style: AppTypography.bodyText2,
              ),
              const SizedBox(height: 16),
              MahasButton(
                text: 'Try Again',
                onPressed: () => provider.loadMoveDetail(
                    provider.currentMoveId.isNotEmpty
                        ? provider.currentMoveId
                        : provider.currentMoveName),
                type: ButtonType.primary,
                color: AppColors.pokemonRed,
              ),
            ],
          ),
        ),
      );
    }

    // No data loaded yet
    if (provider.moveDetail == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            _capitalizeFirstLetter(provider.currentMoveName),
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
  }

  Widget _buildBody(
      BuildContext context, MoveDetailProvider provider, Color appBarColor) {
    return CustomScrollView(
      slivers: [
        // Custom app bar with Move basic info
        _buildSliverAppBar(context, provider, appBarColor),

        // Move Description
        SliverToBoxAdapter(
          child: MahasCustomizableCard(
            margin: AppTheme.spacing16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Description',
                  style: AppTypography.headline6,
                ),
                const Divider(),
                Text(
                  provider.getMoveDescription(),
                  style: AppTypography.bodyText1,
                ),
              ],
            ),
          ),
        ),

        // Move Stats
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
                _buildStatRow('Power', provider.getMovePower()),
                _buildStatRow('Accuracy', provider.getMoveAccuracy()),
                _buildStatRow('PP', provider.getMovePP()),
                _buildStatRow('Damage Class',
                    _capitalizeFirstLetter(provider.getMoveDamageClass())),
              ],
            ),
          ),
        ),

        // Pokemon that can learn this move
        SliverToBoxAdapter(
          child: MahasCustomizableCard(
            margin: AppTheme.spacing16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pokémon that can learn this move',
                  style: AppTypography.headline6,
                ),
                const Divider(),
                _buildPokemonList(context, provider),
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
                color: Colors.white.withOpacity(0.2),
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

  Widget _buildPokemonList(BuildContext context, MoveDetailProvider provider) {
    final pokemonList = provider.getPokemonWithMove();

    if (pokemonList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text('No Pokémon data available'),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: pokemonList.map((pokemon) {
        // Extract ID from URL
        final url = pokemon.url;
        final uri = Uri.parse(url);
        final pathSegments = uri.pathSegments;
        final pokemonId = pathSegments[pathSegments.length - 2];
        final pokemonName = pokemon.name;

        return GestureDetector(
          onTap: () {
            Mahas.routeTo(
              AppRoutes.pokemonDetail,
              arguments: {
                'id': pokemonId,
                'name': pokemonName,
              },
            );
          },
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$pokemonId.png',
                  height: 60,
                  width: 60,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.catching_pokemon, size: 40);
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  _capitalizeFirstLetter(pokemonName),
                  style: AppTypography.caption,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }).toList(),
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
