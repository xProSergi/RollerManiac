import 'package:dartz/dartz.dart';
import 'package:roller_maniac/features/historial/domain/entities/visita_atraccion_entity.dart';
import '../../../../core/error/failures.dart';
import '../entities/visita_entity.dart';
import '../repositories/historial_repository.dart';

class ObtenerVisitasPorParqueUseCase {
  final HistorialRepository repository;

  ObtenerVisitasPorParqueUseCase(this.repository);

  Future<Either<Failure, List<VisitaAtraccionEntity>>> call(
      String parqueId,
      String userId,
      String reporteId, // Add the missing parameter
      ) async {
    return await repository.obtenerVisitasPorParque(parqueId, userId, reporteId);
  }
}