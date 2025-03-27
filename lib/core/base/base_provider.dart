import 'package:flutter/material.dart';
import '../../core/mahas/services/logger_service.dart';
import '../../core/mahas/services/error_handler_service.dart';
import '../../core/di/service_locator.dart';

/// A base class for all providers in the application that extends [ChangeNotifier].
///
/// This class provides lifecycle methods that are called from [BaseWidget] during
/// widget lifecycle events. It also provides access to the [BuildContext] from the widget.
abstract class BaseProvider extends ChangeNotifier {
  BuildContext? _context;

  // PropertyListeners for granular notification
  final Map<String, List<VoidCallback>> _propertyListeners = {};

  // Track changed properties to batch notifications
  final Set<String> _changedProperties = {};

  // Flag to track if we're in a batch update
  bool _isBatchUpdate = false;

  // Core services made available to all providers
  final LoggerService _logger = serviceLocator<LoggerService>();
  final ErrorHandlerService _errorHandler =
      serviceLocator<ErrorHandlerService>();

  // Expose services to subclasses
  LoggerService get logger => _logger;
  ErrorHandlerService get errorHandler => _errorHandler;

  /// Returns the current [BuildContext] associated with this provider.
  BuildContext? get context => _context;

  /// Gets the tag for logging, uses the class name by default.
  /// Subclasses can override this to provide a custom tag.
  String get logTag => runtimeType.toString();

  /// Sets the [BuildContext] associated with this provider.
  ///
  /// This is called by [BaseWidget] during initialization to provide
  /// context-aware operations in the provider.
  void setContext(BuildContext context) {
    _context = context;
  }

  /// Called when the provider is first created.
  ///
  /// Use this method to initialize state or setup listeners.
  /// This is called by [BaseWidget] during [initState].
  void onInit() {
    _logger.i('onInit called', tag: logTag);
    // To be overridden by subclasses
  }

  /// Called after [onInit] and when the widget is ready.
  ///
  /// Use this method to perform tasks that should happen after the UI is built,
  /// such as fetching initial data.
  void onReady() {
    _logger.i('onReady called', tag: logTag);
    // To be overridden by subclasses
  }

  /// Called when the provider is about to be disposed.
  ///
  /// Use this method to clean up resources such as listeners or subscriptions.
  /// This is called by [BaseWidget] during [dispose].
  @override
  void dispose() {
    _propertyListeners.clear();
    onClose();
    super.dispose();
  }

  /// Called before [dispose] to allow cleanup.
  ///
  /// This method is separated from [dispose] to allow subclasses to perform
  /// custom cleanup without needing to call super.dispose().
  void onClose() {
    _logger.i('onClose called - cleaning up resources', tag: logTag);
    // To be overridden by subclasses
  }

  /// Add a listener for a specific property
  ///
  /// Use this to listen to changes for a specific property only
  void addPropertyListener(String property, VoidCallback listener) {
    if (!_propertyListeners.containsKey(property)) {
      _propertyListeners[property] = [];
    }
    _propertyListeners[property]!.add(listener);
  }

  /// Remove a listener for a specific property
  void removePropertyListener(String property, VoidCallback listener) {
    if (_propertyListeners.containsKey(property)) {
      _propertyListeners[property]!.remove(listener);
      if (_propertyListeners[property]!.isEmpty) {
        _propertyListeners.remove(property);
      }
    }
  }

  /// Notify listeners for a specific property
  ///
  /// This will only notify listeners for the specific property, not all listeners
  void notifyPropertyListeners(String property) {
    _logger.d('Notifying listeners for property: $property', tag: logTag);

    if (_isBatchUpdate) {
      _changedProperties.add(property);
      return;
    }

    if (_propertyListeners.containsKey(property)) {
      final listeners = List<VoidCallback>.from(_propertyListeners[property]!);
      for (final listener in listeners) {
        try {
          listener();
        } catch (e, stackTrace) {
          _logger.e(
            'Error in property listener for $property',
            error: e,
            stackTrace: stackTrace,
            tag: logTag,
          );
        }
      }
    }

    // Also notify global listeners
    notifyListeners();
  }

  /// Start a batch update - changes will be accumulated and notified once endBatch is called
  ///
  /// This helps reduce unnecessary rebuilds when multiple properties change
  void beginBatch() {
    _isBatchUpdate = true;
    _changedProperties.clear();
  }

  /// End a batch update and notify all listeners for changed properties
  void endBatch() {
    _isBatchUpdate = false;

    if (_changedProperties.isEmpty) return;

    // Notify individual property listeners
    for (final property in _changedProperties) {
      if (_propertyListeners.containsKey(property)) {
        final listeners =
            List<VoidCallback>.from(_propertyListeners[property]!);
        for (final listener in listeners) {
          try {
            listener();
          } catch (e, stackTrace) {
            _logger.e(
              'Error in property listener for $property during batch update',
              error: e,
              stackTrace: stackTrace,
              tag: logTag,
            );
          }
        }
      }
    }

    // Notify global listeners only once
    notifyListeners();

    _changedProperties.clear();
  }

  /// Helper method for handling synchronous operations with error handling and property-specific notification
  /// Usage: run('updateCount', () { _count++; }, properties: ['count']);
  void run(
    String operationName,
    void Function() action, {
    List<String>? properties,
  }) {
    _logger.d('Starting operation: $operationName', tag: logTag);

    try {
      if (properties != null && properties.length > 1) {
        beginBatch();
      }

      action();

      _logger.d('Completed operation: $operationName', tag: logTag);
    } catch (e, stackTrace) {
      _logger.e(
        'Error in $operationName',
        error: e,
        stackTrace: stackTrace,
        tag: logTag,
      );

      if (context != null) {
        _errorHandler.handleAsyncError(e, stackTrace, context);
      }
      rethrow;
    } finally {
      if (properties != null) {
        if (properties.length > 1) {
          endBatch();
        } else if (properties.length == 1) {
          notifyPropertyListeners(properties.first);
        }
      } else {
        notifyListeners();
      }
    }
  }

  /// Helper method for handling synchronous operations with return value and error handling
  /// Usage: final result = runWithResult('calculateValue', () => _value * 2, properties: ['value']);
  T runWithResult<T>(
    String operationName,
    T Function() action, {
    List<String>? properties,
  }) {
    _logger.d('Starting operation: $operationName', tag: logTag);

    try {
      if (properties != null && properties.length > 1) {
        beginBatch();
      }

      final result = action();

      _logger.d('Completed operation: $operationName', tag: logTag);
      return result;
    } catch (e, stackTrace) {
      _logger.e(
        'Error in $operationName',
        error: e,
        stackTrace: stackTrace,
        tag: logTag,
      );

      if (context != null) {
        _errorHandler.handleAsyncError(e, stackTrace, context);
      }
      rethrow;
    } finally {
      if (properties != null) {
        if (properties.length > 1) {
          endBatch();
        } else if (properties.length == 1) {
          notifyPropertyListeners(properties.first);
        }
      } else {
        notifyListeners();
      }
    }
  }

  /// Helper method for handling asynchronous operations with error handling
  /// Usage: await runAsync('fetchData', () async { _data = await api.getData(); }, properties: ['data']);
  Future<void> runAsync(
    String operationName,
    Future<void> Function() action, {
    List<String>? properties,
  }) async {
    _logger.d('Starting async operation: $operationName', tag: logTag);

    try {
      if (properties != null && properties.length > 1) {
        beginBatch();
      }

      await action();

      _logger.d('Completed async operation: $operationName', tag: logTag);
    } catch (e, stackTrace) {
      _logger.e(
        'Error in async $operationName',
        error: e,
        stackTrace: stackTrace,
        tag: logTag,
      );

      if (context != null) {
        await _errorHandler.handleAsyncError(e, stackTrace, context);
      }
      rethrow;
    } finally {
      if (properties != null) {
        if (properties.length > 1) {
          endBatch();
        } else if (properties.length == 1) {
          notifyPropertyListeners(properties.first);
        }
      } else {
        notifyListeners();
      }
    }
  }

  /// Helper method for handling asynchronous operations with return value and error handling
  /// Usage: final data = await runAsyncWithResult('fetchData', () => api.getData(), properties: ['data']);
  Future<T> runAsyncWithResult<T>(
    String operationName,
    Future<T> Function() action, {
    List<String>? properties,
  }) async {
    _logger.d('Starting async operation: $operationName', tag: logTag);

    try {
      if (properties != null && properties.length > 1) {
        beginBatch();
      }

      final result = await action();

      _logger.d('Completed async operation: $operationName', tag: logTag);
      return result;
    } catch (e, stackTrace) {
      _logger.e(
        'Error in async $operationName',
        error: e,
        stackTrace: stackTrace,
        tag: logTag,
      );

      if (context != null) {
        await _errorHandler.handleAsyncError(e, stackTrace, context);
      }
      rethrow;
    } finally {
      if (properties != null) {
        if (properties.length > 1) {
          endBatch();
        } else if (properties.length == 1) {
          notifyPropertyListeners(properties.first);
        }
      } else {
        notifyListeners();
      }
    }
  }

  // Menjaga kompatibilitas dengan kode lama
  @Deprecated('Gunakan run() atau runWithResult() sebagai gantinya')
  T function<T>(T Function() action, {String? operationName}) {
    return runWithResult(operationName ?? 'operation', action);
  }

  @Deprecated('Gunakan runAsync() atau runAsyncWithResult() sebagai gantinya')
  Future<T> functionAsync<T>(Future<T> Function() action,
      {String? operationName}) async {
    return await runAsyncWithResult(operationName ?? 'operation', action);
  }
}
