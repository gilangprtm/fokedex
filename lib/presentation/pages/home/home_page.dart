import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_typografi.dart';
import '../../../core/utils/mahas.dart';
import '../../providers/home/home_provider.dart';
import '../../../core/mahas/mahas_type.dart';
import '../../routes/app_routes.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // No need to watch the state if it's not being used in the UI
    // final state = ref.watch(homeProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Search Header
          SliverToBoxAdapter(
            child: _buildSearchHeader(context),
          ),

          // Category Buttons
          SliverToBoxAdapter(
            child: _buildCategoryButtons(context),
          ),

          // Bottom Padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What Pokémon\nare you looking for?',
            style: AppTypography.headline5.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search Pokemon, Move, Ability, etc',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  Mahas.routeTo(AppRoutes.pokemonList,
                      arguments: {'search': value});
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildCategoryButton(
                  context,
                  'Pokedex',
                  Colors.greenAccent,
                  () => Mahas.routeTo(AppRoutes.pokemonList),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCategoryButton(
                  context,
                  'Moves',
                  Colors.redAccent,
                  () => Mahas.routeTo(AppRoutes.moveList),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildCategoryButton(
                  context,
                  'Abilities',
                  Colors.blueAccent,
                  () => Mahas.routeTo(AppRoutes.abilityList),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCategoryButton(
                  context,
                  'Items',
                  Colors.amberAccent,
                  () => Mahas.routeTo(AppRoutes.itemList),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildCategoryButton(
                  context,
                  'Locations',
                  Colors.purpleAccent,
                  () => Mahas.routeTo(AppRoutes.locationList),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCategoryButton(
                  context,
                  'Type Charts',
                  Colors.brown,
                  () {
                    Mahas.routeTo(AppRoutes.typeChart);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(
    BuildContext context,
    String title,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(16),
        shape: const RoundedRectangleBorder(
          borderRadius: MahasBorderRadius.large,
        ),
        minimumSize: const Size(double.infinity, 60),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTypography.button.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_forward,
              color: Colors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
