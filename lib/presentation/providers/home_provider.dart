import 'package:flutter/material.dart';
import '../../core/base/base_provider.dart';
import '../../core/utils/mahas.dart';
import '../../data/datasource/models/api_response_model.dart';
import '../../data/datasource/network/service/pokemon_service.dart';
import '../../data/datasource/network/service/move_service.dart';
import '../../data/datasource/network/service/ability_service.dart';
import '../../data/datasource/network/service/item_service.dart';
import '../../data/datasource/network/service/location_service.dart';
import '../routes/app_routes.dart';

class HomeProvider extends BaseProvider {
  // Services
  final PokemonService _pokemonService = PokemonService();
  final MoveService _moveService = MoveService();
  final AbilityService _abilityService = AbilityService();
  final ItemService _itemService = ItemService();
  final LocationService _locationService = LocationService();

  // Data untuk home screen (kosong karena kita hanya menampilkan menu)

  // Loading states
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Error states
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  @override
  void onInit() {
    super.onInit();
    // Tidak perlu inisialisasi data karena home page hanya menampilkan menu
  }

  // Method untuk refresh jika diperlukan
  Future<void> refresh() async {
    await runAsync('refresh', () async {
      // Reset error message
      _errorMessage = null;

      // Tidak ada data yang perlu di-refresh
    });
  }

  // Navigasi ke halaman Pokemon
  void navigateToPokemonList() {
    Mahas.routeTo(AppRoutes.pokemonList);
  }

  // Navigasi ke halaman Move
  void navigateToMoveList() {
    Mahas.routeTo(AppRoutes.moveList);
  }

  // Navigasi ke halaman Ability
  void navigateToAbilityList() {
    // Akan diimplementasikan nanti
  }

  // Navigasi ke halaman Item
  void navigateToItemList() {
    // Akan diimplementasikan nanti
  }

  // Navigasi ke halaman Location
  void navigateToLocationList() {
    // Akan diimplementasikan nanti
  }

  // Navigasi ke halaman Type Charts
  void navigateToTypeCharts() {
    // Akan diimplementasikan nanti
  }
}
