import '../../domain/repositories/clima_repository.dart';
import '../datasources/clima_remote_datasource.dart';
import '../../domain/entities/clima.dart';

class ClimaRepositoryImpl implements ClimaRepository {
  final ClimaRemoteDataSource remoteDataSource;

  ClimaRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Clima> obtenerClimaPorCiudad(String ciudad) async {
    return await remoteDataSource.obtenerClimaPorCiudad(ciudad);
  }
}