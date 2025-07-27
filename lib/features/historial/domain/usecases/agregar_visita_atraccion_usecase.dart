import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/reporte_diario_entity.dart';
import '../entities/visita_atraccion_entity.dart';
import '../repositories/historial_repository.dart';

class AgregarVisitaAtraccionUseCase implements UseCase<ReporteDiarioEntity, AgregarVisitaAtraccionParams> {
  final HistorialRepository repository;

  AgregarVisitaAtraccionUseCase(this.repository);

  @override
  Future<Either<Failure, ReporteDiarioEntity>> call(AgregarVisitaAtraccionParams params) async {
    return await repository.agregarVisitaAtraccion(
      params.reporteId,
      params.visita,
      params.userId,
    );
  }
}

class AgregarVisitaAtraccionParams extends Equatable {
  final String reporteId;
  final VisitaAtraccionEntity visita;
  final String userId;

  const AgregarVisitaAtraccionParams({
    required this.reporteId,
    required this.visita,
    required this.userId,
  });

  @override
  List<Object> get props => [reporteId, visita, userId];
}