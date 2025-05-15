import '../entities/clima.dart';

abstract class ClimaRepository {
  Future<Clima> obtenerClimaPorCiudad(String ciudad);
}