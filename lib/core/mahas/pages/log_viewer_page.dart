import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/logger_service.dart';

/// Halaman untuk melihat dan menganalisis log aplikasi
class LogViewerPage extends StatefulWidget {
  const LogViewerPage({super.key});

  @override
  State<LogViewerPage> createState() => _LogViewerPageState();
}

class _LogViewerPageState extends State<LogViewerPage> {
  final LoggerService _logger = LoggerService.instance;

  // State variables
  String _filterQuery = '';
  LogLevel? _selectedLevel;
  List<Map<String, dynamic>> _filteredLogs = [];

  @override
  void initState() {
    super.initState();
    _applyFilters();
  }

  /// Filter log berdasarkan query dan level
  void _applyFilters() {
    final logs = _logger.logHistory;
    setState(() {
      _filteredLogs = logs.where((log) {
        // Filter by level
        if (_selectedLevel != null) {
          final logLevel = log['level'] as String;
          final targetLevel = _selectedLevel.toString().split('.').last;
          if (logLevel != targetLevel) {
            return false;
          }
        }

        // Filter by query
        if (_filterQuery.isNotEmpty) {
          final message = log['message'] as String;
          final tag = log['tag'] as String;
          return message.toLowerCase().contains(_filterQuery.toLowerCase()) ||
              tag.toLowerCase().contains(_filterQuery.toLowerCase());
        }

        return true;
      }).toList();
    });
  }

  /// Mendapatkan warna untuk log level
  Color _getColorForLevel(String level) {
    switch (level) {
      case 'debug':
        return Colors.grey.shade700;
      case 'info':
        return Colors.blue.shade700;
      case 'warning':
        return Colors.orange.shade700;
      case 'error':
        return Colors.red.shade700;
      case 'fatal':
        return Colors.purple.shade700;
      default:
        return Colors.black87;
    }
  }

  /// Menyalin log ke clipboard
  Future<void> _copyLogs() async {
    final jsonString = const JsonEncoder.withIndent('  ')
        .convert(_filteredLogs.isEmpty ? _logger.logHistory : _filteredLogs);

    await Clipboard.setData(ClipboardData(text: jsonString));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logs copied to clipboard'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Membersihkan semua log
  void _clearLogs() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Logs'),
        content: const Text('Are you sure you want to clear all logs?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _logger.clearHistory();
              Navigator.of(context).pop();
              _applyFilters();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Viewer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy Logs',
            onPressed: _copyLogs,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear Logs',
            onPressed: _clearLogs,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Filter logs...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    onChanged: (value) {
                      _filterQuery = value;
                      _applyFilters();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<LogLevel?>(
                  value: _selectedLevel,
                  hint: const Text('Level'),
                  items: [
                    const DropdownMenuItem<LogLevel?>(
                      value: null,
                      child: Text('All'),
                    ),
                    ...LogLevel.values.map((level) {
                      return DropdownMenuItem<LogLevel?>(
                        value: level,
                        child: Text(level.toString().split('.').last),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedLevel = value;
                      _applyFilters();
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredLogs.isEmpty
                ? const Center(
                    child: Text('No logs to display'),
                  )
                : ListView.builder(
                    itemCount: _filteredLogs.length,
                    itemBuilder: (context, index) {
                      // Reversed order for newest logs on top
                      final log =
                          _filteredLogs[_filteredLogs.length - 1 - index];
                      final level = log['level'] as String;
                      final message = log['message'] as String;
                      final tag = log['tag'] as String;
                      final timestamp = log['timestamp'] as String;
                      final hasData = log.containsKey('data');
                      final hasStackTrace = log.containsKey('stackTrace');

                      // Format time for display
                      final dateTime = DateTime.parse(timestamp);
                      final formattedTime =
                          '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: ExpansionTile(
                          leading: Container(
                            width: 8,
                            height: double.infinity,
                            color: _getColorForLevel(level),
                          ),
                          title: Text(
                            message,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getColorForLevel(level),
                            ),
                          ),
                          subtitle: Text('$tag - $formattedTime'),
                          children: [
                            if (hasData)
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Data:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        log['data'] as String,
                                        style: const TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (hasStackTrace)
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Stack Trace:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      constraints:
                                          const BoxConstraints(maxHeight: 300),
                                      child: SingleChildScrollView(
                                        child: Text(
                                          log['stackTrace'] as String,
                                          style: const TextStyle(
                                            fontFamily: 'monospace',
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
