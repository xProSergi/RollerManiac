import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// TIEMPOS
import '../features/tiempos/data/datasources/parques_remote_datasource.dart';
import '../features/tiempos/data/datasources/clima_remote_datasource.dart';
import '../features/tiempos/data/repositories/parques_repository_impl.dart';
import '../features/tiempos/data/repositories/clima_repository_impl.dart';
import '../features/tiempos/domain/repositories/parques_repository.dart';
import '../features/tiempos/domain/repositories/clima_repository.dart';
import '../features/tiempos/domain/usecases/get_parques.dart';
import '../features/tiempos/domain/usecases/obtener_clima_por_ciudad.dart';
import '../features/tiempos/presentation/viewmodel/tiempos_viewmodel.dart';

// SOCIAL
import '../features/social/data/datasources/social_remote_datasource.dart';
import '../features/social/data/repositories/social_repository_impl.dart';
import '../features/social/domain/repositories/social_repository.dart';
import '../features/social/domain/usecases/agregar_amigo_usecase.dart';
import '../features/social/domain/usecases/obtener_amigos_usecase.dart';
import '../features/social/domain/usecases/obtener_solicitudes_recibidas_usecase.dart';
import '../features/social/domain/usecases/aceptar_solicitud_usecase.dart';
import '../features/social/domain/usecases/obtener_ranking_usecase.dart';
import '../features/social/presentation/viewmodel/social_viewmodel.dart';

// HISTORIAL
import '../features/historial/data/datasources/historial_remote_datasource.dart';
import '../features/historial/data/repositories/historial_repository_impl.dart';
import '../features/historial/domain/repositories/historial_repository.dart';
import '../features/historial/domain/usecases/iniciar_nuevo_dia_usecase.dart';
import '../features/historial/domain/usecases/agregar_visita_atraccion_usecase.dart';
import '../features/historial/domain/usecases/finalizar_visita_atraccion_usecase.dart';
import '../features/historial/domain/usecases/finalizar_dia_usecase.dart';
import '../features/historial/domain/usecases/obtener_reporte_diario_usecase.dart';
import '../features/historial/domain/usecases/obtener_visitas_usecase.dart' hide ObtenerVisitasPorParqueUseCase;
import '../features/historial/domain/usecases/obtener_visitas_por_parque_usecase.dart';
import '../features/historial/presentation/viewmodel/reporte_diario_viewmodel.dart';
import '../features/historial/presentation/viewmodel/historial_view_model.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // External
  getIt.registerLazySingleton(() => http.Client());
  getIt.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  // DataSources
  getIt.registerLazySingleton<ParquesRemoteDataSource>(
          () => ParquesRemoteDataSourceImpl(client: getIt()));
  getIt.registerLazySingleton<ClimaRemoteDataSource>(
          () => ClimaRemoteDataSourceImpl(client: getIt()));
  getIt.registerLazySingleton<SocialRemoteDataSource>(
          () => SocialRemoteDataSource(firestore: getIt(), auth: getIt()));
  getIt.registerLazySingleton<HistorialRemoteDataSource>(
          () => HistorialRemoteDataSourceImpl(firestore: getIt()));

  // Repositories
  getIt.registerLazySingleton<ParquesRepository>(
          () => ParquesRepositoryImpl(remoteDataSource: getIt()));
  getIt.registerLazySingleton<ClimaRepository>(
          () => ClimaRepositoryImpl(remoteDataSource: getIt()));
  getIt.registerLazySingleton<SocialRepository>(
        () => SocialRepositoryImpl(remote: getIt<SocialRemoteDataSource>()), // Usa 'remote' si ese es el parámetro esperado
  );

  getIt.registerLazySingleton<HistorialRepository>(
          () => HistorialRepositoryImpl(
        remoteDataSource: getIt(),
        firestore: getIt(),
      ));

  // UseCases
  getIt.registerLazySingleton(() => GetParques(getIt()));
  getIt.registerLazySingleton(() => ObtenerClimaPorCiudad(getIt()));
  getIt.registerLazySingleton(() => AgregarAmigoUseCase(getIt()));
  getIt.registerLazySingleton(() => ObtenerAmigosUseCase(getIt()));
  getIt.registerLazySingleton(() => ObtenerSolicitudesRecibidasUseCase(getIt()));
  getIt.registerLazySingleton(() => AceptarSolicitudUseCase(getIt()));
  getIt.registerLazySingleton(() => ObtenerRankingUseCase(getIt()));
  getIt.registerLazySingleton(() => IniciarNuevoDiaUseCase(getIt()));
  getIt.registerLazySingleton(() => AgregarVisitaAtraccionUseCase(getIt()));
  getIt.registerLazySingleton(() => FinalizarVisitaAtraccionUseCase(getIt()));
  getIt.registerLazySingleton(() => FinalizarDiaUseCase(getIt()));
  getIt.registerLazySingleton(() => ObtenerReporteDiarioUseCase(getIt()));
  getIt.registerLazySingleton(() => ObtenerVisitasUseCase(getIt()));
  getIt.registerLazySingleton(() => ObtenerVisitasPorParqueUseCase(getIt()));

  // ViewModels
  getIt.registerFactory(() => TiemposViewModel(
    getParques: getIt(),
    obtenerClimaPorCiudad: getIt(),
    parquesRepository: getIt(),
  ));

  getIt.registerFactory(() => SocialViewModel(
    agregarAmigoUseCase: getIt(),
    obtenerAmigosUseCase: getIt(),
    obtenerSolicitudesRecibidasUseCase: getIt(),
    aceptarSolicitudUseCase: getIt(),
    obtenerRankingUseCase: getIt(),
  ));

  getIt.registerFactory(() => ReporteDiarioViewModel(
    obtenerReporteDiarioUseCase: getIt(),
    iniciarNuevoDiaUseCase: getIt(),
    agregarVisitaAtraccionUseCase: getIt(),
    finalizarVisitaAtraccionUseCase: getIt(),
    finalizarDiaUseCase: getIt(),
    historialRepository: getIt(),
  ));

  getIt.registerFactory(() => HistorialViewModel(
    obtenerVisitasUseCase: getIt(),
    obtenerVisitasPorParqueUseCase: getIt(),
  ));
}