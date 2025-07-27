import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/reporte_diario_entity.dart';
import '../repositories/historial_repository.dart';

class IniciarNuevoDiaUseCase implements UseCase<ReporteDiarioEntity, IniciarNuevoDiaParams> {
  final HistorialRepository repository;

  IniciarNuevoDiaUseCase(this.repository);

  @override
  Future<Either<Failure, ReporteDiarioEntity>> call(IniciarNuevoDiaParams params) async {
    return await repository.iniciarNuevoDia(
      userId: params.userId,
      parqueId: params.parqueId,
      parqueNombre: params.parqueNombre,
      fecha: params.fecha,
    );
  }
}

class IniciarNuevoDiaParams {
  final String userId;
  final String parqueId;
  final String parqueNombre;
  final DateTime fecha;

  IniciarNuevoDiaParams({
    required this.userId,
    required this.parqueId,
    required this.parqueNombre,
    required this.fecha,
  });
}