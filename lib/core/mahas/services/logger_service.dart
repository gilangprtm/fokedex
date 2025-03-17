import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../../env/app_environment.dart';

/// Level log yang didukung
enum LogLevel {
  debug,
  info,
  warning,
  error,
  fatal,
}

/// Service untuk mengelola logging aplikasi
class LoggerService {
  // Singleton pattern
  static final LoggerService _instance = LoggerService._internal();
  static LoggerService get instance => _instance;
  LoggerService._internal();

  // Current log level, log dengan level di bawah ini tidak akan ditampilkan
  LogLevel _currentLogLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  // History logs untuk keperluan debugging
  final List<Map<String, dynamic>> _logHistory = [];

  // Maksimum ukuran history log
  int _maxLogHistorySize = 1000;

  // Flag untuk mengaktifkan/menonaktifkan logging detail
  bool _enableDetailedLogs = true;

  /// Inisialisasi logger berdasarkan environment
  void init() {
    final env = AppEnvironment.instance;

    // Set log level berdasarkan environment
    String logLevelStr = env.get<String>('logLevel');
    _currentLogLevel = _getLogLevelFromString(logLevelStr);

    // Set maksimum ukuran history log
    _maxLogHistorySize = env.get<int>('maxLogHistory');

    // Set flag detailed logging
    _enableDetailedLogs = env.get<bool>('enableDetailedLogs');

    // Log inisialisasi
    i('Logger initialized with level: $_currentLogLevel, max history: $_maxLogHistorySize, detailed logs: $_enableDetailedLogs',
        tag: 'LOGGER');
  }

  /// Mengkonversi string ke LogLevel
  LogLevel _getLogLevelFromString(String level) {
    switch (level.toLowerCase()) {
      case 'debug':
        return LogLevel.debug;
      case 'info':
        return LogLevel.info;
      case 'warning':
        return LogLevel.warning;
      case 'error':
        return LogLevel.error;
      case 'fatal':
        return LogLevel.fatal;
      default:
        return LogLevel.info;
    }
  }

  /// Mendapatkan history logs
  List<Map<String, dynamic>> get logHistory => _logHistory;

  /// Mengatur level log
  void setLogLevel(LogLevel level) {
    _currentLogLevel = level;
  }

  /// Log debug message
  void d(String message, {Object? data, String? tag, StackTrace? stackTrace}) {
    _log(LogLevel.debug, message, data: data, tag: tag, stackTrace: stackTrace);
  }

  /// Log info message
  void i(String message, {Object? data, String? tag, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, data: data, tag: tag, stackTrace: stackTrace);
  }

  /// Log warning message
  void w(String message, {Object? data, String? tag, StackTrace? stackTrace}) {
    _log(LogLevel.warning, message,
        data: data, tag: tag, stackTrace: stackTrace);
  }

  /// Log error message
  void e(String message, {Object? error, String? tag, StackTrace? stackTrace}) {
    _log(LogLevel.error, message,
        data: error, tag: tag, stackTrace: stackTrace);
  }

  /// Log fatal error message
  void f(String message, {Object? error, String? tag, StackTrace? stackTrace}) {
    _log(LogLevel.fatal, message,
        data: error, tag: tag, stackTrace: stackTrace);
  }

  /// Method internal untuk melakukan logging berdasarkan level
  void _log(
    LogLevel level,
    String message, {
    Object? data,
    String? tag,
    StackTrace? stackTrace,
  }) {
    // Skip jika level di bawah current level
    if (level.index < _currentLogLevel.index) {
      return;
    }

    final String logTag = tag ?? 'APP';
    final DateTime now = DateTime.now();
    final String formattedTime =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}.${now.millisecond.toString().padLeft(3, '0')}";

    // Emoji untuk masing-masing level
    final String emoji = _getEmojiForLevel(level);

    // Format pesan
    String logMessage = "$emoji [$formattedTime] [$logTag] $message";

    // Tambahkan data jika ada dan detailed logs diaktifkan
    String? dataString;
    if (data != null && _enableDetailedLogs) {
      try {
        if (data is Map || data is List) {
          dataString = const JsonEncoder.withIndent('  ').convert(data);
        } else if (data is String) {
          dataString = data;
        } else {
          dataString = data.toString();
        }

        logMessage += "\nData: $dataString";
      } catch (e) {
        logMessage += "\nData: $data (couldn't format)";
      }
    }

    // Tambahkan stack trace jika tersedia dan dalam mode development
    if (stackTrace != null && _enableDetailedLogs) {
      logMessage += "\nStackTrace: $stackTrace";
    }

    // Log ke console dalam mode debug
    if (kDebugMode) {
      // Gunakan warna berbeda untuk level berbeda
      developer.log(
        message,
        name: logTag,
        time: now,
        level: level.index * 100,
        error: data is Exception || data is Error ? data : null,
        stackTrace: stackTrace,
      );
    }

    // Simpan ke history jika bukan di production atau jika level error/fatal
    if (_enableDetailedLogs || level.index >= LogLevel.error.index) {
      final logEntry = {
        'level': level.toString().split('.').last,
        'message': message,
        'tag': logTag,
        'timestamp': now.toIso8601String(),
        if (data != null && _enableDetailedLogs)
          'data': dataString ?? data.toString(),
        if (stackTrace != null && _enableDetailedLogs)
          'stackTrace': stackTrace.toString(),
      };

      _logHistory.add(logEntry);

      // Batasi ukuran history log
      if (_logHistory.length > _maxLogHistorySize) {
        _logHistory.removeAt(0);
      }
    }
  }

  /// Mendapatkan emoji berdasarkan level log
  String _getEmojiForLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🐛';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
      case LogLevel.fatal:
        return '💥';
      default:
        return '📝';
    }
  }

  /// Membersihkan history log
  void clearHistory() {
    _logHistory.clear();
  }

  /// Ekspor log history ke string
  String exportLogs() {
    return const JsonEncoder.withIndent('  ').convert(_logHistory);
  }
}
