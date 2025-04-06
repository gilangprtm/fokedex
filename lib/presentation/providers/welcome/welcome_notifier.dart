import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:math';
import '../../../core/base/base_state_notifier.dart';
import '../../../data/datasource/local/services/local_pokemon_service.dart';
import '../../../data/models/api_response_model.dart';
import './welcome_state.dart';
import 'welcome_provider.dart';

/// StateNotifier untuk mengelola state Welcome Page dan preloading data Pokemon
class WelcomeNotifier extends BaseStateNotifier<WelcomeState> {
  // Service dan repository
  final LocalPokemonService _localService;

  // Total stages for loading
  final int _totalLoadingStages = 5;

  WelcomeNotifier(
    super.initialState,
    super.ref,
    this._localService,
  );

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
          state = state.copyWith(
            loadingStatus: LoadingStatus.success,
            isLoading: false,
            isInitialDataLoaded: true,
            lastUpdated: DateTime.now(),
          );
          return;
        }
      }
      state = state.copyWith(isInitialDataLoaded: false);
    } catch (e) {
      state = state.copyWith(isInitialDataLoaded: false);
    }
  }

  /// Mulai proses loading data Pokemon
  Future<void> startLoadingPokemonData() async {
    if (state.isLoading) return;

    await runAsync('startLoadingPokemonData', () async {
      // Mark as loading
      state = state.copyWith(isLoading: true, loadingProgress: 0.0);

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
        state = state.copyWith(loadingProgress: 1 / _totalLoadingStages);
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
        state = state.copyWith(loadingProgress: 2 / _totalLoadingStages);
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
        state = state.copyWith(loadingProgress: 3 / _totalLoadingStages);
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
            state = state.copyWith(
              percentComplete: (downloadedCount / totalPokemon * 100).toInt(),
            );

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
            state =
                state.copyWith(loadingProgress: progress / _totalLoadingStages);

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
        state = state.copyWith(loadingProgress: 4 / _totalLoadingStages);
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
        state = state.copyWith(
          isLoading: false,
          isInitialDataLoaded: true,
          lastUpdated: DateTime.now(),
          loadingProgress: 1.0,
          loadingStatusText: 'Pengunduhan data selesai!',
          loadingDetailText:
              'Anda sekarang dapat menjelajahi Pokedex secara offline',
        );

        // Wait a bit to show 100% completion
        await Future.delayed(const Duration(seconds: 1));
      } on TimeoutException {
        state = state.copyWith(
          isLoading: false,
          loadingStatusText: 'Koneksi timeout',
          loadingDetailText:
              'Server tidak merespon. Cek koneksi internet Anda dan coba lagi.',
        );
      } catch (e) {
        final detailText = e.toString().contains('connection') ||
                e.toString().contains('timeout') ||
                e.toString().contains('network')
            ? 'Koneksi internet terputus atau server tidak dapat dijangkau. Periksa koneksi internet Anda dan coba lagi.'
            : 'Silakan coba lagi nanti. Error: ${e.toString().substring(0, min(100, e.toString().length))}';

        state = state.copyWith(
          isLoading: false,
          loadingStatusText: 'Terjadi kesalahan saat mengunduh data',
          loadingDetailText: detailText,
        );
      }
    });
  }

  /// Update state loading
  void _updateLoadingState({
    required int stage,
    required String statusText,
    required String detailText,
  }) {
    state = state.copyWith(
      loadingProgress: stage / _totalLoadingStages,
      loadingStatusText: statusText,
      loadingDetailText: detailText,
    );
  }
}
