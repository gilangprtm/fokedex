import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../providers/home_provider.dart';
import '../providers/pokemon_detail_provider.dart';

class AppProviders {
  static List<SingleChildWidget> getProviders() {
    return [
      // Provider yang akan selalu aktif selama aplikasi berjalan
      ChangeNotifierProvider(create: (context) => HomeProvider()),

      // Providers yang akan dibuat saat diperlukan (lazy)
      ChangeNotifierProvider.value(value: PokemonDetailProvider()),
    ];
  }
}
