import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/mahas/mahas_type.dart';
import '../../../../core/mahas/widget/mahas_loader.dart';
import '../../../../core/mahas/widget/mahas_button.dart';
import '../../../../core/mahas/widget/mahas_card.dart';
import '../../../../core/mahas/widget/mahas_tab.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_typografi.dart';
import '../../../../data/models/api_response_model.dart';
import '../../../providers/location/location_detail/location_detail_provider.dart';
import '../../../routes/app_routes.dart';
import '../../../../core/utils/mahas.dart';

class LocationDetailPage extends ConsumerWidget {
  const LocationDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only watch essential state at top level
    final isLoading =
        ref.watch(locationDetailProvider.select((state) => state.isLoading));
    final error =
        ref.watch(locationDetailProvider.select((state) => state.error));
    final location =
        ref.watch(locationDetailProvider.select((state) => state.location));
    final currentLocationName = ref.watch(
        locationDetailProvider.select((state) => state.currentLocationName));
    final currentLocationId = ref.watch(
        locationDetailProvider.select((state) => state.currentLocationId));
    final notifier = ref.read(locationDetailProvider.notifier);

    // Show loading state
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            _capitalizeFirstLetter(currentLocationName),
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
            _capitalizeFirstLetter(currentLocationName),
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
                'Error loading location details',
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
                onPressed: () => notifier.loadLocationDetail(
                    currentLocationId.isNotEmpty
                        ? currentLocationId
                        : currentLocationName),
                type: ButtonType.primary,
                color: AppColors.pokemonRed,
              ),
            ],
          ),
        ),
      );
    }

    // No data loaded yet
    if (location == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            _capitalizeFirstLetter(currentLocationName),
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

    // Show Location details
    return Scaffold(
      body: _buildBody(context, ref),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        // Custom app bar with Location basic info
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
              tabLabels: const ['Overview', 'Areas'],
              tabViews: [
                // Overview Tab
                _buildOverviewTab(ref),
                // Areas Tab
                _buildAreasTab(ref),
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
    final currentLocationName = ref.watch(
        locationDetailProvider.select((state) => state.currentLocationName));

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

            // Location name
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  Text(
                    _capitalizeFirstLetter(
                        currentLocationName.replaceAll('-', ' ')),
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
        final location =
            ref.watch(locationDetailProvider.select((state) => state.location));

        if (location == null) {
          return const Center(child: Text('No overview data available'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Region
              if (location.region != null) ...[
                MahasCustomizableCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Region',
                        style: AppTypography.headline6,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _capitalizeFirstLetter(location.region!.name),
                        style: AppTypography.bodyText1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Game Indices
              if (location.gameIndices?.isNotEmpty == true) ...[
                MahasCustomizableCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Game Appearances',
                        style: AppTypography.headline6,
                      ),
                      const SizedBox(height: 10),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: location.gameIndices?.length ?? 0,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final gameIndex = location.gameIndices?[index];
                          if (gameIndex == null) return const SizedBox.shrink();
                          return Text(
                            '${_capitalizeFirstLetter(gameIndex.generation.name)} (Game Index: ${gameIndex.gameIndex})',
                            style: AppTypography.bodyText1,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Names in different languages
              if (location.names?.isNotEmpty == true) ...[
                MahasCustomizableCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Names in Other Languages',
                        style: AppTypography.headline6,
                      ),
                      const SizedBox(height: 10),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: location.names?.length ?? 0,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final name = location.names?[index];
                          if (name == null) return const SizedBox.shrink();
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.pokemonRed
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _capitalizeFirstLetter(name.language.name),
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.pokemonRed,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  name.name,
                                  style: AppTypography.bodyText2,
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

  Widget _buildAreasTab(WidgetRef ref) {
    return Consumer(
      builder: (context, ref, _) {
        final location =
            ref.watch(locationDetailProvider.select((state) => state.location));

        if (location == null) {
          return const Center(child: Text('No areas data available'));
        }

        if (location.areas?.isEmpty == true) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.map_outlined, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No Areas Found',
                  style: AppTypography.headline6,
                ),
                const SizedBox(height: 8),
                Text(
                  'This location has no specific areas',
                  style: AppTypography.bodyText2,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: location.areas?.length ?? 0,
          itemBuilder: (context, index) {
            final area = location.areas?[index];
            if (area == null) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: MahasCustomizableCard(
                child: InkWell(
                  onTap: () => _navigateToLocationAreaDetail(context, area),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _capitalizeFirstLetter(
                                    area.name.replaceAll('-', ' ')),
                                style: AppTypography.subtitle1.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'ID: ${_extractIdFromUrl(area.url)}',
                                style: AppTypography.bodyText2.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right,
                            color: AppColors.pokemonRed),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Helper to extract ID from URL
  String _extractIdFromUrl(String url) {
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    return pathSegments[pathSegments.length - 2];
  }

  void _navigateToLocationAreaDetail(
      BuildContext context, ResourceListItem area) {
    // Sampai halaman location area detail dibuat
    Mahas.routeTo(
      AppRoutes.locationAreaDetail,
      arguments: {
        'id': area.id,
        'name': area.name,
        'locationName': _capitalizeFirstLetter(area.name.split('-')[0])
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
