import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../providers/home_provider.dart';
import '../providers/move_list_provider.dart';
import '../providers/move_detail_provider.dart';

class AppProviders {
  static List<SingleChildWidget> getProviders() {
    return [
      // Provider yang akan selalu aktif selama aplikasi berjalan
      ChangeNotifierProvider(create: (context) => HomeProvider()),
      // Provider untuk Move List
      ChangeNotifierProvider(create: (context) => MoveListProvider()),
      // Provider untuk Move Detail
      ChangeNotifierProvider(create: (context) => MoveDetailProvider()),
    ];
  }
}
