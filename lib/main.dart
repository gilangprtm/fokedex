import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'core/mahas/mahas_service.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/mahas.dart';
import 'presentation/routes/app_providers.dart';
import 'presentation/routes/app_routes.dart';
import 'presentation/routes/app_routes_provider.dart';
import 'core/mahas/pages/log_viewer_page.dart';
import 'core/env/app_environment.dart';
import 'data/local/services/local_pokemon_service.dart';
import 'core/mahas/services/logger_service.dart';
import 'core/di/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final environment = _determineEnvironment();

  // Inisialisasi semua service melalui MahasService
  await MahasService.init(environment: environment);

  // Periksa apakah data Pokemon sudah ada
  final String initialRoute = await _determineInitialRoute();

  runApp(
    MultiProvider(
      providers: AppProviders.getProviders(),
      child: MyApp(initialRoute: initialRoute),
    ),
  );
}

/// Menentukan initial route berdasarkan keberadaan data lokal
Future<String> _determineInitialRoute() async {
  final _logger = serviceLocator<LoggerService>();

  try {
    // Inisialisasi LocalPokemonService
    final localService = LocalPokemonService();
    await localService.initialize();

    // Cek apakah data Pokemon sudah tersedia
    final hasData = await localService.hasPokemonList();
    if (hasData) {
      // Cek detail untuk memastikan data lengkap
      final detailCount = await localService.getPokemonDetailCount();
      if (detailCount > 0) {
        // Jika data sudah ada, langsung ke home page
        return AppRoutes.home;
      }
    }
  } catch (e) {
    _logger.e('Error checking local data: $e');
  }

  // Default ke welcome page jika data belum ada
  return AppRoutes.welcome;
}

/// Menentukan environment berdasarkan flag compile
Environment _determineEnvironment() {
  if (kDebugMode) {
    return Environment.development;
  } else if (kReleaseMode) {
    return Environment.production;
  } else {
    return Environment.staging;
  }
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    // Tambahkan log viewer hanya dalam mode development
    final appRoutes = AppRoutesProvider.getRoutes();

    // Tambahkan log viewer route hanya jika dalam mode development
    if (AppEnvironment.instance.isDevelopment) {
      appRoutes['/log-viewer'] = (context) => const LogViewerPage();
    }

    return MaterialApp(
      title: 'Fokedex',
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      routes: appRoutes,
      navigatorKey: Mahas.navigatorKey,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
    );
  }
}
