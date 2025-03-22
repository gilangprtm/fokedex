import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:math';
import '../../core/base/base_provider.dart';
import '../../core/utils/mahas.dart';
import '../../data/datasource/local/services/local_pokemon_service.dart';
import '../../data/datasource/models/api_response_model.dart';
import '../routes/app_routes.dart';

// Konstanta untuk key penyimpanan
const String kPokemonListKey = 'pokemon_list_updated';
const String kPokemonTypesKey = 'pokemon_types_updated';
const String kPokemonDetailKey = 'pokemon_detail_updated';

/// Status for the loading process
enum LoadingStatus {
  initial,
  loading,
  success,
  error,
}

/// Provider untuk mengelola state Welcome Page dan preloading data Pokemon
class WelcomeProvider extends BaseProvider {
  // Service dan repository
  final LocalPokemonService _localService = LocalPokemonService();

  // State untuk loading
  bool _isDataLoading = false;
  bool get isDataLoading => _isDataLoading;

  double _loadingProgress = 0.0;
  double get loadingProgress => _loadingProgress;

  String _loadingStatusText = 'Siap untuk mengunduh data Pokemon';
  String get loadingStatusText => _loadingStatusText;

  String _loadingDetailText =
      'Aplikasi membutuhkan data Pokemon untuk digunakan secara offline';
  String get loadingDetailText => _loadingDetailText;

  DateTime? _lastUpdated;
  String get lastUpdatedText {
    if (_lastUpdated == null) return 'Belum pernah';

    final formatter = DateFormat('dd MMM yyyy, HH:mm');
    return formatter.format(_lastUpdated!);
  }

  int _percentComplete = 0;
  int get percentComplete => _percentComplete;

  bool _isInitialDataLoaded = false;
  bool get isInitialDataLoaded => _isInitialDataLoaded;

  // Total stages for loading
  final int _totalLoadingStages = 5;

  LoadingStatus _loadingStatus = LoadingStatus.initial;
  LoadingStatus get loadingStatus => _loadingStatus;

  @override
  void onInit() {
    super.onInit();
    _checkExistingData();
  }

  /// Cek apakah data Pokemon sudah ada di penyimpanan lokal
  Future<void> _checkExistingData() async {
    try {
      if (await _localService.hasPokemonList()) {
        bool needsListUpdate = await _localService.needsUpdate(kPokemonListKey);
        bool needsTypesUpdate =
            await _localService.needsUpdate(kPokemonTypesKey);
        bool needsDetailUpdate =
            await _localService.needsUpdate(kPokemonDetailKey);

        if (!needsListUpdate && !needsTypesUpdate && !needsDetailUpdate) {
          _loadingStatus = LoadingStatus.success;
          _isDataLoading = false;
          _isInitialDataLoaded = true;
          _lastUpdated = DateTime.now();
          notifyListeners();
          return;
        }
      }
      _isInitialDataLoaded = false;
    } catch (e) {
      _isInitialDataLoaded = false;
    }
    notifyListeners();
  }

  /// Mulai proses loading data Pokemon
  Future<void> startLoadingPokemonData() async {
    if (_isDataLoading) return;

    await runAsync('startLoadingPokemonData', () async {
      _isDataLoading = true;
      _loadingProgress = 0.0;

      try {
        // Tahap 1: Inisialisasi
        _updateLoadingState(
          stage: 1,
          statusText: 'Mempersiapkan pengunduhan...',
          detailText: 'Menginisialisasi layanan untuk mengunduh data Pokemon',
        );

        // Pastikan local service sudah diinisialisasi
        await _localService.initialize();

        // Pastikan perubahan tahap 1 selesai
        _loadingProgress = 1 / _totalLoadingStages;
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 200));

        // Tahap 2: Mengambil daftar Pokemon langsung dari API
        _updateLoadingState(
          stage: 2,
          statusText: 'Mengunduh daftar Pokemon...',
          detailText:
              'Mendapatkan informasi dasar untuk semua Pokemon dari API',
        );

        List<ResourceListItem> allPokemonList = [];
        try {
          // Gunakan LocalPokemonService untuk download dan simpan ke local storage
          allPokemonList = await _localService.downloadAndSavePokemonList(
            limit: 2000,
          );
        } catch (e) {
          // Coba ambil dari lokal jika gagal dari API
          allPokemonList = await _localService.getPokemonList();
          if (allPokemonList.isEmpty) {
            _updateLoadingState(
              stage: 2,
              statusText: 'Gagal mengunduh daftar Pokemon',
              detailText: 'Terjadi kesalahan dan tidak ada data lokal tersedia',
            );
            throw Exception(
                'Tidak dapat mengunduh atau membaca daftar Pokemon');
          }
        }

        // Pastikan perubahan tahap 2 selesai
        _loadingProgress = 2 / _totalLoadingStages;
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 200));

        // Tahap 3: Mengambil daftar tipe Pokemon dari API
        _updateLoadingState(
          stage: 3,
          statusText: 'Mengunduh tipe Pokemon...',
          detailText: 'Mendapatkan informasi tentang semua tipe Pokemon',
        );

        List<ResourceListItem> allPokemonTypes = [];
        try {
          // Gunakan LocalPokemonService untuk download dan simpan ke local storage
          allPokemonTypes = await _localService.downloadAndSavePokemonTypes();
        } catch (e) {
          // Coba ambil dari lokal jika gagal dari API
          allPokemonTypes = await _localService.getPokemonTypes();
          if (allPokemonTypes.isEmpty) {
            _updateLoadingState(
              stage: 3,
              statusText: 'Gagal mengunduh tipe Pokemon',
              detailText: 'Melanjutkan dengan fungsionalitas terbatas',
            );
          }
        }

        // Pastikan perubahan tahap 3 selesai
        _loadingProgress = 3 / _totalLoadingStages;
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 200));

        // Tahap 4: Mengambil detail Pokemon (semua data)

        try {
          // Ambil semua Pokemon dan download detailnya
          // Batasi jumlah yang diunduh sesuai kebutuhan aplikasi (misal: 300 Pokemon pertama)
          final pokemonToDownload = allPokemonList;
          final totalPokemon = pokemonToDownload.length;
          int downloadedCount = 0;

          _updateLoadingState(
            stage: 3,
            statusText: 'Mengunduh detail Pokemon ...',
            detailText: 'Mengunduh $totalPokemon Pokemon',
          );

          // Batch download untuk kinerja yang lebih baik
          const batchSize = 20;
          for (int i = 0; i < pokemonToDownload.length; i += batchSize) {
            final endIdx =
                (i + batchSize < totalPokemon) ? i + batchSize : totalPokemon;
            final batch = pokemonToDownload.sublist(i, endIdx);

// Update status loading untuk menunjukkan progress
            _percentComplete = (downloadedCount / totalPokemon * 100).toInt();

            // Download batch secara paralel
            final futures = batch
                .map((pokemon) =>
                    _localService.downloadAndSavePokemonDetail(pokemon.id))
                .toList();

            final results = await Future.wait(futures);

            // Count successful downloads
            final successCount =
                results.where((result) => result == true).length;
            debugPrint(
                'Batch ${i ~/ batchSize + 1}: Downloaded $successCount/${batch.length} Pokemon details successfully');

            // Update counter dan berikan waktu untuk UI refresh
            downloadedCount += batch.length;

            // Update progress
            final progress = 3 + (downloadedCount / totalPokemon);
            _loadingProgress = progress / _totalLoadingStages;
            notifyListeners();

            // Berikan sedikit waktu untuk UI refresh
            await Future.delayed(const Duration(milliseconds: 50));
          }
        } catch (e) {
          _updateLoadingState(
            stage: 4,
            statusText: 'Melanjutkan dengan data dasar...',
            detailText:
                'Beberapa detail Pokemon mungkin belum tersedia. Detail akan diunduh saat dibutuhkan.',
          );
        }

        // Pastikan perubahan tahap 4 selesai
        _loadingProgress = 4 / _totalLoadingStages;
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 200));

        // Tahap 5: Pastikan semua data sudah tersimpan
        _updateLoadingState(
          stage: 5,
          statusText: 'Verifikasi penyimpanan data...',
          detailText: 'Memastikan semua data tersimpan dengan benar',
        );

        try {
          // Verifikasi data tersimpan
          await _localService.getPokemonCount();
          await _localService.getPokemonTypes();
          await _localService.getPokemonDetailCount();
        } catch (e) {
          _updateLoadingState(
            stage: 5,
            statusText: 'Terjadi masalah saat verifikasi',
            detailText:
                'Beberapa data mungkin tidak tersimpan dengan benar: ${e.toString().substring(0, min(100, e.toString().length))}',
          );
        }

        // Selesai
        _isDataLoading = false;
        _isInitialDataLoaded = true;
        _lastUpdated = DateTime.now();

        _loadingProgress = 1.0;
        _loadingStatusText = 'Pengunduhan data selesai!';
        _loadingDetailText =
            'Anda sekarang dapat menjelajahi Pokedex secara offline';
        notifyListeners();

        // Wait a bit to show 100% completion
        await Future.delayed(const Duration(seconds: 1));

        // Navigate to home page after data is loaded
        Mahas.routeToAndRemove(AppRoutes.home);
      } on TimeoutException {
        _isDataLoading = false;
        _loadingStatusText = 'Koneksi timeout';
        _loadingDetailText =
            'Server tidak merespon. Cek koneksi internet Anda dan coba lagi.';
        notifyListeners();
      } catch (e) {
        _isDataLoading = false;
        _loadingStatusText = 'Terjadi kesalahan saat mengunduh data';

        // Check if it's a connection error
        if (e.toString().contains('connection') ||
            e.toString().contains('timeout') ||
            e.toString().contains('network')) {
          _loadingDetailText =
              'Koneksi internet terputus atau server tidak dapat dijangkau. Periksa koneksi internet Anda dan coba lagi.';
        } else {
          _loadingDetailText =
              'Silakan coba lagi nanti. Error: ${e.toString().substring(0, min(100, e.toString().length))}';
        }

        notifyListeners();
      }
    });
  }

  /// Update state loading
  void _updateLoadingState({
    required int stage,
    required String statusText,
    required String detailText,
  }) {
    _loadingProgress = stage / _totalLoadingStages;
    _loadingStatusText = statusText;
    _loadingDetailText = detailText;

    notifyListeners();
  }
}
