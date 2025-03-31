import 'package:flutter/material.dart';
import '../../../../core/base/provider_widget.dart';
import '../../../../core/mahas/mahas_type.dart';
import '../../../../core/mahas/widget/mahas_loader.dart';
import '../../../../core/mahas/widget/mahas_button.dart';
import '../../../../core/mahas/widget/mahas_card.dart';
import '../../../../core/mahas/widget/mahas_tab.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_typografi.dart';
import '../../../../data/models/pokemon_model.dart';
import '../../../providers/location/location_area_detail_provider.dart';
import '../../../widgets/pokemon_grid_tab.dart';

class LocationAreaDetailPage extends StatelessWidget {
  const LocationAreaDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderPage<LocationAreaDetailProvider>(
      createProvider: () => LocationAreaDetailProvider(),
      builder: (context, provider) => _buildDetailPage(context, provider),
    );
  }

  Widget _buildDetailPage(
      BuildContext context, LocationAreaDetailProvider provider) {
    // Show loading state
    if (provider.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            _capitalizeFirstLetter(provider.currentAreaName),
            style: AppTypography.headline6.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.pokemonRed,
          elevation: 0,
        ),
        body: const MahasLoader(isLoading: true),
      );
    }

    // Show error state
    if (provider.hasError) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            _capitalizeFirstLetter(provider.currentAreaName),
            style: AppTypography.headline6.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.pokemonRed,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.errorColor),
              const SizedBox(height: 16),
              Text(
                'Error loading area details',
                style: AppTypography.headline6,
              ),
              const SizedBox(height: 8),
              Text(
                provider.errorMessage,
                style: AppTypography.bodyText2,
              ),
              const SizedBox(height: 16),
              MahasButton(
                text: 'Try Again',
                onPressed: () => provider.loadAreaDetail(
                    provider.currentAreaId.isNotEmpty
                        ? provider.currentAreaId
                        : provider.currentAreaName),
                type: ButtonType.primary,
                color: AppColors.pokemonRed,
              ),
            ],
          ),
        ),
      );
    }

    // No data loaded yet
    if (provider.areaDetail == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            _capitalizeFirstLetter(provider.currentAreaName),
            style: AppTypography.headline6.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.pokemonRed,
          elevation: 0,
        ),
        body: Center(
          child: Text(
            'No data available',
            style: AppTypography.bodyText1,
          ),
        ),
      );
    }

    // Show Area details
    return Scaffold(
      body: _buildBody(context, provider),
    );
  }

  Widget _buildBody(BuildContext context, LocationAreaDetailProvider provider) {
    return CustomScrollView(
      slivers: [
        // Custom app bar with Area basic info
        _buildSliverAppBar(context, provider),
        // Add padding at the bottom
        const SliverToBoxAdapter(
          child: SizedBox(height: 16),
        ),
        // Tab Bar with content
        SliverToBoxAdapter(
          child: SizedBox(
            height: MediaQuery.of(context).size.height -
                100, // Subtract app bar height
            child: MahasPillTabBar(
              tabLabels: const ['Overview', 'Pokémon'],
              tabViews: [
                // Overview Tab
                _buildOverviewTab(provider),
                // Pokemon Tab
                _buildPokemonTab(context, provider),
              ],
              activeColor: AppColors.pokemonRed,
              backgroundColor: Colors.grey[200]!,
              activeTextColor: Colors.white,
              inactiveTextColor: Colors.black87,
              height: 45,
              borderRadius: 15,
            ),
          ),
        ),
        // Add padding at the bottom
        const SliverToBoxAdapter(
          child: SizedBox(height: 32),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(
      BuildContext context, LocationAreaDetailProvider provider) {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.pokemonRed,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Background color
            Container(
              color: AppColors.pokemonRed,
            ),

            // Decorative Poké Ball pattern in the background
            Positioned(
              right: -50,
              top: -50,
              child: Icon(
                Icons.catching_pokemon,
                size: 200,
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),

            // Location and Area name
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    provider.locationName.isNotEmpty
                        ? provider.locationName
                        : _capitalizeFirstLetter(
                            provider.areaDetail?.location.name ?? ''),
                    style: AppTypography.subtitle1.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _capitalizeFirstLetter(
                        provider.currentAreaName.replaceAll('-', ' ')),
                    style: AppTypography.headline5.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(LocationAreaDetailProvider provider) {
    final area = provider.areaDetail!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Info
          MahasCustomizableCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Area Information',
                  style: AppTypography.headline6,
                ),
                const SizedBox(height: 10),
                Text(
                  'Game Index: ${area.gameIndex}',
                  style: AppTypography.bodyText1,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Encounter Method Rates
          if (area.encounterMethodRates?.isNotEmpty == true) ...[
            MahasCustomizableCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Encounter Methods',
                    style: AppTypography.headline6,
                  ),
                  const SizedBox(height: 10),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: area.encounterMethodRates?.length ?? 0,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final methodRate = area.encounterMethodRates?[index];
                      if (methodRate == null) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _capitalizeFirstLetter(
                                methodRate.encounterMethod.name),
                            style: AppTypography.subtitle1.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            children: methodRate.versionDetails?.map((detail) {
                                  return Chip(
                                    label: Text(
                                      '${_capitalizeFirstLetter(detail.version.name)}: ${detail.rate}%',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    backgroundColor: AppColors.pokemonRed
                                        .withValues(alpha: 0.1),
                                  );
                                }).toList() ??
                                [],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPokemonTab(
      BuildContext context, LocationAreaDetailProvider provider) {
    final pokemonEncounters = provider.getPokemonEncounters();

    if (pokemonEncounters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.catching_pokemon,
                size: 48, color: AppColors.pokemonGray),
            const SizedBox(height: 16),
            Text(
              'No Pokémon Found',
              style: AppTypography.headline6,
            ),
            const SizedBox(height: 8),
            Text(
              'No Pokémon can be encountered in this area.',
              style: AppTypography.bodyText2,
            ),
          ],
        ),
      );
    }

    final gridItems = pokemonEncounters
        .map((encounter) => PokemonReference(
            name: encounter.pokemon.name, url: encounter.pokemon.url))
        .toList();

    return PokemonGridTab(
      title: 'Pokémon in this area',
      pokemons: gridItems,
    );
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return '';

    // Split by dash or space and capitalize each word
    final words = text.split(RegExp(r'[-\s]'));
    final capitalizedWords = words.map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1);
    }).toList();

    return capitalizedWords.join(' ');
  }
}
