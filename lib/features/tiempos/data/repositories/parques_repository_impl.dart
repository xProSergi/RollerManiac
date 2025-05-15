import '../../domain/entities/atraccion.dart';
import '../../domain/entities/parque.dart';
import '../../domain/repositories/parques_repository.dart';
import '../datasources/parques_remote_datasource.dart';

class ParquesRepositoryImpl implements ParquesRepository {
  final ParquesRemoteDataSource remoteDataSource;

  ParquesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Parque>> obtenerParques() {
    return remoteDataSource.obtenerParques();
  }

  @override
  Future<List<Atraccion>> obtenerAtraccionesDeParque(int parqueId) {
    return remoteDataSource.obtenerAtraccionesDeParque(parqueId);
  }
}
