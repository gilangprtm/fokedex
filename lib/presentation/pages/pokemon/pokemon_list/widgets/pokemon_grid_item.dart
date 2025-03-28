import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../data/datasource/models/api_response_model.dart';
import '../../../../../core/theme/app_color.dart';
import '../../../../../core/utils/pokemon_type_utils.dart';
import '../../../../../core/utils/image_cache_utils.dart';
import '../../../../providers/pokemon/pokemon_list_provider.dart';

class PokemonGridItem extends StatelessWidget {
  final ResourceListItem pokemon;
  final VoidCallback? onTap;

  const PokemonGridItem({
    super.key,
    required this.pokemon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Extract ID from URL
    final pokemonId = pokemon.id;

    // Get Pokemon details from provider
    final provider = context.watch<PokemonListProvider>();
    final pokemonDetails = provider.getPokemonDetails(pokemonId);
    final activeTypeFilter = provider.activeTypeFilter;

    // Get primary type color
    Color typeColor;

    // If there's an active type filter, use its color first
    if (activeTypeFilter != null) {
      typeColor = PokemonTypeUtils.getTypeColor(activeTypeFilter);
    }
    // Otherwise use the Pokemon's first type if available
    else if (pokemonDetails?.types?.isNotEmpty == true) {
      typeColor =
          PokemonTypeUtils.getTypeColor(pokemonDetails!.types!.first.type.name);
    }
    // Default fallback color
    else {
      typeColor = AppColors.pokemonRed;
    }

    // Image URL for the Pokemon
    final imageUrl =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$pokemonId.png';

    // Formatted ID (e.g., #001, #025, #150)
    final formattedId = '#${pokemonId.toString().padLeft(3, '0')}';

    // Capitalized name
    final capitalizedName =
        pokemon.name.substring(0, 1).toUpperCase() + pokemon.name.substring(1);

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ID badge
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                margin: const EdgeInsets.only(top: 8, right: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  formattedId,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),

            // Pokemon image
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Hero(
                  tag: 'pokemon-$pokemonId',
                  child: ImageCacheUtils.buildPokemonImage(
                    imageUrl: imageUrl,
                    height: 80,
                    width: 80,
                    progressColor: typeColor.withValues(alpha: 0.7),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.catching_pokemon,
                      size: 60,
                      color: AppColors.pokemonGray,
                    ),
                  ),
                ),
              ),
            ),

            // Pokemon name
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: typeColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Text(
                capitalizedName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
