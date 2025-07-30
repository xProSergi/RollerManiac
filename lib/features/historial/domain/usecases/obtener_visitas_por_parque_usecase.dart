import 'package:dartz/dartz.dart';
import '../entities/visita_atraccion_entity.dart';
import '../repositories/historial_repository.dart';
import '../../../../core/error/failures.dart';

class ObtenerVisitasPorParqueUseCase {
  final HistorialRepository repository;

  ObtenerVisitasPorParqueUseCase(this.repository);

  Future<Either<Failure, List<VisitaAtraccionEntity>>> call(
      String userId,
      String parqueId,
      String reporteId,
      ) async {
    return await repository.obtenerVisitasPorParque(parqueId, userId, reporteId);
  }
}