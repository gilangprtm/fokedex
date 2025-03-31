// lib/core/di/core_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../mahas/services/logger_service.dart';
import '../mahas/services/error_handler_service.dart';
import '../mahas/services/performance_service.dart';
import '../mahas/services/initial_route_service.dart';
import '../mahas/services/firebase_service.dart';
import '../mahas/services/storage_service.dart';

// Logger dan Error Handler (singleton)
final loggerServiceProvider = Provider<LoggerService>((ref) {
  return LoggerService.instance;
});

final errorHandlerServiceProvider = Provider<ErrorHandlerService>((ref) {
  return ErrorHandlerService.instance;
});

// Performance Service (singleton)
final performanceServiceProvider = Provider<PerformanceService>((ref) {
  return PerformanceService.instance;
});

// Initial Route Service (singleton)
final initialRouteServiceProvider = Provider<InitialRouteService>((ref) {
  return InitialRouteService();
});

// Firebase Service (lazy singleton)
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService.instance;
});

// Storage Service (lazy singleton)
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService.instance;
});
