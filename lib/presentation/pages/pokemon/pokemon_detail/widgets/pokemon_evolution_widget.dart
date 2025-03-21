import 'package:flutter/material.dart';
import '../../../../../core/utils/mahas.dart';
import '../../../../../core/utils/image_cache_utils.dart';
import '../../../../../data/datasource/models/evolution_stage_model.dart';
import '../../../../../presentation/routes/app_routes.dart';

class PokemonEvolutionWidget extends StatelessWidget {
  final List<EvolutionStage> evolutionStages;
  final String pokemonId;

  const PokemonEvolutionWidget({
    super.key,
    required this.evolutionStages,
    required this.pokemonId,
  });

  @override
  Widget build(BuildContext context) {
    if (evolutionStages.isEmpty) {
      return const Center(
        child: Text('No evolution data available'),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: evolutionStages.length == 1
          ? _buildSingleEvolution()
          : _buildEvolutionChain(context),
    );
  }

  Widget _buildSingleEvolution() {
    final stage = evolutionStages.first;

    return Column(
      children: [
        Text(
          'This Pokémon does not evolve',
          style: TextStyle(
            color: Colors.grey.shade700,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 16),
        _buildPokemonAvatar(null, stage),
      ],
    );
  }

  Widget _buildEvolutionChain(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < evolutionStages.length; i++)
          Column(
            children: [
              _buildPokemonAvatar(context, evolutionStages[i]),

              // Show evolution details between stages
              if (i < evolutionStages.length - 1)
                Column(
                  children: [
                    const SizedBox(height: 8),
                    Icon(Icons.arrow_downward, color: Colors.grey.shade600),
                    const SizedBox(height: 8),
                    if (evolutionStages[i + 1].evolutionDetails.isNotEmpty)
                      Text(
                        evolutionStages[i + 1].evolutionDetails.join(', '),
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 8),
                  ],
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildPokemonAvatar(BuildContext? context, EvolutionStage stage) {
    return GestureDetector(
      onTap: stage.id != pokemonId
          ? () {
              Mahas.routeTo(
                AppRoutes.pokemonDetail,
                arguments: {
                  'id': stage.id,
                  'name': stage.name,
                },
              );
            }
          : null,
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: ClipOval(
              child: ImageCacheUtils.buildPokemonImage(
                imageUrl: stage.imageUrl,
                height: 60,
                width: 60,
                progressColor: Colors.grey.shade300,
                errorWidget: (context, url, error) {
                  return Icon(
                    Icons.catching_pokemon,
                    size: 40,
                    color: Colors.grey.shade400,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _capitalizeFirstLetter(stage.name),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '#${stage.id.toString().padLeft(3, '0')}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }
}
