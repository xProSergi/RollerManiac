import '../entities/visita_entity.dart';
import '../repositories/historial_repository.dart';

class ObtenerVisitasUseCase {
  final HistorialRepository repository;

  ObtenerVisitasUseCase(this.repository);

  Future<List<VisitaEntity>> call(String userId) async {
    return await repository.obtenerVisitas(userId);
  }
}
