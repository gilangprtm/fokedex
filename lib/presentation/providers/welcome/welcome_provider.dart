import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasource/local/services/local_pokemon_service.dart';
import 'welcome_state.dart';
import 'welcome_notifier.dart';

// Konstanta untuk key penyimpanan
const String kPokemonListKey = 'pokemon_list_updated';
const String kPokemonTypesKey = 'pokemon_types_updated';
const String kPokemonDetailKey = 'pokemon_detail_updated';

/// StateNotifier Provider untuk Welcome Screen
final welcomeProvider = StateNotifierProvider<WelcomeNotifier, WelcomeState>(
  (ref) => WelcomeNotifier(
    const WelcomeState(),
    ref,
    LocalPokemonService(), // In the future, this should come from a provider
  ),
);
