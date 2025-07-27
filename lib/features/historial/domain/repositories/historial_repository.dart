// features/historial/domain/repositories/historial_repository.dart
import 'package:dartz/dartz.dart';
import '../entities/reporte_diario_entity.dart';
import '../entities/visita_atraccion_entity.dart';
import '../entities/visita_entity.dart'; // Assuming you have this entity

import '../../../../core/error/failures.dart';

abstract class HistorialRepository {
  Future<Either<Failure, List<VisitaAtraccionEntity>>> obtenerVisitas(String userId, String reporteId);

  Future<Either<Failure, List<VisitaAtraccionEntity>>> obtenerVisitasPorParque(String parqueId, String userId, String reporteId);

  // Daily Report methods
  Future<Either<Failure, ReporteDiarioEntity>> obtenerReportePorId(String userId, String reporteId);
  Stream<ReporteDiarioEntity?> obtenerReporteEnTiemReal(String reporteId, String userId);
  Stream<List<VisitaAtraccionEntity>> obtenerVisitasAtraccionEnTiempoReal(
      String userId, String reporteId);

  Future<ReporteDiarioEntity?> obtenerReporteDiarioActual(String userId, DateTime fecha);
  Future<Either<Failure, List<ReporteDiarioEntity>>> obtenerReportesPorRango(
      String userId, {
        required DateTime fechaInicio,
        required DateTime fechaFin,
      });

  Future<Either<Failure, ReporteDiarioEntity>> iniciarNuevoDia({
    required String userId,
    required String parqueId,
    required String parqueNombre,
    required DateTime fecha,
  });

  Future<Either<Failure, ReporteDiarioEntity>> agregarVisitaAtraccion(
      String reporteId,
      VisitaAtraccionEntity visita,
      String userId,
      );

  Future<Either<Failure, ReporteDiarioEntity>> finalizarVisitaAtraccion(
      String reporteId,
      String visitaId,
      String userId,
      {
        int? valoracion,
        String? notas,
      });

  Future<Either<Failure, ReporteDiarioEntity>> finalizarDia({
    required String reporteId,
    required String userId,
  });

  Future<Either<Failure, ReporteDiarioEntity>> actualizarReporteDiario(ReporteDiarioEntity reporte);
}