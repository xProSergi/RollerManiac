import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/reporte_diario_entity.dart';
import '../repositories/historial_repository.dart';

class FinalizarVisitaAtraccionUseCase implements UseCase<ReporteDiarioEntity, FinalizarVisitaAtraccionParams> {
  final HistorialRepository repository;

  FinalizarVisitaAtraccionUseCase(this.repository);

  @override
  Future<Either<Failure, ReporteDiarioEntity>> call(FinalizarVisitaAtraccionParams params) async {
    return await repository.finalizarVisitaAtraccion(
      params.reporteId,
      params.visitaId,
      params.userId,
      valoracion: params.valoracion,
      notas: params.notas,
    );
  }
}

class FinalizarVisitaAtraccionParams extends Equatable {
  final String reporteId;
  final String visitaId;
  final String userId;
  final int? valoracion;
  final String? notas;

  const FinalizarVisitaAtraccionParams({
    required this.reporteId,
    required this.visitaId,
    required this.userId,
    this.valoracion,
    this.notas,
  });

  @override
  List<Object?> get props => [reporteId, visitaId, userId, valoracion, notas];
}
