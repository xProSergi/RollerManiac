import 'package:dartz/dartz.dart';
import 'package:roller_maniac/features/historial/domain/entities/visita_atraccion_entity.dart';
import '../../../../core/error/failures.dart';
import '../repositories/historial_repository.dart';

class ObtenerVisitasUseCase {
  final HistorialRepository repository;

  ObtenerVisitasUseCase(this.repository);

  Future<Either<Failure, List<VisitaAtraccionEntity>>> call({
    required String userId,
    required String reporteId,
  }) async {
    return await repository.obtenerVisitas(userId, reporteId);
  }
}

class ObtenerVisitasPorParqueUseCase {
  final HistorialRepository repository;

  ObtenerVisitasPorParqueUseCase(this.repository);

  Future<Either<Failure, List<VisitaAtraccionEntity>>> call(
      String userId,
      String parqueId,
      String reporteId, // Added this parameter
      ) async {
    return await repository.obtenerVisitasPorParque(parqueId, userId, reporteId);
  }
}