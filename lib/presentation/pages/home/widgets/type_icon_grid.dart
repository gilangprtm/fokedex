import 'package:flutter/material.dart';
import '../../../../core/utils/pokemon_type_utils.dart';

/// A widget that displays all Pokemon type icons in a grid
class TypeIconGrid extends StatelessWidget {
  const TypeIconGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: PokemonTypeUtils.allTypes.length,
      itemBuilder: (context, index) {
        final type = PokemonTypeUtils.allTypes[index];
        final color = PokemonTypeUtils.getTypeColor(type);

        return Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                PokemonTypeUtils.getTypeIconPath(type),
                width: 24,
                height: 24,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error_outline, size: 16);
                },
              ),
              const SizedBox(width: 8),
              Text(
                PokemonTypeUtils.formatTypeName(type),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
