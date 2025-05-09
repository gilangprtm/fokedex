import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/mahas/mahas_service.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/mahas.dart';
import 'presentation/routes/app_routes_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi semua service melalui MahasService
  await MahasService.init();

  // Periksa apakah data Pokemon sudah ada
  final String initialRoute = await MahasService.determineInitialRoute();

  runApp(
    ProviderScope(
      child: MyApp(initialRoute: initialRoute),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    // Tambahkan log viewer hanya dalam mode development
    final appRoutes = AppRoutesProvider.getRoutes();

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
