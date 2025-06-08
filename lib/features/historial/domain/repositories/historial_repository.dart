import '../entities/visita_entity.dart';

abstract class HistorialRepository {
  Future<List<VisitaEntity>> obtenerVisitas(String userId);
  Future<void> registrarVisita(VisitaEntity visita);
  Future<void> eliminarVisita(String visitaId, String userId);
  Future<List<VisitaEntity>> obtenerVisitasPorParque(String parqueId, String userId);
}