import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../data/models/api_response_model.dart';
import '../../../../../data/models/pokemon_list_item_model.dart';
import '../../../../../core/theme/app_color.dart';
import '../../../../../core/utils/pokemon_type_utils.dart';
import '../../../../../core/utils/image_cache_utils.dart';
import '../../../../../core/utils/mahas.dart';
import '../../../../routes/app_routes.dart';
import '../../../../providers/pokemon/pokemon_list/pokemon_list_provider.dart';

/// A grid item displaying a Pokémon card with image, name, and ID
/// This widget is optimized to only rebuild when necessary
class PokemonGridItem extends ConsumerWidget {
  final ResourceListItem pokemon;

  const PokemonGridItem({
    super.key,
    required this.pokemon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Extract ID from URL
    final pokemonId = pokemon.id;

    // Watch only the minimum state needed for this item
    final itemState = ref.watch(pokemonListProvider.select((state) => ({
          'details': state.getPokemonDetails(pokemonId),
          'activeFilter': state.activeTypeFilter,
        })));

    final pokemonDetails = itemState['details'] as PokemonList?;
    final activeTypeFilter = itemState['activeFilter'] as String?;

    // Determine the primary color for the card
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
      onTap: () {
        // Navigate to detail page
        Mahas.routeTo(
          AppRoutes.pokemonDetail,
          arguments: {
            'id': pokemonId.toString(),
            'name': pokemon.name,
          },
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
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
                    progressColor: typeColor.withOpacity(0.7),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.catching_pokemon,
                      size: 60,
                      color: AppColors.pokemonGray,
                    ),
                  ),
                ),
              ),
            ),

            // Pokemon name with type-colored background
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
