import '../../domain/entities/visita_entity.dart';
import '../../domain/repositories/historial_repository.dart';
import '../datasources/historial_remote_datasource.dart';
import '../models/visita_model.dart';

class HistorialRepositoryImpl implements HistorialRepository {
  final HistorialRemoteDataSource remoteDataSource;

  HistorialRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<VisitaEntity>> obtenerVisitas(String userId) async {
    try {
      final visitas = await remoteDataSource.obtenerVisitas(userId);
      return visitas;
    } catch (e) {
      throw Exception('Error en el repositorio al obtener visitas: $e');
    }
  }

  @override
  Future<void> registrarVisita(VisitaEntity visita) async {
    try {
      final visitaModel = VisitaModel(
        id: visita.id,
        parqueId: visita.parqueId,
        parqueNombre: visita.parqueNombre,
        atraccionNombre: visita.atraccionNombre,
        fecha: visita.fecha,
        userId: visita.userId,
      );
      await remoteDataSource.registrarVisita(visitaModel);
    } catch (e) {
      throw Exception('Error en el repositorio al registrar visita: $e');
    }
  }

  @override
  Future<void> eliminarVisita(String visitaId, String userId) async {
    try {
      await remoteDataSource.eliminarVisita(visitaId, userId);
    } catch (e) {
      throw Exception('Error en el repositorio al eliminar visita: $e');
    }
  }

  @override
  Future<List<VisitaEntity>> obtenerVisitasPorParque(String parqueId, String userId) async {
    try {
      final visitas = await remoteDataSource.obtenerVisitasPorParque(parqueId, userId);
      return visitas;
    } catch (e) {
      throw Exception('Error en el repositorio al obtener visitas por parque: $e');
    }
  }
}