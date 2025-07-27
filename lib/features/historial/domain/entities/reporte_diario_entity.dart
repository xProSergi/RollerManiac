import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart'; // Make sure this is imported if used

import 'visita_atraccion_entity.dart';

class ReporteDiarioEntity extends Equatable {
  final String id;
  final String userId;
  final String parqueId;
  final String parqueNombre;
  final DateTime fecha;
  final DateTime? fechaFin;
  final List<VisitaAtraccionEntity> atraccionesVisitadas; // Will be populated by repository
  final Duration? tiempoTotalEnParque;
  final String? notas;
  final double? valoracionPromedio;
  final bool sincronizado;

  const ReporteDiarioEntity({
    required this.id,
    required this.userId,
    required this.parqueId,
    required this.parqueNombre,
    required this.fecha,
    this.fechaFin,
    required this.atraccionesVisitadas, // This list is populated by the repository after fetching the main report
    this.tiempoTotalEnParque,
    this.notas,
    this.valoracionPromedio,
    this.sincronizado = false,
  });

  // Getters for computed properties (already good)
  int get totalAtracciones => atraccionesVisitadas.length;

  double? get valoracionPromedioCalculado {
    final valoraciones = atraccionesVisitadas
        .where((v) => v.valoracion != null)
        .map((v) => v.valoracion!)
        .toList();

    if (valoraciones.isEmpty) return null;
    return valoraciones.reduce((a, b) => a + b) / valoraciones.length;
  }

  Duration? get tiempoTotalCalculado {
    if (atraccionesVisitadas.isEmpty) return null;

    final visitasFinalizadas = atraccionesVisitadas.where((v) => v.horaFin != null);
    if (visitasFinalizadas.isEmpty) return null;

    final primera = visitasFinalizadas.reduce(
            (a, b) => a.horaInicio.isBefore(b.horaInicio) ? a : b);
    final ultima = visitasFinalizadas.reduce(
            (a, b) => a.horaFin!.isAfter(b.horaFin!) ? a : b);

    return ultima.horaFin!.difference(primera.horaInicio);
  }

  ReporteDiarioEntity copyWith({
    String? id,
    String? userId,
    String? parqueId,
    String? parqueNombre,
    DateTime? fecha,
    DateTime? fechaFin,
    List<VisitaAtraccionEntity>? atraccionesVisitadas,
    Duration? tiempoTotalEnParque,
    String? notas,
    double? valoracionPromedio,
    bool? sincronizado,
  }) {
    return ReporteDiarioEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      parqueId: parqueId ?? this.parqueId,
      parqueNombre: parqueNombre ?? this.parqueNombre,
      fecha: fecha ?? this.fecha,
      fechaFin: fechaFin ?? this.fechaFin,
      atraccionesVisitadas: atraccionesVisitadas ?? this.atraccionesVisitadas,
      tiempoTotalEnParque: tiempoTotalEnParque ?? this.tiempoTotalEnParque,
      notas: notas ?? this.notas,
      valoracionPromedio: valoracionPromedio ?? this.valoracionPromedio,
      sincronizado: sincronizado ?? this.sincronizado,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    parqueId,
    parqueNombre,
    fecha,
    fechaFin,
    // Note: atraccionesVisitadas requires careful handling with Equatable
    // if you want changes within the list to trigger equality checks.
    // For simplicity with subcollections, we often don't include complex nested lists directly.
    // However, if your use case demands it, consider iterating through the list's IDs for comparison.
    // For now, it's included as is, assuming a new list instance implies change.
    atraccionesVisitadas,
    tiempoTotalEnParque,
    notas,
    valoracionPromedio,
    sincronizado,
  ];

  @override
  bool get stringify => true;
}