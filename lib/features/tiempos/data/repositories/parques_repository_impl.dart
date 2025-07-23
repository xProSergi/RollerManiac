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
  Future<List<Atraccion>> obtenerAtraccionesDeParque(String parqueId) {
    return remoteDataSource.obtenerAtraccionesDeParque(parqueId.toString());
  }
  @override
  Future<List<Parque>> obtenerParquesPaginados({Parque? ultimoParque, int limite = 10}) {
    return remoteDataSource.obtenerParquesPaginados(ultimoParque: ultimoParque, limite: limite);
  }


}
