import 'package:flutter/material.dart';
import '../../core/mahas/widget/mahas_grid.dart';
import '../../core/theme/app_typografi.dart';
import '../../core/utils/image_cache_utils.dart';
import '../../core/utils/mahas.dart';
import '../routes/app_routes.dart';

class PokemonGridTab extends StatelessWidget {
  final String title;
  final List<PokemonGridItem> pokemons;
  final bool isLoading;
  final String? errorMessage;

  const PokemonGridTab({
    super.key,
    required this.title,
    required this.pokemons,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            title,
            style: AppTypography.headline6,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(child: _buildPokemonList()),
      ],
    );
  }

  Widget _buildPokemonList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(child: Text(errorMessage!));
    }

    if (pokemons.isEmpty) {
      return const Center(
        child: Text('No Pokémon data available'),
      );
    }

    final pokemonWidgets = pokemons.map((pokemon) {
      return GestureDetector(
        onTap: () {
          Mahas.routeTo(
            AppRoutes.pokemonDetail,
            arguments: {
              'id': pokemon.id,
              'name': pokemon.name,
            },
          );
        },
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ImageCacheUtils.buildPokemonImage(
                imageUrl: pokemon.imageUrl,
                height: 50,
                width: 50,
                progressColor: Colors.grey.shade400,
                errorWidget: (context, url, error) {
                  return const Icon(Icons.catching_pokemon, size: 32);
                },
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  pokemon.name,
                  style: AppTypography.caption,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Expanded(
            child: MahasGrid(
              items: pokemonWidgets,
              crossAxisCount: 3,
              childAspectRatio: 1,
            ),
          ),
          const SizedBox(height: 16), // Footer padding
        ],
      ),
    );
  }
}

class PokemonGridItem {
  final String id;
  final String name;
  final String imageUrl;

  const PokemonGridItem({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory PokemonGridItem.fromUrl(String name, String url) {
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    final id = pathSegments[pathSegments.length - 2];
    final imageUrl =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';

    return PokemonGridItem(
      id: id,
      name: name
          .split('-')
          .map((word) => word[0].toUpperCase() + word.substring(1))
          .join(' '),
      imageUrl: imageUrl,
    );
  }
}
