import 'package:get_it/get_it.dart';
import 'package:sandbox_demo/services/global_data.dart';
import 'package:sandbox_demo/services/http_service.dart';
import 'package:sandbox_demo/services/navigation_service.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => HttpService());
  locator.registerLazySingleton(() => GlobalData());
  locator.registerLazySingleton(() => NavigationService());
}
