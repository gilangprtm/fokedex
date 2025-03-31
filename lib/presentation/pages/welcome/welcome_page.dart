import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/theme/app_typografi.dart';
import '../../../core/utils/mahas.dart';
import '../../../presentation/routes/app_routes.dart';
import '../../providers/welcome/welcome_notifier.dart';
import '../../providers/welcome/welcome_provider.dart';

class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only get the notifier, don't watch the entire state
    final notifier = ref.read(welcomeProvider.notifier);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.pokemonRed,
              Color(0xFFE53935),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top spacing
              const SizedBox(height: 32),

              // App logo and title
              _buildAppHeader(),

              // App description and loading progress
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App description
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Pokedex adalah ensiklopedia Pokemon lengkap yang memuat data dari semua generasi! Aplikasi ini dapat digunakan secara offline setelah data diunduh.',
                          style: AppTypography.bodyText1.copyWith(
                            color: Colors.white,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Loading indicator or start button - only rebuilds when loading state changes
                      Consumer(
                        builder: (context, ref, child) {
                          final isLoading = ref.watch(welcomeProvider
                              .select((state) => state.isLoading));

                          if (isLoading) {
                            return _buildLoadingProgressConsumer(ref);
                          } else {
                            return _buildStartButtonConsumer(
                                context, ref, notifier);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Pokeball decoration
              _buildPokeballDecoration(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppHeader() {
    return Column(
      children: [
        // Pokeball icon
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.catching_pokemon,
            size: 60,
            color: AppColors.pokemonRed,
          ),
        ),

        const SizedBox(height: 16),

        // App title
        Text(
          'Flutter Pokedex',
          style: AppTypography.headline4.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        // App subtitle
        Text(
          'Ensiklopedia Pokemon Lengkap',
          style: AppTypography.subtitle1.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingProgressConsumer(WidgetRef ref) {
    // Only watch loading-related state properties
    final loadingState = ref.watch(welcomeProvider.select((state) => {
          'loadingProgress': state.loadingProgress,
          'loadingStatusText': state.loadingStatusText,
          'loadingDetailText': state.loadingDetailText,
        }));

    final loadingProgress = loadingState['loadingProgress'] as double;
    final loadingStatusText = loadingState['loadingStatusText'] as String;
    final loadingDetailText = loadingState['loadingDetailText'] as String;

    return Column(
      children: [
        // Loading progress indicator
        Stack(
          alignment: Alignment.center,
          children: [
            // Circular progress indicator background
            SizedBox(
              height: 120,
              width: 120,
              child: CircularProgressIndicator(
                value: loadingProgress,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 8.0,
              ),
            ),

            // Progress percentage
            Text(
              '${(loadingProgress * 100).toInt()}%',
              style: AppTypography.headline5.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Loading status text
        Text(
          loadingStatusText,
          style: AppTypography.bodyText1.copyWith(
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        // Loading detail text
        Text(
          loadingDetailText,
          style: AppTypography.caption.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStartButtonConsumer(
      BuildContext context, WidgetRef ref, WelcomeNotifier notifier) {
    // Only watch button-related state properties
    final buttonState = ref.watch(welcomeProvider.select((state) => {
          'isInitialDataLoaded': state.isInitialDataLoaded,
          'lastUpdatedText': state.lastUpdatedText,
        }));

    final isInitialDataLoaded = buttonState['isInitialDataLoaded'] as bool;
    final lastUpdatedText = buttonState['lastUpdatedText'] as String;

    return Column(
      children: [
        // Main action buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (isInitialDataLoaded) {
                    // Navigate to home if we have data
                    Mahas.routeTo(AppRoutes.home);
                  } else {
                    // Otherwise, start loading process
                    notifier.startLoadingPokemonData();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.pokemonRed,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  isInitialDataLoaded
                      ? 'Mulai Menjelajah'
                      : 'Unduh Data Pokemon',
                  style: AppTypography.button.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),

        if (isInitialDataLoaded) ...[
          const SizedBox(height: 16),
          // Last updated info
          Text(
            'Terakhir diperbarui: $lastUpdatedText',
            style: AppTypography.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPokeballDecoration() {
    return Opacity(
      opacity: 0.1,
      child: Container(
        height: 200,
        width: 200,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/pokeball.png'),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
