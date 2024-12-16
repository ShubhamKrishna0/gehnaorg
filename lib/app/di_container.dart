import 'package:get_it/get_it.dart';
import '../data/apis/category_api.dart';
import '../data/repositories/category_repository.dart';
import '../core/utils/network_utils.dart';

final sl = GetIt.instance;

void init() {
  sl.registerLazySingleton(() => NetworkUtils.createDio());
  sl.registerLazySingleton(() => CategoryApi(sl()));
  sl.registerLazySingleton(() => CategoryRepository(sl()));
}
