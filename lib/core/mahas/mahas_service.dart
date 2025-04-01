import 'dart:async';
import 'services/firebase_service.dart';
import 'services/storage_service.dart';
import 'services/logger_service.dart';
import 'services/error_handler_service.dart';
import 'services/initial_route_service.dart';

/// MahasService adalah kelas singleton yang mengelola inisialisasi aplikasi
/// seperti firebase, local storage, dll.
class MahasService {
  static final MahasService _instance = MahasService._internal();
  static MahasService get instance => _instance;

  // Private constructor
  MahasService._internal();

  /// Inisialisasi seluruh layanan yang dibutuhkan sebelum aplikasi dijalankan
  static Future<void> init() async {
    try {
      // Inisialisasi Logger terlebih dahulu untuk bisa mencatat progress inisialisasi lainnya
      final logger = LoggerService.instance;

      // Inisialisasi error handler
      await initErrorHandler();

      // Inisialisasi Firebase (jika diperlukan)
      //await initFirebase();

      // Inisialisasi Local Storage (jika diperlukan)
      //await initStorage();

      logger.i('✅ All services initialized successfully!', tag: 'MAHAS');
    } catch (e, stackTrace) {
      LoggerService.instance.e(
        '❌ Error initializing application services',
        error: e,
        stackTrace: stackTrace,
        tag: 'MAHAS',
      );
      rethrow;
    }
  }

  /// Determine the initial route based on application state
  static Future<String> determineInitialRoute() async {
    try {
      // Use the InitialRouteService to determine the initial route
      final initialRouteService = InitialRouteService();
      return await initialRouteService.determineInitialRoute();
    } catch (e, stackTrace) {
      LoggerService.instance.e(
        '❌ Error determining initial route',
        error: e,
        stackTrace: stackTrace,
        tag: 'MAHAS',
      );
      // Return the welcome route as fallback
      return '/welcome';
    }
  }

  /// Inisialisasi error handler
  static Future<void> initErrorHandler() async {
    final logger = LoggerService.instance;
    final errorHandler = ErrorHandlerService.instance;

    // Contoh implementasi, bisa diganti dengan layanan pelaporan error seperti Firebase Crashlytics
    errorHandler.setErrorReportFunction((error, stackTrace) async {
      // Log error untuk keperluan debugging
      logger.e(
        'Error reported to error service',
        error: error,
        stackTrace: stackTrace,
        tag: 'ERROR_REPORTING',
      );

      // Di sini bisa tambahkan implementasi untuk report ke layanan lain
      // Misalnya Firebase Crashlytics, Sentry, dll
      return;
    });

    // Initialize global error catching
    errorHandler.init();

    logger.i('✅ Error Handler initialized successfully!', tag: 'MAHAS');
  }

  /// Inisialisasi Firebase (menggunakan FirebaseService yang terpisah)
  static Future<void> initFirebase() async {
    final logger = LoggerService.instance;

    await FirebaseService.instance.init();

    logger.i('✅ Firebase initialized successfully!', tag: 'MAHAS');
  }

  /// Inisialisasi Storage (menggunakan StorageService yang terpisah)
  static Future<void> initStorage() async {
    final logger = LoggerService.instance;

    await StorageService.instance.init();

    logger.i('✅ Storage initialized successfully!', tag: 'MAHAS');
  }
}
