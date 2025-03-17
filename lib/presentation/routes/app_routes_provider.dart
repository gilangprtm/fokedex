import '../pages/home/home_page.dart';
import '../pages/pokemon/pokemon_list/pokemon_list_page.dart';
import '../pages/pokemon/pokemon_detail/pokemon_detail_page.dart';

import 'package:flutter/material.dart';
import 'app_routes.dart';

class AppRoutesProvider {
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      AppRoutes.home: (context) => const HomePage(),
      // The Pokemon detail page needs parameters, so it will be created using Navigator.push
      // directly from the home page. This route is just for reference or deep linking.
      AppRoutes.pokemonList: (context) => const PokemonListPage(),
      AppRoutes.pokemonDetail: (context) => const PokemonDetailPage(),
    };
  }
}
