import '../pages/home/home_page.dart';

import 'package:flutter/material.dart';
import 'app_routes.dart';

class AppRoutesProvider {
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      AppRoutes.home: (context) => const HomePage(),
    };
  }
}
