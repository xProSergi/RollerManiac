import 'package:equatable/equatable.dart';

class VisitaAtraccionEntity extends Equatable {
  final String id;
  final String reporteDiarioId;
  final String parqueId;
  final String parqueNombre;
  final String atraccionId;
  final String atraccionNombre;
  final String userId;
  final DateTime horaInicio;
  final DateTime? horaFin;
  final Duration? duracion;
  final int? valoracion;
  final String? notas;
  final DateTime fecha;

  const VisitaAtraccionEntity({
    required this.id,
    required this.reporteDiarioId,
    required this.parqueId,
    required this.parqueNombre,
    required this.atraccionId,
    required this.atraccionNombre,
    required this.userId,
    required this.horaInicio,
    this.horaFin,
    this.duracion,
    this.valoracion,
    this.notas,
    required this.fecha,
  });

  VisitaAtraccionEntity copyWith({
    String? id,
    String? reporteDiarioId,
    String? parqueId,
    String? parqueNombre,
    String? atraccionId,
    String? atraccionNombre,
    String? userId,
    DateTime? horaInicio,
    DateTime? horaFin,
    Duration? duracion,
    int? valoracion,
    String? notas,
    DateTime? fecha,
  }) {
    return VisitaAtraccionEntity(
      id: id ?? this.id,
      reporteDiarioId: reporteDiarioId ?? this.reporteDiarioId,
      parqueId: parqueId ?? this.parqueId,
      parqueNombre: parqueNombre ?? this.parqueNombre,
      atraccionId: atraccionId ?? this.atraccionId,
      atraccionNombre: atraccionNombre ?? this.atraccionNombre,
      userId: userId ?? this.userId,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      duracion: duracion ?? this.duracion,
      valoracion: valoracion ?? this.valoracion,
      notas: notas ?? this.notas,
      fecha: fecha ?? this.fecha,
    );
  }

  @override
  List<Object?> get props => [
    id,
    reporteDiarioId,
    parqueId,
    parqueNombre,
    atraccionId,
    atraccionNombre,
    userId,
    horaInicio,
    horaFin,
    duracion,
    valoracion,
    notas,
    fecha,
  ];
}