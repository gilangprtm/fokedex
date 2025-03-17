import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../providers/home_provider.dart';

class AppProviders {
  static List<SingleChildWidget> getProviders() {
    return [
      // provider yg akan selalu aktif selama aplikasi berjalan
      ChangeNotifierProvider(create: (context) => HomeProvider()),
    ];
  }
}
