import 'dart:async';
import '../di/service_locator.dart';
import 'services/firebase_service.dart';
import 'services/storage_service.dart';
import 'services/logger_service.dart';
import 'services/error_handler_service.dart';
import '../env/app_environment.dart';

/// MahasService adalah kelas singleton yang mengelola inisialisasi aplikasi
/// seperti service locator, firebase, local storage, dll.
class MahasService {
  static final MahasService _instance = MahasService._internal();
  static MahasService get instance => _instance;

  // Private constructor
  MahasService._internal();

  /// Inisialisasi seluruh layanan yang dibutuhkan sebelum aplikasi dijalankan
  static Future<void> init(
      {Environment environment = Environment.development}) async {
    try {
      // Inisialisasi Environment terlebih dahulu
      AppEnvironment.instance.initEnvironment(environment);

      // Inisialisasi Logger terlebih dahulu untuk bisa mencatat progress inisialisasi lainnya
      final logger = LoggerService.instance;

      // Init logger dengan environment settings
      logger.init();

      logger.i(
          '🚀 Initializing application services in ${environment.toString()} mode...',
          tag: 'MAHAS');

      // Inisialisasi error handler
      await _initErrorHandler();

      // Inisialisasi service locator / dependency injection
      await _initServiceLocator();

      // Inisialisasi Firebase (jika diperlukan)
      // await _initFirebase();

      // Inisialisasi Local Storage (jika diperlukan)
      // await _initStorage();

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

  /// Inisialisasi error handler
  static Future<void> _initErrorHandler() async {
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

  /// Inisialisasi service locator
  static Future<void> _initServiceLocator() async {
    final logger = LoggerService.instance;

    await setupServiceLocator();

    logger.i('✅ Service Locator initialized successfully!', tag: 'MAHAS');
  }

  /// Inisialisasi Firebase (menggunakan FirebaseService yang terpisah)
  static Future<void> _initFirebase() async {
    final logger = LoggerService.instance;

    await FirebaseService.instance.init();

    logger.i('✅ Firebase initialized successfully!', tag: 'MAHAS');
  }

  /// Inisialisasi Storage (menggunakan StorageService yang terpisah)
  static Future<void> _initStorage() async {
    final logger = LoggerService.instance;

    await StorageService.instance.init();

    logger.i('✅ Storage initialized successfully!', tag: 'MAHAS');
  }
}
