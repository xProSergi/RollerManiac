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

import '../features/historial/data/datasources/historial_remote_datasource.dart';
import '../features/historial/data/repositories/historial_repository_impl.dart';
import '../features/historial/domain/repositories/historial_repository.dart';
import '../features/historial/domain/usecases/obtener_visitas_usecase.dart';
import '../features/historial/domain/usecases/obtener_visitas_por_parque_usecase.dart';
import '../features/historial/domain/usecases/obtener_todas_visitas_usecase.dart';
import '../features/historial/domain/usecases/obtener_reporte_diario_usecase.dart';
import '../features/historial/domain/usecases/iniciar_nuevo_dia_usecase.dart';
import '../features/historial/domain/usecases/agregar_visita_atraccion_usecase.dart';
import '../features/historial/domain/usecases/finalizar_dia_usecase.dart';
import '../features/historial/presentation/viewmodel/historial_view_model.dart';
import '../features/historial/presentation/viewmodel/reporte_diario_viewmodel.dart';

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

  getIt.registerLazySingleton(() => http.Client());

  // Firebase
  getIt.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  // TIEMPOS
  getIt.registerFactory(() => TiemposViewModel(
    getParques: getIt(),
    obtenerClimaPorCiudad: getIt(),
    parquesRepository: getIt(),
    historialRepository: getIt(),
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

  // HISTORIAL
  getIt.registerLazySingleton<HistorialRemoteDataSource>(
        () => HistorialRemoteDataSourceImpl(firestore: getIt()),
  );

  getIt.registerLazySingleton<HistorialRepository>(
        () => HistorialRepositoryImpl(
      remoteDataSource: getIt(),
      firestore: getIt(),
    ),
  );

  // Casos de uso del historial
  getIt.registerLazySingleton(() => ObtenerVisitasUseCase(getIt<HistorialRepository>()));
  getIt.registerLazySingleton(() => ObtenerVisitasPorParqueUseCase(getIt<HistorialRepository>()));
  getIt.registerLazySingleton(() => ObtenerTodasVisitasUseCase(getIt<HistorialRepository>()));
  getIt.registerLazySingleton(() => ObtenerReporteDiarioUseCase(getIt<HistorialRepository>()));
  getIt.registerLazySingleton(() => IniciarNuevoDiaUseCase(getIt<HistorialRepository>()));
  getIt.registerLazySingleton(() => AgregarVisitaAtraccionUseCase(getIt<HistorialRepository>()));
  getIt.registerLazySingleton(() => FinalizarDiaUseCase(getIt<HistorialRepository>()));

  // ViewModels del historial
  getIt.registerFactory(() => HistorialViewModel(
    obtenerVisitasUseCase: getIt<ObtenerVisitasUseCase>(),
    obtenerVisitasPorParqueUseCase: getIt<ObtenerVisitasPorParqueUseCase>(),
    obtenerTodasVisitasUseCase: getIt<ObtenerTodasVisitasUseCase>(),
    historialRepository: getIt<HistorialRepository>(),
  ));

  getIt.registerFactory(() => ReporteDiarioViewModel(
    obtenerReporteDiarioUseCase: getIt<ObtenerReporteDiarioUseCase>(),
    iniciarNuevoDiaUseCase: getIt<IniciarNuevoDiaUseCase>(),
    agregarVisitaAtraccionUseCase: getIt<AgregarVisitaAtraccionUseCase>(),
    finalizarDiaUseCase: getIt<FinalizarDiaUseCase>(),
    historialRepository: getIt<HistorialRepository>(),
  ));

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