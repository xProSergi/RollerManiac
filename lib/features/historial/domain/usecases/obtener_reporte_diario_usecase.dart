import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/reporte_diario_entity.dart';
import '../repositories/historial_repository.dart';

class ObtenerReporteDiarioUseCase implements UseCase<ReporteDiarioEntity, ObtenerReporteDiarioParams> {
  final HistorialRepository repository;

  ObtenerReporteDiarioUseCase(this.repository);

  @override
  Future<Either<Failure, ReporteDiarioEntity>> call(ObtenerReporteDiarioParams params) async {
    return await repository.obtenerReportePorId(
      params.userId,
      params.reporteId,
    );
  }
}

class ObtenerReporteDiarioParams {
  final String userId;
  final String reporteId;

  ObtenerReporteDiarioParams({
    required this.userId,
    required this.reporteId,
  });
}