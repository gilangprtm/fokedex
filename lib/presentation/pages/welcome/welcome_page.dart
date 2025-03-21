import 'package:flutter/material.dart';
import '../../../core/base/provider_widget.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/theme/app_typografi.dart';
import '../../../core/utils/mahas.dart';
import '../../../presentation/routes/app_routes.dart';
import '../../providers/welcome_provider.dart';
import 'package:flutter/foundation.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderPage<WelcomeProvider>(
      createProvider: () => WelcomeProvider(),
      builder: (context, provider) => _buildWelcomePage(context, provider),
    );
  }

  Widget _buildWelcomePage(BuildContext context, WelcomeProvider provider) {
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

                      // Loading indicator and status
                      if (provider.isDataLoading) ...[
                        _buildLoadingProgress(provider),
                      ] else ...[
                        _buildStartButton(context, provider),
                      ],
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
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
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
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingProgress(WelcomeProvider provider) {
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
                value: provider.loadingProgress,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 8.0,
              ),
            ),

            // Progress percentage
            Text(
              '${(provider.loadingProgress * 100).toInt()}%',
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
          provider.loadingStatusText,
          style: AppTypography.bodyText1.copyWith(
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        // Loading detail text
        Text(
          provider.loadingDetailText,
          style: AppTypography.caption.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStartButton(BuildContext context, WelcomeProvider provider) {
    return Column(
      children: [
        // Main action buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (provider.isInitialDataLoaded) {
                    // Navigate to home if we have data
                    Mahas.routeTo(AppRoutes.home);
                  } else {
                    // Otherwise, start loading process
                    provider.startLoadingPokemonData();
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
                  provider.isInitialDataLoaded
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

        if (provider.isInitialDataLoaded) ...[
          const SizedBox(height: 16),
          // Last updated info
          Text(
            'Terakhir diperbarui: ${provider.lastUpdatedText}',
            style: AppTypography.caption.copyWith(
              color: Colors.white.withOpacity(0.8),
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
