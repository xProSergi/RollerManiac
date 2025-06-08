import 'package:equatable/equatable.dart';

class VisitaEntity extends Equatable {
  final String id;
  final String parqueId;
  final String parqueNombre;
  final String? atraccionNombre;
  final DateTime fecha;
  final String userId;

  const VisitaEntity({
    required this.id,
    required this.parqueId,
    required this.parqueNombre,
    this.atraccionNombre,
    required this.fecha,
    required this.userId,
  });

  @override
  List<Object?> get props => [id, parqueId, parqueNombre, atraccionNombre, fecha, userId];
}