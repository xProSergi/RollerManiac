import '../repositories/clima_repository.dart';
import '../entities/clima.dart';

class ObtenerClimaPorCiudad {
  final ClimaRepository repository;

  ObtenerClimaPorCiudad(this.repository);

  Future<Clima> ejecutar(String ciudad) async {
    return await repository.obtenerClimaPorCiudad(ciudad);
  }
}