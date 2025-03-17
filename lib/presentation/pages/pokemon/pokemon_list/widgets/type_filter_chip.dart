import 'package:flutter/material.dart';
import '../../../../../core/utils/pokemon_type_utils.dart';

class TypeFilterChip extends StatelessWidget {
  final String typeName;
  final bool isSelected;
  final VoidCallback onSelected;

  const TypeFilterChip({
    super.key,
    required this.typeName,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = PokemonTypeUtils.getTypeColor(typeName);

    return FilterChip(
      label: Row(
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
            PokemonTypeUtils.formatTypeName(typeName),
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      backgroundColor: typeColor.withOpacity(0.2),
      selectedColor: typeColor,
      checkmarkColor: Colors.white,
    );
  }
}
