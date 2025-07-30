import 'package:dartz/dartz.dart';
import '../entities/visita_atraccion_entity.dart';
import '../repositories/historial_repository.dart';
import '../../../../core/error/failures.dart';

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
