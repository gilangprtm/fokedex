import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/mahas/mahas_type.dart';
import '../../../../core/mahas/widget/mahas_loader.dart';
import '../../../../core/mahas/widget/mahas_button.dart';
import '../../../../core/mahas/widget/mahas_card.dart';
import '../../../../core/mahas/widget/mahas_tab.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_typografi.dart';
import '../../../../data/models/pokemon_model.dart';
import '../../../providers/location/location_area_detail/location_area_detail_provider.dart';
import '../../../widgets/pokemon_grid_tab.dart';

class LocationAreaDetailPage extends ConsumerWidget {
  const LocationAreaDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only watch essential state at top level
    final isLoading = ref
        .watch(locationAreaDetailProvider.select((state) => state.isLoading));
    final error =
        ref.watch(locationAreaDetailProvider.select((state) => state.error));
    final areaDetail = ref
        .watch(locationAreaDetailProvider.select((state) => state.areaDetail));
    final currentAreaName = ref.watch(
        locationAreaDetailProvider.select((state) => state.currentAreaName));
    final currentAreaId = ref.watch(
        locationAreaDetailProvider.select((state) => state.currentAreaId));
    final notifier = ref.read(locationAreaDetailProvider.notifier);

    // Show loading state
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            _capitalizeFirstLetter(currentAreaName),
            style: AppTypography.headline6.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.pokemonRed,
          elevation: 0,
        ),
        body: const MahasLoader(isLoading: true),
      );
    }

    // Show error state
    if (error != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            _capitalizeFirstLetter(currentAreaName),
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
                error.toString(),
                style: AppTypography.bodyText2,
              ),
              const SizedBox(height: 16),
              MahasButton(
                text: 'Try Again',
                onPressed: () => notifier.loadAreaDetail(
                    currentAreaId.isNotEmpty ? currentAreaId : currentAreaName),
                type: ButtonType.primary,
                color: AppColors.pokemonRed,
              ),
            ],
          ),
        ),
      );
    }

    // No data loaded yet
    if (areaDetail == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            _capitalizeFirstLetter(currentAreaName),
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
      body: _buildBody(context, ref),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        // Custom app bar with Area basic info
        _buildSliverAppBar(context, ref),
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
                _buildOverviewTab(ref),
                // Pokemon Tab
                _buildPokemonTab(context, ref),
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

  Widget _buildSliverAppBar(BuildContext context, WidgetRef ref) {
    final currentAreaName = ref.watch(
        locationAreaDetailProvider.select((state) => state.currentAreaName));
    final locationName = ref.watch(
        locationAreaDetailProvider.select((state) => state.locationName));
    final areaDetail = ref
        .watch(locationAreaDetailProvider.select((state) => state.areaDetail));

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
                    locationName.isNotEmpty
                        ? locationName
                        : _capitalizeFirstLetter(
                            areaDetail?.location.name ?? ''),
                    style: AppTypography.subtitle1.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _capitalizeFirstLetter(
                        currentAreaName.replaceAll('-', ' ')),
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

  Widget _buildOverviewTab(WidgetRef ref) {
    return Consumer(
      builder: (context, ref, _) {
        final areaDetail = ref.watch(
            locationAreaDetailProvider.select((state) => state.areaDetail));

        if (areaDetail == null) {
          return const Center(child: Text('No overview data available'));
        }

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
                      'Game Index: ${areaDetail.gameIndex}',
                      style: AppTypography.bodyText1,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Encounter Method Rates
              if (areaDetail.encounterMethodRates?.isNotEmpty == true) ...[
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
                        itemCount: areaDetail.encounterMethodRates?.length ?? 0,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final rate = areaDetail.encounterMethodRates?[index];
                          if (rate == null) return const SizedBox.shrink();
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _capitalizeFirstLetter(
                                    rate.encounterMethod.name),
                                style: AppTypography.bodyText1,
                              ),
                              Text(
                                rate.versionDetails.first.version.name,
                                style: AppTypography.bodyText2.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Pokémon Encounters
              if (areaDetail.pokemonEncounters?.isNotEmpty == true) ...[
                MahasCustomizableCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Pokémon',
                        style: AppTypography.headline6,
                      ),
                      const SizedBox(height: 10),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: areaDetail.pokemonEncounters?.length ?? 0,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final encounter =
                              areaDetail.pokemonEncounters?[index];
                          if (encounter == null) return const SizedBox.shrink();
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _capitalizeFirstLetter(encounter.pokemon.name),
                                style: AppTypography.bodyText1,
                              ),
                              Text(
                                encounter.versionDetails.first.version.name,
                                style: AppTypography.bodyText2.copyWith(
                                  color: Colors.grey[600],
                                ),
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
      },
    );
  }

  Widget _buildPokemonTab(BuildContext context, WidgetRef ref) {
    return Consumer(
      builder: (context, ref, _) {
        final areaDetail = ref.watch(
            locationAreaDetailProvider.select((state) => state.areaDetail));

        if (areaDetail == null) {
          return const Center(child: Text('No Pokémon data available'));
        }

        if (areaDetail.pokemonEncounters?.isEmpty == true) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.catching_pokemon,
                    size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No Pokémon Found',
                  style: AppTypography.headline6,
                ),
                const SizedBox(height: 8),
                Text(
                  'This area has no available Pokémon',
                  style: AppTypography.bodyText2,
                ),
              ],
            ),
          );
        }

        final pokemonList = areaDetail.pokemonEncounters?.map((encounter) {
              final pokemon = encounter.pokemon;
              return PokemonReference(
                name: pokemon.name,
                url: pokemon.url,
              );
            }).toList() ??
            [];

        return PokemonGridTab(
          title: 'Pokémon in this area',
          pokemons: pokemonList,
        );
      },
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
