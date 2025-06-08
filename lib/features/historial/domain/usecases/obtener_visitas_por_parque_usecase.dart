import '../entities/visita_entity.dart';
import '../repositories/historial_repository.dart';

class ObtenerVisitasPorParqueUseCase {
  final HistorialRepository repository;

  ObtenerVisitasPorParqueUseCase(this.repository);

  Future<List<VisitaEntity>> call(String parqueId, String userId) async {
    return await repository.obtenerVisitasPorParque(parqueId, userId);
  }
}