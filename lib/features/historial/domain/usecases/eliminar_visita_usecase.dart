import '../repositories/historial_repository.dart';

class EliminarVisitaUseCase {
  final HistorialRepository repository;

  EliminarVisitaUseCase(this.repository);

  Future<void> call(String visitaId, String userId) async {
    return await repository.eliminarVisita(visitaId, userId);
  }
}