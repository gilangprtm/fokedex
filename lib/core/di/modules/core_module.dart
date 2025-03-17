import 'package:get_it/get_it.dart';
import '../../mahas/services/firebase_service.dart';
import '../../mahas/services/storage_service.dart';
import '../../mahas/services/logger_service.dart';
import '../../mahas/services/error_handler_service.dart';
import '../../mahas/services/performance_service.dart';

/// Mendaftarkan semua layanan inti aplikasi
Future<void> setupCoreModule(GetIt serviceLocator) async {
  // Logger dan Error Handler (tidak diregister sebagai lazy singleton
  // karena sudah diinisialisasi sebelum serviceLocator)
  serviceLocator.registerSingleton<LoggerService>(
    LoggerService.instance,
  );

  serviceLocator.registerSingleton<ErrorHandlerService>(
    ErrorHandlerService.instance,
  );

  // Register PerformanceService
  serviceLocator.registerSingleton<PerformanceService>(
    PerformanceService.instance,
  );

  // Core Services lainnya
  serviceLocator.registerLazySingleton<FirebaseService>(
    () => FirebaseService.instance,
  );

  serviceLocator.registerLazySingleton<StorageService>(
    () => StorageService.instance,
  );
}
