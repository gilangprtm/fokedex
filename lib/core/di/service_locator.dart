import 'package:get_it/get_it.dart';

// Import modul-modul
import 'modules/core_module.dart';

final serviceLocator = GetIt.instance;

Future<void> setupServiceLocator() async {
  await setupCoreModule(serviceLocator);
}
