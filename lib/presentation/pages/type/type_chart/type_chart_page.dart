import 'package:flutter/material.dart';
import '../../../../core/base/provider_widget.dart';
import '../../../../core/mahas/mahas_type.dart';
import '../../../../core/mahas/widget/mahas_loader.dart';
import '../../../../core/mahas/widget/mahas_button.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_typografi.dart';
import '../../../providers/type/type_chart_provider.dart';

class TypeChartPage extends StatelessWidget {
  const TypeChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderPage<TypeChartProvider>(
      createProvider: () => TypeChartProvider(),
      builder: (context, provider) => _buildPage(context, provider),
    );
  }

  Widget _buildPage(BuildContext context, TypeChartProvider provider) {
    return PropertySelector<TypeChartProvider, Map<String, dynamic>>(
      property: 'typesList',
      selector: (provider) => {
        'isLoading': provider.isLoading,
        'hasError': provider.hasError,
        'errorMessage': provider.errorMessage,
        'typesList': provider.typesList,
      },
      builder: (context, data) {
        final isLoading = data['isLoading'] as bool;
        final hasError = data['hasError'] as bool;
        final errorMessage = data['errorMessage'] as String;
        final typesList = data['typesList'] as List<dynamic>;

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
        if (hasError && typesList.isEmpty) {
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
                    errorMessage,
                    style: AppTypography.bodyText2,
                  ),
                  const SizedBox(height: 16),
                  MahasButton(
                    text: 'Try Again',
                    onPressed: () => provider.refresh(),
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
                  onPressed: () => provider.refresh(),
                  tooltip: 'Refresh',
                ),
            ],
          ),
          body: _buildContent(context, provider),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, TypeChartProvider provider) {
    return PropertySelector<TypeChartProvider, Map<String, dynamic>>(
      property: 'typeDetails',
      selector: (provider) => {
        'isLoading': provider.isLoading,
        'typesList': provider.typesList,
        'typeDetails': provider.typeDetails,
      },
      builder: (context, data) {
        final isLoading = data['isLoading'] as bool;
        final typesList = data['typesList'] as List<dynamic>;
        final typeDetails = data['typeDetails'] as Map<String, dynamic>;

        if (typesList.isEmpty) {
          return const Center(
            child: MahasLoader(isLoading: true),
          );
        }

        // Sort types for consistency
        final sortedTypes = typesList.toList()
          ..sort((a, b) => a.name.compareTo(b.name));

        return RefreshIndicator(
          onRefresh: () => provider.refresh(),
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
                          : _buildTypeChart(sortedTypes, provider),
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

  Widget _buildTypeChart(List<dynamic> types, TypeChartProvider provider) {
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
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Defending type headers
                  ...types.map((type) {
                    final typeName = type.name;
                    return Container(
                      width: 60,
                      height: 60,
                      alignment: Alignment.center,
                      color: Color(provider.getTypeColor(typeName))
                          .withOpacity(0.7),
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Text(
                          provider.formatTypeName(typeName),
                          style: AppTypography.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }),
                ],
              ),

              // Type effectiveness rows
              ...types.map((attackingType) {
                final attackingTypeName = attackingType.name;
                return Row(
                  children: [
                    // Attacking type header
                    Container(
                      width: 100,
                      height: 40,
                      alignment: Alignment.center,
                      color: Color(provider.getTypeColor(attackingTypeName)),
                      child: Text(
                        provider.formatTypeName(attackingTypeName),
                        style: AppTypography.bodyText2.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // Effectiveness cells
                    ...types.map((defendingType) {
                      final defendingTypeName = defendingType.name;
                      final effectiveness = provider.getDamageMultiplier(
                          attackingTypeName, defendingTypeName);
                      return _buildEffectivenessCell(effectiveness);
                    }),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEffectivenessCell(double effectiveness) {
    Color cellColor;
    String text;

    if (effectiveness == 2.0) {
      cellColor = Colors.green[700]!;
      text = '2×';
    } else if (effectiveness == 0.5) {
      cellColor = Colors.red[300]!;
      text = '½';
    } else if (effectiveness == 0.0) {
      cellColor = Colors.black45;
      text = '0';
    } else {
      cellColor = Colors.grey[400]!;
      text = '1';
    }

    return Container(
      width: 60,
      height: 40,
      alignment: Alignment.center,
      color: cellColor,
      child: Text(
        text,
        style: AppTypography.bodyText2.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
