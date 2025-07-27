import 'package:equatable/equatable.dart';

enum TipoVisita { parque, atraccion }

class VisitaEntity extends Equatable {
  final String id;
  final String parqueId;
  final String parqueNombre;
  final String? atraccionId;
  final String? atraccionNombre;
  final DateTime fecha;
  final String userId;
  final TipoVisita tipo;
  final Duration? duracion;
  final String? notas;
  final String? reporteDiarioId;

  const VisitaEntity({
    required this.id,
    required this.parqueId,
    required this.parqueNombre,
    this.atraccionId,
    this.atraccionNombre,
    required this.fecha,
    required this.userId,
    required this.tipo,
    this.duracion,
    this.notas,
    this.reporteDiarioId,
  });

  @override
  List<Object?> get props => [
    id,
    parqueId,
    parqueNombre,
    atraccionId,
    atraccionNombre,
    fecha,
    userId,
    tipo,
    duracion,
    notas,
    reporteDiarioId,
  ];
}