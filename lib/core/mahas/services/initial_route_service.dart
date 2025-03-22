import '../../../data/datasource/local/services/local_pokemon_service.dart';
import '../../di/service_locator.dart';
import 'logger_service.dart';
import '../../../presentation/routes/app_routes.dart';

/// Service to determine the initial route of the application based on data availability
class InitialRouteService {
  final LoggerService _logger = serviceLocator<LoggerService>();

  /// Singleton pattern
  static final InitialRouteService _instance = InitialRouteService._internal();
  factory InitialRouteService() => _instance;
  InitialRouteService._internal();

  /// Determines the initial route based on whether Pokemon data is available locally
  ///
  /// Returns the home route if data exists, otherwise the welcome route
  Future<String> determineInitialRoute() async {
    try {
      // Initialize LocalPokemonService
      final localService = LocalPokemonService();
      await localService.initialize();

      // Check if Pokemon data is already available
      final hasData = await localService.hasPokemonList();
      if (hasData) {
        // Check details to ensure data is complete
        final detailCount = await localService.getPokemonDetailCount();
        if (detailCount > 0) {
          // If data exists, go directly to home page
          return AppRoutes.home;
        }
      }
    } catch (e) {
      _logger.e('Error checking local data: $e');
    }

    // Default to welcome page if data doesn't exist
    return AppRoutes.welcome;
  }
}
