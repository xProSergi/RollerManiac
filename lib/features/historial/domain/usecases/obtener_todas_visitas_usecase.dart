import 'package:dartz/dartz.dart';
import '../entities/visita_atraccion_entity.dart';
import '../repositories/historial_repository.dart';
import '../../../../core/error/failures.dart';

class ObtenerTodasVisitasUseCase {
  final HistorialRepository repository;

  ObtenerTodasVisitasUseCase(this.repository);

  Future<Either<Failure, List<VisitaAtraccionEntity>>> call(String userId) async {
    return await repository.obtenerTodasLasVisitas(userId);
  }
}