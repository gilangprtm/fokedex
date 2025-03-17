import 'package:flutter/material.dart';
import '../../../../data/datasource/models/pokemon_model.dart';

class PokemonStatsWidget extends StatelessWidget {
  final List<PokemonStat> stats;

  const PokemonStatsWidget({Key? key, required this.stats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sort stats to ensure they're in the correct order
    final sortedStats = List<PokemonStat>.from(stats);
    sortedStats.sort((a, b) => a.stat.name.compareTo(b.stat.name));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedStats.map((stat) => _buildStatRow(stat)).toList(),
    );
  }

  Widget _buildStatRow(PokemonStat stat) {
    // Max base stat to determine progress bar percentage (255 is max for any stat)
    const int maxBaseStat = 255;

    // Percentage for progress indicator
    final double percentage = stat.baseStat / maxBaseStat;

    // Color for the progress bar based on stat value
    final Color progressColor = _getStatColor(stat.baseStat);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Stat name
          SizedBox(
            width: 80,
            child: Text(
              stat.stat.formattedName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Stat value
          SizedBox(
            width: 40,
            child: Text(
              stat.baseStat.toString(),
              textAlign: TextAlign.right,
            ),
          ),

          const SizedBox(width: 12),

          // Progress bar
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Get color based on stat value
  Color _getStatColor(int value) {
    if (value < 50) {
      return Colors.red;
    } else if (value < 90) {
      return Colors.orange;
    } else if (value < 110) {
      return Colors.yellow.shade700;
    } else if (value < 130) {
      return Colors.green;
    } else {
      return Colors.teal;
    }
  }
}
