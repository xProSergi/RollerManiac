import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import '../features/tiempos/data/datasources/parques_remote_datasource.dart';
import '../features/tiempos/data/datasources/clima_remote_datasource.dart';
import '../features/tiempos/data/repositories/parques_repository_impl.dart';
import '../features/tiempos/domain/repositories/parques_repository.dart';
import '../features/tiempos/domain/usecases/get_parques.dart';

import '../features/tiempos/domain/usecases/obtener_clima_por_ciudad.dart';
import '../features/tiempos/domain/repositories/clima_repository.dart';
import '../features/tiempos/data/repositories/clima_repository_impl.dart';
import '../features/tiempos/presentation/viewmodel/tiempos_viewmodel.dart';

final getIt = GetIt.instance;

Future<void> init() async {

  getIt.registerFactory(
        () => TiemposViewModel(
      repository: getIt(),
      obtenerClimaPorCiudad: getIt(),
    ),
  );


  getIt.registerLazySingleton(() => GetParques(getIt()));
  getIt.registerLazySingleton(() => ObtenerClimaPorCiudad(getIt()));


  getIt.registerLazySingleton<ParquesRepository>(
        () => ParquesRepositoryImpl(remoteDataSource: getIt()),
  );
  getIt.registerLazySingleton<ClimaRepository>(
        () => ClimaRepositoryImpl(remoteDataSource: getIt()),
  );


  getIt.registerLazySingleton<ParquesRemoteDataSource>(
        () => ParquesRemoteDataSourceImpl(client: getIt()),
  );
  getIt.registerLazySingleton<ClimaRemoteDataSource>(
        () => ClimaRemoteDataSourceImpl(client: getIt()),
  );


  getIt.registerLazySingleton(() => http.Client());
}

