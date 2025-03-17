import 'package:flutter/material.dart';
import '../../../../core/utils/pokemon_type_utils.dart';

class PokemonTypeBadge extends StatelessWidget {
  final String typeName;

  const PokemonTypeBadge({Key? key, required this.typeName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final typeColor = PokemonTypeUtils.getTypeColor(typeName);
    final formattedName = PokemonTypeUtils.formatTypeName(typeName);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: typeColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Try to load type icon if available
          Image.asset(
            PokemonTypeUtils.getTypeIconPath(typeName),
            width: 16,
            height: 16,
            errorBuilder: (context, error, stackTrace) {
              // If icon not found, just show the text
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(width: 4),
          Text(
            formattedName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
