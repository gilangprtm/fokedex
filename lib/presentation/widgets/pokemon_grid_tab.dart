import 'package:flutter/material.dart';
import '../../core/theme/app_typografi.dart';
import '../../core/utils/image_cache_utils.dart';
import '../../core/utils/mahas.dart';
import '../../data/datasource/models/pokemon_model.dart';
import '../routes/app_routes.dart';

class PokemonGridTab extends StatelessWidget {
  final String title;
  final List<PokemonReference> pokemons;

  const PokemonGridTab({
    super.key,
    required this.title,
    required this.pokemons,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style: AppTypography.headline6,
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: pokemons.length,
            itemBuilder: (context, index) {
              final pokemon = pokemons[index];
              return _buildPokemonCard(context, pokemon);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPokemonCard(BuildContext context, PokemonReference pokemon) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Mahas.routeTo(
            AppRoutes.pokemonDetail,
            arguments: {
              'id': pokemon.id,
              'name': pokemon.name,
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
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
              const SizedBox(height: 8),
              Text(
                pokemon.formattedName,
                style: AppTypography.subtitle1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
