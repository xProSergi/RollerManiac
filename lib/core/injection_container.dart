import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../features/tiempos/data/datasources/parques_remote_datasource.dart';
import '../features/tiempos/data/datasources/clima_remote_datasource.dart';
import '../features/tiempos/data/repositories/parques_repository_impl.dart';
import '../features/tiempos/data/repositories/clima_repository_impl.dart';
import '../features/tiempos/domain/repositories/parques_repository.dart';
import '../features/tiempos/domain/repositories/clima_repository.dart';
import '../features/tiempos/domain/usecases/get_parques.dart';
import '../features/tiempos/domain/usecases/obtener_clima_por_ciudad.dart';
import '../features/tiempos/presentation/viewmodel/tiempos_viewmodel.dart';

import '../features/social/data/datasources/social_remote_datasource.dart';
import '../features/social/data/repositories/social_repository_impl.dart';
import '../features/social/domain/repositories/social_repository.dart';
import '../features/social/domain/usecases/agregar_amigo_usecase.dart';
import '../features/social/domain/usecases/obtener_amigos_usecase.dart';
import '../features/social/domain/usecases/obtener_solicitudes_recibidas_usecase.dart';
import '../features/social/domain/usecases/aceptar_solicitud_usecase.dart';
import '../features/social/domain/usecases/obtener_ranking_usecase.dart';
import '../features/social/presentation/viewmodel/social_viewmodel.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // HTTP Client
  getIt.registerLazySingleton(() => http.Client());

  // Firebase
  getIt.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  // IEMPOS
  getIt.registerFactory(() => TiemposViewModel(
    repository: getIt(),
    obtenerClimaPorCiudad: getIt(),
  ));

  getIt.registerLazySingleton(() => GetParques(getIt()));
  getIt.registerLazySingleton(() => ObtenerClimaPorCiudad(getIt()));

  getIt.registerLazySingleton<ParquesRepository>(
          () => ParquesRepositoryImpl(remoteDataSource: getIt()));
  getIt.registerLazySingleton<ClimaRepository>(
          () => ClimaRepositoryImpl(remoteDataSource: getIt()));

  getIt.registerLazySingleton<ParquesRemoteDataSource>(
          () => ParquesRemoteDataSourceImpl(client: getIt()));
  getIt.registerLazySingleton<ClimaRemoteDataSource>(
          () => ClimaRemoteDataSourceImpl(client: getIt()));

  // SOCIAL
  getIt.registerLazySingleton<SocialRemoteDataSource>(
        () => SocialRemoteDataSource(
      firestore: getIt<FirebaseFirestore>(),
      auth: getIt<FirebaseAuth>(),
    ),
  );

  getIt.registerLazySingleton<SocialRepository>(
          () => SocialRepositoryImpl(remote: getIt()));

  getIt.registerLazySingleton(() => AgregarAmigoUseCase(getIt<SocialRepository>()));
  getIt.registerLazySingleton(() => ObtenerAmigosUseCase(getIt<SocialRepository>()));
  getIt.registerLazySingleton(() => ObtenerSolicitudesRecibidasUseCase(getIt<SocialRepository>()));
  getIt.registerLazySingleton(() => AceptarSolicitudUseCase(getIt<SocialRepository>()));
  getIt.registerLazySingleton(() => ObtenerRankingUseCase(getIt<SocialRepository>()));

  getIt.registerFactory(() => SocialViewModel(
    agregarAmigoUseCase: getIt<AgregarAmigoUseCase>(),
    obtenerAmigosUseCase: getIt<ObtenerAmigosUseCase>(),
    obtenerSolicitudesRecibidasUseCase: getIt<ObtenerSolicitudesRecibidasUseCase>(),
    aceptarSolicitudUseCase: getIt<AceptarSolicitudUseCase>(),
    obtenerRankingUseCase: getIt<ObtenerRankingUseCase>(),
  ));
}
