import 'package:flutter/material.dart';
import '../../../../../data/datasource/models/pokemon_model.dart';

class PokemonMovesWidget extends StatefulWidget {
  final List<PokemonMove> moves;

  const PokemonMovesWidget({super.key, required this.moves});

  @override
  State<PokemonMovesWidget> createState() => _PokemonMovesWidgetState();
}

class _PokemonMovesWidgetState extends State<PokemonMovesWidget> {
  // Filter and search state
  String _searchQuery = '';
  bool _showExpanded = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sort moves alphabetically
    final sortedMoves = List<PokemonMove>.from(widget.moves);
    sortedMoves.sort((a, b) => a.move.name.compareTo(b.move.name));

    // Apply search filter
    final filteredMoves = _searchQuery.isEmpty
        ? sortedMoves
        : sortedMoves
            .where(
                (move) => move.move.name.contains(_searchQuery.toLowerCase()))
            .toList();

    // Limit moves to display if not expanded
    final displayMoves =
        _showExpanded ? filteredMoves : filteredMoves.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search moves',
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, size: 16),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
            ),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          },
        ),

        const SizedBox(height: 16),

        // Moves count
        Text(
          '${filteredMoves.length} moves found',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),

        const SizedBox(height: 12),

        // Moves list
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: displayMoves.map(_buildMoveChip).toList(),
          ),
        ),

        // Show more/less button
        if (filteredMoves.length > 10)
          TextButton(
            onPressed: () {
              setState(() {
                _showExpanded = !_showExpanded;
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_showExpanded
                    ? 'Show less'
                    : 'Show all ${filteredMoves.length} moves'),
                Icon(_showExpanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMoveChip(PokemonMove move) {
    final moveName = move.move.name.replaceAll('-', ' ');
    final formattedName =
        moveName.substring(0, 1).toUpperCase() + moveName.substring(1);

    return Chip(
      label: Text(formattedName),
      backgroundColor: Colors.white,
      side: BorderSide(color: Colors.grey.shade300),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
