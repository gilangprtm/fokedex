import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/mahas/mahas_type.dart';
import '../../../../core/mahas/widget/mahas_loader.dart';
import '../../../../core/mahas/widget/mahas_button.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_typografi.dart';
import '../../../providers/type/type_chart/type_chart_notifier.dart';
import '../../../providers/type/type_chart/type_chart_provider.dart';

class TypeChartPage extends ConsumerWidget {
  const TypeChartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only watch essential state at top level
    final isLoading =
        ref.watch(typeChartProvider.select((state) => state.isLoading));
    final error = ref.watch(typeChartProvider.select((state) => state.error));
    final typesList =
        ref.watch(typeChartProvider.select((state) => state.typesList));
    final notifier = ref.read(typeChartProvider.notifier);

    // Loading state
    if (isLoading && typesList.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Type Chart'),
          backgroundColor: AppColors.pokemonRed,
          elevation: 0,
        ),
        body: const MahasLoader(isLoading: true),
      );
    }

    // Error state
    if (error != null && typesList.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Type Chart'),
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
                'Error loading type data',
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
                onPressed: () => notifier.refresh(),
                type: ButtonType.primary,
                color: AppColors.pokemonRed,
              ),
            ],
          ),
        ),
      );
    }

    // Main content
    return Scaffold(
      appBar: AppBar(
        title: const Text('Type Chart'),
        backgroundColor: AppColors.pokemonRed,
        elevation: 0,
        actions: [
          if (!isLoading)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => notifier.refresh(),
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: _buildContent(context, ref),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref) {
    return Consumer(
      builder: (context, ref, _) {
        final isLoading =
            ref.watch(typeChartProvider.select((state) => state.isLoading));
        final typesList =
            ref.watch(typeChartProvider.select((state) => state.typesList));
        final typeDetails =
            ref.watch(typeChartProvider.select((state) => state.typeDetails));
        final notifier = ref.read(typeChartProvider.notifier);

        if (typesList.isEmpty) {
          return const Center(
            child: MahasLoader(isLoading: true),
          );
        }

        // Sort types for consistency
        final sortedTypes = typesList.toList()
          ..sort((a, b) => a.name.compareTo(b.name));

        return RefreshIndicator(
          onRefresh: () => notifier.refresh(),
          color: AppColors.pokemonRed,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height -
                  100, // Subtract app bar height
              child: Column(
                children: [
                  // Title
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Pokémon Type Effectiveness Chart',
                      style: AppTypography.headline6,
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Legend
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildLegendItem(
                            '2×', Colors.green[700]!, 'Super Effective'),
                        _buildLegendItem('1×', Colors.grey[400]!, 'Normal'),
                        _buildLegendItem(
                            '½', Colors.red[300]!, 'Not Very Effective'),
                        _buildLegendItem('0×', Colors.black45, 'No Effect'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Show loading if we have types list but still loading details
                  if (isLoading && typeDetails.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.pokemonRed),
                            ),
                            SizedBox(height: 16),
                            Text("Loading type details...")
                          ],
                        ),
                      ),
                    )
                  // Type chart
                  else
                    Expanded(
                      child: typeDetails.isEmpty
                          ? const Center(
                              child: Text("No type details available"),
                            )
                          : _buildTypeChart(sortedTypes, notifier),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(String value, Color color, String label) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              value,
              style: AppTypography.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.caption,
        ),
      ],
    );
  }

  Widget _buildTypeChart(List<dynamic> types, TypeChartNotifier notifier) {
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with defending types
              Row(
                children: [
                  // Empty cell for the corner
                  Container(
                    width: 100,
                    height: 60,
                    alignment: Alignment.center,
                    color: Colors.grey[200],
                    child: Text(
                      'ATK \\ DEF',
                      style: AppTypography.subtitle1.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Defending type headers
                  ...types.map((type) => Container(
                        width: 60,
                        height: 60,
                        alignment: Alignment.center,
                        color: Color(notifier.getTypeColor(type.name)),
                        child: Text(
                          notifier.formatTypeName(type.name),
                          style: AppTypography.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )),
                ],
              ),
              // Rows for each attacking type
              ...types.map((attackingType) => Row(
                    children: [
                      // Attacking type header
                      Container(
                        width: 100,
                        height: 60,
                        alignment: Alignment.center,
                        color: Color(notifier.getTypeColor(attackingType.name)),
                        child: Text(
                          notifier.formatTypeName(attackingType.name),
                          style: AppTypography.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // Effectiveness cells
                      ...types.map((defendingType) {
                        final multiplier = notifier.getDamageMultiplier(
                            attackingType.name, defendingType.name);
                        Color cellColor;
                        if (multiplier == 2.0) {
                          cellColor = Colors.green[700]!;
                        } else if (multiplier == 1.0) {
                          cellColor = Colors.grey[400]!;
                        } else if (multiplier == 0.5) {
                          cellColor = Colors.red[300]!;
                        } else {
                          cellColor = Colors.black45;
                        }
                        return Container(
                          width: 60,
                          height: 60,
                          alignment: Alignment.center,
                          color: cellColor,
                          child: Text(
                            multiplier == 0.0
                                ? '0×'
                                : multiplier == 0.5
                                    ? '½'
                                    : multiplier == 2.0
                                        ? '2×'
                                        : '1×',
                            style: AppTypography.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
