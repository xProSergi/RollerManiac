import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/reporte_diario_entity.dart';
import '../repositories/historial_repository.dart';

class FinalizarDiaUseCase implements UseCase<ReporteDiarioEntity, FinalizarDiaParams> {
  final HistorialRepository repository;

  FinalizarDiaUseCase(this.repository);

  @override
  Future<Either<Failure, ReporteDiarioEntity>> call(FinalizarDiaParams params) async {
    return await repository.finalizarDia(
      reporteId: params.reporteId,
      userId: params.userId,
    );
  }
}

class FinalizarDiaParams {
  final String reporteId;
  final String userId;

  FinalizarDiaParams({
    required this.reporteId,
    required this.userId,
  });
}