import 'package:get_it/get_it.dart';

import '../core/utils/network_utils.dart';
import '../features/add_product/apis/category_api.dart';
import '../features/add_product/data/repositories/category_repository.dart';

final sl = GetIt.instance;

void init() {
  sl.registerLazySingleton(() => NetworkUtils.createDio());
  sl.registerLazySingleton(() => CategoryApi(sl()));
  sl.registerLazySingleton(() => CategoryRepository(sl()));
}
