import 'package:flutter/foundation.dart';

/// Representasi environment aplikasi
enum Environment {
  development,
  staging,
  production,
}

/// Kelas untuk mengelola environment dan konfigurasi aplikasi
class AppEnvironment {
  // Singleton pattern
  static final AppEnvironment _instance = AppEnvironment._internal();
  static AppEnvironment get instance => _instance;
  AppEnvironment._internal();

  // Environment yang sedang aktif
  Environment _environment = Environment.development;

  // Variabel konfigurasi berdasarkan environment
  final Map<String, dynamic> _config = {};

  /// Mendapatkan environment aktif
  Environment get environment => _environment;

  /// Mengecek apakah dalam mode development
  bool get isDevelopment => _environment == Environment.development;

  /// Mengecek apakah dalam mode staging
  bool get isStaging => _environment == Environment.staging;

  /// Mengecek apakah dalam mode production
  bool get isProduction => _environment == Environment.production;

  /// Mengecek apakah dalam mode debug
  bool get isDebugMode => kDebugMode;

  /// Inisialisasi environment aplikasi
  void initEnvironment(Environment env) {
    _environment = env;
    _loadConfig();
  }

  /// Memuat konfigurasi berdasarkan environment
  void _loadConfig() {
    // Base PokeAPI URL for all environments
    const String pokeApiBaseUrl = 'https://pokeapi.co/api/v2';

    switch (_environment) {
      case Environment.development:
        _config.addAll({
          'apiUrl': pokeApiBaseUrl,
          'enableDetailedLogs': true,
          'logLevel': 'debug',
          'maxLogHistory': 1000,
          'pokemonLimit': 20, // Limit for pagination
          'cacheEnabled': true,
          'cacheDuration': const Duration(days: 7), // Cache data for 7 days
        });
        break;
      case Environment.staging:
        _config.addAll({
          'apiUrl': pokeApiBaseUrl,
          'enableDetailedLogs': true,
          'logLevel': 'info',
          'maxLogHistory': 500,
          'pokemonLimit': 20,
          'cacheEnabled': true,
          'cacheDuration': const Duration(days: 7),
        });
        break;
      case Environment.production:
        _config.addAll({
          'apiUrl': pokeApiBaseUrl,
          'enableDetailedLogs': false,
          'logLevel': 'error',
          'maxLogHistory': 100,
          'pokemonLimit': 20,
          'cacheEnabled': true,
          'cacheDuration':
              const Duration(days: 14), // Cache longer in production
        });
        break;
    }
  }

  /// Mendapatkan nilai konfigurasi berdasarkan key
  T get<T>(String key) {
    return _config[key] as T;
  }
}
