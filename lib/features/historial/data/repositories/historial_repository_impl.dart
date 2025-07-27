import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';

import '../../domain/entities/reporte_diario_entity.dart';
import '../../domain/entities/visita_atraccion_entity.dart';
// import '../../domain/entities/visita_entity.dart'; // REMOVED: If not used
import '../../domain/repositories/historial_repository.dart';
import '../datasources/historial_remote_datasource.dart';
import '../models/reporte_diario_model.dart';
import '../models/visita_atraccion_model.dart';
// import '../models/visita_model.dart'; // REMOVED: If not used

class HistorialRepositoryImpl implements HistorialRepository {
  final HistorialRemoteDataSource remoteDataSource;
  final FirebaseFirestore firestore; // Injected for specific queries not handled by remoteDataSource directly
  final Uuid uuid;

  HistorialRepositoryImpl({
    required this.remoteDataSource,
    required this.firestore,
    this.uuid = const Uuid(),
  });

  // --- Visita Atracción / Reporte Diario Methods ---

  @override
  Future<Either<Failure, List<VisitaAtraccionEntity>>> obtenerVisitas(
      String userId, String reporteId) async {
    try {
      // Delegate to remoteDataSource, which now uses the correct direct path
      final result = await remoteDataSource.obtenerVisitas(userId, reporteId);
      return Right(result.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on PermissionDeniedException catch (e) {
      return Left(PermissionDeniedFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<VisitaAtraccionEntity>>> obtenerVisitasPorParque(
      String parqueId, String userId, String reporteId) async {
    try {
      // Delegate to remoteDataSource, which now uses the correct direct path and filters
      final result = await remoteDataSource.obtenerVisitasPorParque(parqueId, userId, reporteId);
      return Right(result.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on PermissionDeniedException catch (e) {
      return Left(PermissionDeniedFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, ReporteDiarioEntity>> obtenerReportePorId(
      String userId, String reporteId) async {
    try {
      final reporteModel = await remoteDataSource.obtenerReportePorId(userId, reporteId);
      // Fetch attractions separately since they are in a different collection
      final atracciones = await remoteDataSource.obtenerVisitasAtraccionEnTiempoReal(userId, reporteId).first;

      return Right(reporteModel.toEntity().copyWith(
        atraccionesVisitadas: atracciones.map((e) => e.toEntity()).toList(),
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on PermissionDeniedException catch (e) {
      return Left(PermissionDeniedFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Stream<List<VisitaAtraccionEntity>> obtenerVisitasAtraccionEnTiempoReal(
      String userId, String reporteId) {
    // Delegate to remoteDataSource, which handles the direct collection stream
    return remoteDataSource.obtenerVisitasAtraccionEnTiempoReal(userId, reporteId)
        .map((models) => models.map((model) => model.toEntity()).toList())
        .handleError((error) {
      // You can catch specific exceptions here if needed
      debugPrint('Error en stream de atracciones del repositorio: $error');
      throw ServerFailure(message: 'Error en tiempo real de atracciones: ${error.toString()}');
    });
  }

  @override
  Stream<ReporteDiarioEntity?> obtenerReporteEnTiemReal(String reporteId, String userId) {
    // This stream now returns a ReporteDiarioModel *without* populated attractions.
    // The ViewModel needs to combine this with the attractions stream.
    return remoteDataSource.obtenerReporteEnTiemReal(reporteId, userId)
        .map((reporteModel) => reporteModel?.toEntity())
        .handleError((error) {
      debugPrint('Error en stream de reporte principal del repositorio: $error');
      throw ServerFailure(message: 'Error en tiempo real del reporte: ${error.toString()}');
    });
  }

  @override
  Future<ReporteDiarioEntity?> obtenerReporteDiarioActual(String userId, DateTime fecha) async {
    try {
      final reporteModel = await remoteDataSource.obtenerReporteDiarioActual(userId, fecha);
      if (reporteModel == null) return null;

      // Fetch attractions separately for the current report
      final atracciones = await remoteDataSource.obtenerVisitasAtraccionEnTiempoReal(userId, reporteModel.id).first; // Get current state

      return reporteModel.toEntity().copyWith(atraccionesVisitadas: atracciones.map((e) => e.toEntity()).toList());
    } on ServerException catch (e) {
      debugPrint('Server error in obtenerReporteDiarioActual: ${e.message}');
      return null;
    } on PermissionDeniedException catch (e) {
      debugPrint('Permission denied in obtenerReporteDiarioActual: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Unexpected error in obtenerReporteDiarioActual: $e');
      return null;
    }
  }

  @override
  Future<Either<Failure, List<ReporteDiarioEntity>>> obtenerReportesPorRango(
      String userId, {
        required DateTime fechaInicio,
        required DateTime fechaFin,
      }) async {
    try {
      final reportesModels = await remoteDataSource.obtenerReportesPorRango(
          userId, fechaInicio: fechaInicio, fechaFin: fechaFin);

      final List<ReporteDiarioEntity> reportesConAtracciones = [];
      for (var reporteModel in reportesModels) {
        // Fetch attractions for each report
        final atracciones = await remoteDataSource.obtenerVisitasAtraccionEnTiempoReal(userId, reporteModel.id).first;
        reportesConAtracciones.add(reporteModel.toEntity().copyWith(
          atraccionesVisitadas: atracciones.map((e) => e.toEntity()).toList(),
        ));
      }

      return Right(reportesConAtracciones);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on PermissionDeniedException catch (e) {
      return Left(PermissionDeniedFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, ReporteDiarioEntity>> iniciarNuevoDia({
    required String userId,
    required String parqueId,
    required String parqueNombre,
    required DateTime fecha,
  }) async {
    try {
      final reporteModel = await remoteDataSource.iniciarNuevoDia(
        userId: userId,
        parqueId: parqueId,
        parqueNombre: parqueNombre,
        fecha: fecha,
      );
      // Return the new report, without any attractions initially
      return Right(reporteModel.toEntity().copyWith(atraccionesVisitadas: []));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on PermissionDeniedException catch (e) {
      return Left(PermissionDeniedFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, ReporteDiarioEntity>> agregarVisitaAtraccion(
      String reporteId,
      VisitaAtraccionEntity visita,
      String userId,
      ) async {
    try {
      // Ensure the ID is set on the entity if not already
      final visitaWithId = visita.id.isEmpty ? visita.copyWith(id: uuid.v4(), fecha: DateTime.now()) : visita.copyWith(fecha: DateTime.now());
      debugPrint('Agregando visita con ID: ${visitaWithId.id}, ReporteID: $reporteId, Atraccion: ${visitaWithId.atraccionNombre}');

      // Convert entity to model for remote data source
      final visitaModel = VisitaAtraccionModel.fromEntity(visitaWithId);

      final reporteActualizadoModel = await remoteDataSource.agregarVisitaAtraccion(
        userId: userId,
        reporteId: reporteId,
        visita: visitaModel,
      );

      // Fetch the latest attractions to ensure the returned entity is complete
      final atraccionesActualizadas = await remoteDataSource.obtenerVisitasAtraccionEnTiempoReal(userId, reporteId).first;

      return Right(reporteActualizadoModel.toEntity().copyWith(
        atraccionesVisitadas: atraccionesActualizadas.map((e) => e.toEntity()).toList(),
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on PermissionDeniedException catch (e) {
      return Left(PermissionDeniedFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } catch (e) {
      debugPrint('Error inesperado al agregar visita en repo: $e');
      return Left(ServerFailure(message: 'Error inesperado al agregar visita: $e'));
    }
  }

  @override
  Future<Either<Failure, ReporteDiarioEntity>> finalizarVisitaAtraccion(
      String reporteId,
      String visitaId,
      String userId, {
        int? valoracion,
        String? notas,
      }) async {
    try {
      final reporteActualizadoModel = await remoteDataSource.finalizarVisitaAtraccion(
        reporteId: reporteId,
        visitaId: visitaId,
        userId: userId,
        valoracion: valoracion,
        notas: notas,
      );

      // Fetch the latest attractions to ensure the returned entity is complete
      final atraccionesActualizadas = await remoteDataSource.obtenerVisitasAtraccionEnTiempoReal(userId, reporteId).first;

      return Right(reporteActualizadoModel.toEntity().copyWith(
        atraccionesVisitadas: atraccionesActualizadas.map((e) => e.toEntity()).toList(),
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on PermissionDeniedException catch (e) {
      return Left(PermissionDeniedFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, ReporteDiarioEntity>> finalizarDia({
    required String reporteId,
    required String userId,
  }) async {
    try {
      final reporteActualizadoModel = await remoteDataSource.finalizarDia(
        reporteId: reporteId,
        userId: userId,
      );

      // Fetch the latest attractions to ensure the returned entity is complete
      final atraccionesActualizadas = await remoteDataSource.obtenerVisitasAtraccionEnTiempoReal(userId, reporteId).first;

      return Right(reporteActualizadoModel.toEntity().copyWith(
        atraccionesVisitadas: atraccionesActualizadas.map((e) => e.toEntity()).toList(),
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on PermissionDeniedException catch (e) {
      return Left(PermissionDeniedFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, ReporteDiarioEntity>> actualizarReporteDiario(
      ReporteDiarioEntity reporte) async {
    try {
      final reporteModel = ReporteDiarioModel.fromEntity(reporte);
      final reporteActualizadoModel = await remoteDataSource.actualizarReporteDiario(reporteModel);

      // Fetch the latest attractions to ensure the returned entity is complete
      final atraccionesActualizadas = await remoteDataSource.obtenerVisitasAtraccionEnTiempoReal(reporte.userId, reporte.id).first;

      return Right(reporteActualizadoModel.toEntity().copyWith(
        atraccionesVisitadas: atraccionesActualizadas.map((e) => e.toEntity()).toList(),
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on PermissionDeniedException catch (e) {
      return Left(PermissionDeniedFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }
}