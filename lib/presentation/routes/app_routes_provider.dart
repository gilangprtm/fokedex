import '../pages/home/home_page.dart';
import '../pages/pokemon_detail/pokemon_detail_page.dart';

import 'package:flutter/material.dart';
import 'app_routes.dart';

class AppRoutesProvider {
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      AppRoutes.home: (context) => const HomePage(),
      // The Pokemon detail page needs parameters, so it will be created using Navigator.push
      // directly from the home page. This route is just for reference or deep linking.
      AppRoutes.pokemonDetail: (context) {
        final args =
            ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
        return PokemonDetailPage(
          pokemonId: args?['id'] ?? '1',
          pokemonName: args?['name'] ?? 'bulbasaur',
        );
      },
    };
  }
}
