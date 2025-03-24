import '../pages/home/home_page.dart';
import '../pages/item/item_detail/item_detail_page.dart';
import '../pages/item/item_list/item_list_page.dart';
import '../pages/location/location_area_detail/location_area_detail_page.dart';
import '../pages/location/location_detail/location_detail_page.dart';
import '../pages/location/location_list/location_list_page.dart';
import '../pages/pokemon/pokemon_list/pokemon_list_page.dart';
import '../pages/pokemon/pokemon_detail/pokemon_detail_page.dart';
import '../pages/move/move_list/move_list_page.dart';
import '../pages/move/move_detail/move_detail_page.dart';
import '../pages/ability/ability_list/ability_list_page.dart';
import '../pages/ability/ability_detail/ability_detail_page.dart';
import '../pages/welcome/welcome_page.dart';

import 'package:flutter/material.dart';
import 'app_routes.dart';

class AppRoutesProvider {
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      // Welcome page as the initial route
      AppRoutes.welcome: (context) => const WelcomePage(),
      AppRoutes.home: (context) => const HomePage(),
      // The Pokemon detail page needs parameters, so it will be created using Navigator.push
      // directly from the home page. This route is just for reference or deep linking.
      AppRoutes.pokemonList: (context) => const PokemonListPage(),
      AppRoutes.pokemonDetail: (context) => const PokemonDetailPage(),
      AppRoutes.moveList: (context) => const MoveListPage(),
      AppRoutes.moveDetail: (context) => const MoveDetailPage(),
      AppRoutes.abilityList: (context) => const AbilityListPage(),
      AppRoutes.abilityDetail: (context) => const AbilityDetailPage(),
      AppRoutes.itemList: (context) => const ItemListPage(),
      AppRoutes.itemDetail: (context) => const ItemDetailPage(),
      AppRoutes.locationList: (context) => const LocationListPage(),
      AppRoutes.locationDetail: (context) => const LocationDetailPage(),
      AppRoutes.locationAreaDetail: (context) => const LocationAreaDetailPage(),
    };
  }
}
