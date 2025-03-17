import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/base/provider_widget.dart';
import '../../../data/datasource/models/pokemon_model.dart';
import '../../../data/datasource/models/evolution_stage_model.dart';
import '../../providers/pokemon_detail_provider.dart';
import 'widgets/pokemon_stats_widget.dart';
import 'widgets/pokemon_type_badge.dart';
import 'widgets/pokemon_evolution_widget.dart';
import 'widgets/pokemon_moves_widget.dart';

class PokemonDetailPage extends StatelessWidget {
  final String pokemonId;
  final String pokemonName;

  const PokemonDetailPage({
    Key? key,
    required this.pokemonId,
    required this.pokemonName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderPage<PokemonDetailProvider>(
      createProvider: () => PokemonDetailProvider(),
      onInitState: (provider) => provider.loadPokemonDetail(pokemonId),
      builder: (context, provider) => _buildDetailPage(context, provider),
    );
  }

  Widget _buildDetailPage(
      BuildContext context, PokemonDetailProvider provider) {
    // Show loading state
    if (provider.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_capitalizeFirstLetter(pokemonName)),
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show error state
    if (provider.hasError) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_capitalizeFirstLetter(pokemonName)),
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading Pokémon details',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(provider.errorMessage),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => provider.loadPokemonDetail(pokemonId),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    // No data loaded yet
    if (provider.pokemon == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_capitalizeFirstLetter(pokemonName)),
          elevation: 0,
        ),
        body: const Center(
          child: Text('No data available'),
        ),
      );
    }

    // Show Pokemon details
    final pokemon = provider.pokemon!;
    final Color appBarColor = _getAppBarColor(provider);

    return Scaffold(
      body: _buildBody(context, provider, pokemon, appBarColor),
    );
  }

  // Determine app bar color based on Pokemon type or species
  Color _getAppBarColor(PokemonDetailProvider provider) {
    // Get the primary type color if available
    if (provider.pokemon?.types != null &&
        provider.pokemon!.types!.isNotEmpty) {
      final primaryType = provider.pokemon!.types!.first.type.name;
      // Return type color based on the primary type
      return _getTypeColor(primaryType);
    }

    // Default color if no type is available
    return Colors.blue;
  }

  Widget _buildBody(BuildContext context, PokemonDetailProvider provider,
      Pokemon pokemon, Color appBarColor) {
    final imageUrl = pokemon.imageUrl;

    return CustomScrollView(
      slivers: [
        // App bar with Pokemon image
        SliverAppBar(
          expandedHeight: 200.0,
          floating: false,
          pinned: true,
          backgroundColor: appBarColor,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              _capitalizeFirstLetter(pokemon.name),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Background color based on Pokemon type
                Container(
                  color: appBarColor,
                ),

                // Pokeball background
                Positioned(
                  right: -50,
                  top: -50,
                  child: Opacity(
                    opacity: 0.15,
                    child: Image.asset(
                      'assets/images/pokeball.png',
                      width: 200,
                      height: 200,
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),

                // Pokemon image
                Center(
                  child: Hero(
                    tag: 'pokemon-image-${pokemon.id}',
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      height: 150,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.catching_pokemon,
                          size: 100,
                          color: Colors.white.withOpacity(0.5),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Pokemon details
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pokemon ID and basic info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ID badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        pokemon.formattedId,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Height and weight
                    Row(
                      children: [
                        Icon(Icons.height,
                            size: 20, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(pokemon.formattedHeight),
                        const SizedBox(width: 16),
                        Icon(Icons.fitness_center,
                            size: 20, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(pokemon.formattedWeight),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Pokemon types
                if (pokemon.types != null)
                  Row(
                    children: pokemon.types!
                        .map((type) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: PokemonTypeBadge(typeName: type.type.name),
                            ))
                        .toList(),
                  ),

                const SizedBox(height: 24),

                // Pokemon description
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(provider.getDescription()),

                const SizedBox(height: 24),

                // Pokemon stats
                const Text(
                  'Base Stats',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (pokemon.stats != null)
                  PokemonStatsWidget(stats: pokemon.stats!),

                const SizedBox(height: 24),

                // Pokemon abilities
                const Text(
                  'Abilities',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (pokemon.abilities != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: pokemon.abilities!.map((ability) {
                      final abilityName = ability.ability.name;
                      final formattedName = abilityName.replaceAll('-', ' ');
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.star,
                                size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              _capitalizeFirstLetter(formattedName),
                              style: TextStyle(
                                fontStyle: ability.isHidden
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                              ),
                            ),
                            if (ability.isHidden)
                              Text(
                                ' (Hidden)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 24),

                // Evolution chain
                const Text(
                  'Evolution Chain',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                PokemonEvolutionWidget(
                  evolutionStages: provider.parseEvolutionChain(),
                ),

                const SizedBox(height: 24),

                // Moves
                const Text(
                  'Moves',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (pokemon.moves != null)
                  PokemonMovesWidget(moves: pokemon.moves!),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Get color based on Pokemon type
  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'grass':
        return Colors.green;
      case 'fire':
        return Colors.red;
      case 'water':
        return Colors.blue;
      case 'electric':
        return Colors.yellow;
      case 'psychic':
        return Colors.purple;
      case 'fighting':
        return Colors.brown;
      case 'rock':
        return Colors.brown.shade300;
      case 'ground':
        return Colors.brown.shade200;
      case 'flying':
        return Colors.indigo.shade200;
      case 'bug':
        return Colors.lightGreen;
      case 'poison':
        return Colors.purple.shade300;
      case 'normal':
        return Colors.grey.shade400;
      case 'ghost':
        return Colors.indigo;
      case 'dragon':
        return Colors.indigo.shade700;
      case 'dark':
        return Colors.grey.shade800;
      case 'steel':
        return Colors.blueGrey;
      case 'fairy':
        return Colors.pink;
      case 'ice':
        return Colors.lightBlue;
      default:
        return Colors.blue;
    }
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
