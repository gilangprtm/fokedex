import 'package:intl/intl.dart';
import '../../../core/base/base_state_notifier.dart';

/// Status for the loading process
enum LoadingStatus {
  initial,
  loading,
  success,
  error,
}

/// State class for the Welcome Screen
class WelcomeState extends BaseState {
  final bool isInitialDataLoaded;
  final double loadingProgress;
  final String loadingStatusText;
  final String loadingDetailText;
  final DateTime? lastUpdated;
  final int percentComplete;
  final LoadingStatus loadingStatus;

  const WelcomeState({
    super.isLoading = false,
    super.error,
    super.stackTrace,
    this.isInitialDataLoaded = false,
    this.loadingProgress = 0.0,
    this.loadingStatusText = 'Siap untuk mengunduh data Pokemon',
    this.loadingDetailText =
        'Aplikasi membutuhkan data Pokemon untuk digunakan secara offline',
    this.lastUpdated,
    this.percentComplete = 0,
    this.loadingStatus = LoadingStatus.initial,
  });

  /// Get a formatted string of the last updated time
  String get lastUpdatedText {
    if (lastUpdated == null) return 'Belum pernah';

    final formatter = DateFormat('dd MMM yyyy, HH:mm');
    return formatter.format(lastUpdated!);
  }

  @override
  WelcomeState copyWith({
    bool? isLoading,
    Object? error,
    StackTrace? stackTrace,
    bool clearError = false,
    bool? isInitialDataLoaded,
    double? loadingProgress,
    String? loadingStatusText,
    String? loadingDetailText,
    DateTime? lastUpdated,
    int? percentComplete,
    LoadingStatus? loadingStatus,
  }) {
    return WelcomeState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      stackTrace: clearError ? null : stackTrace ?? this.stackTrace,
      isInitialDataLoaded: isInitialDataLoaded ?? this.isInitialDataLoaded,
      loadingProgress: loadingProgress ?? this.loadingProgress,
      loadingStatusText: loadingStatusText ?? this.loadingStatusText,
      loadingDetailText: loadingDetailText ?? this.loadingDetailText,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      percentComplete: percentComplete ?? this.percentComplete,
      loadingStatus: loadingStatus ?? this.loadingStatus,
    );
  }
}
