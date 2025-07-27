import '../repositories/clima_repository.dart';
import '../entities/clima.dart';
import 'package:equatable/equatable.dart';

class ObtenerClimaPorCiudad {
  final ClimaRepository repository;

  ObtenerClimaPorCiudad(this.repository);

  @override
  Future<Clima> call(Params params) async {
    return await repository.obtenerClimaPorCiudad(params.ciudad);
  }
}

class Params extends Equatable {
  final String ciudad;

  const Params({required this.ciudad});

  @override
  List<Object> get props => [ciudad];
}