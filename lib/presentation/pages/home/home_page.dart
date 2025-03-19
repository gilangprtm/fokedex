import 'package:flutter/material.dart';

import '../../../core/base/provider_widget.dart';
import '../../../core/theme/app_typografi.dart';
import '../../../core/utils/mahas.dart';
import '../../providers/home_provider.dart';
import '../../../core/mahas/mahas_type.dart';
import '../../routes/app_routes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderPage<HomeProvider>(
      createProvider: () => HomeProvider(),
      builder: (context, provider) => Scaffold(
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
                  color: Colors.black.withOpacity(0.1),
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
                  Mahas.routeTo('/pokemon', arguments: {'search': value});
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
                  () {
                    // Navigate to moves page
                  },
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
                  () {
                    // Navigate to abilities page
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCategoryButton(
                  context,
                  'Items',
                  Colors.amberAccent,
                  () {
                    // Navigate to items page
                  },
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
                  () {
                    // Navigate to locations page
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCategoryButton(
                  context,
                  'Type Charts',
                  Colors.brown,
                  () {
                    // Navigate to type charts page
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
              color: Colors.white.withOpacity(0.3),
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
