import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'core/mahas/mahas_service.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/mahas.dart';
import 'presentation/routes/app_providers.dart';
import 'presentation/routes/app_routes_provider.dart';
import 'core/mahas/pages/log_viewer_page.dart';
import 'core/env/app_environment.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final environment = _determineEnvironment();

  // Inisialisasi semua service melalui MahasService
  await MahasService.init(environment: environment);

  // Periksa apakah data Pokemon sudah ada
  final String initialRoute = await MahasService.determineInitialRoute();

  runApp(
    MultiProvider(
      providers: AppProviders.getProviders(),
      child: MyApp(initialRoute: initialRoute),
    ),
  );
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
      themeMode: ThemeMode.light,
    );
  }
}
