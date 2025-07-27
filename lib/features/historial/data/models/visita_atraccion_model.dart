import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart'; // No se utiliza directamente aquí, pero es común en el dominio
import '../../domain/entities/visita_atraccion_entity.dart';

class VisitaAtraccionModel extends VisitaAtraccionEntity {
  const VisitaAtraccionModel({
    required String id,
    required String reporteDiarioId,
    required String parqueId,
    required String parqueNombre,
    required String atraccionId,
    required String atraccionNombre,
    required String userId,
    required DateTime horaInicio,
    DateTime? horaFin,
    Duration? duracion,
    int? valoracion,
    String? notas,
    required DateTime fecha, // <-- AÑADIDO: Campo 'fecha' en el constructor
  }) : super(
    id: id,
    reporteDiarioId: reporteDiarioId,
    parqueId: parqueId,
    parqueNombre: parqueNombre,
    atraccionId: atraccionId,
    atraccionNombre: atraccionNombre,
    userId: userId,
    horaInicio: horaInicio,
    horaFin: horaFin,
    duracion: duracion,
    valoracion: valoracion,
    notas: notas,
    fecha: fecha, // <-- AÑADIDO: Pasando 'fecha' al super constructor
  );

  factory VisitaAtraccionModel.fromFirestore(
      DocumentSnapshot doc,
      // reporteDiarioId ya no se necesita aquí si lo traes de los datos del documento
      // o si la entidad ya lo tiene. Si lo necesitas para el fromFirestore,
      // el documento de la atracción debería tenerlo.
      // Vamos a asumir que el documento de la atracción contiene 'reporteDiarioId'.
      String reporteDiarioIdFromParam, // Se usa si el doc.data() no lo tiene directamente
      ) {
    final data = doc.data() as Map<String, dynamic>;
    return VisitaAtraccionModel(
      id: doc.id,
      // Usar el reporteDiarioId del documento si está disponible, o del parámetro
      reporteDiarioId: data['reporteDiarioId'] as String? ?? reporteDiarioIdFromParam,
      parqueId: data['parqueId'] as String,
      parqueNombre: data['parqueNombre'] as String,
      atraccionId: data['atraccionId'] as String,
      atraccionNombre: data['atraccionNombre'] as String,
      userId: data['userId'] as String,
      horaInicio: (data['horaInicio'] as Timestamp).toDate(), // <-- Usar 'horaInicio' si es el campo real
      horaFin: data['horaFin'] != null ? (data['horaFin'] as Timestamp).toDate() : null,
      duracion: data['duracion'] != null ? Duration(seconds: data['duracion'] as int) : null,
      valoracion: data['valoracion'] as int?,
      notas: data['notas'] as String?,
      fecha: (data['fecha'] as Timestamp).toDate(), // <-- AÑADIDO: Mapeando 'fecha' desde Firestore
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'reporteDiarioId': reporteDiarioId, // Asegurarse de que esté en el mapa
      'parqueId': parqueId,
      'parqueNombre': parqueNombre,
      'atraccionId': atraccionId,
      'atraccionNombre': atraccionNombre,
      'userId': userId,
      'horaInicio': Timestamp.fromDate(horaInicio), // <-- Usar 'horaInicio' para el campo
      'horaFin': horaFin != null ? Timestamp.fromDate(horaFin!) : null,
      'duracion': duracion?.inSeconds,
      'valoracion': valoracion,
      'notas': notas,
      'fecha': Timestamp.fromDate(fecha), // <-- AÑADIDO: Mapeando 'fecha' para Firestore
    };
  }

  factory VisitaAtraccionModel.fromEntity(VisitaAtraccionEntity entity) {
    return VisitaAtraccionModel(
      id: entity.id,
      reporteDiarioId: entity.reporteDiarioId,
      parqueId: entity.parqueId,
      parqueNombre: entity.parqueNombre,
      atraccionId: entity.atraccionId,
      atraccionNombre: entity.atraccionNombre,
      userId: entity.userId,
      horaInicio: entity.horaInicio,
      horaFin: entity.horaFin,
      duracion: entity.duracion,
      valoracion: entity.valoracion,
      notas: entity.notas,
      fecha: entity.fecha, // <-- AÑADIDO: Pasando 'fecha' desde la entidad
    );
  }

  @override
  VisitaAtraccionEntity toEntity() {
    return VisitaAtraccionEntity(
      id: id,
      reporteDiarioId: reporteDiarioId,
      parqueId: parqueId,
      parqueNombre: parqueNombre,
      atraccionId: atraccionId,
      atraccionNombre: atraccionNombre,
      userId: userId,
      horaInicio: horaInicio,
      horaFin: horaFin,
      duracion: duracion,
      valoracion: valoracion,
      notas: notas,
      fecha: fecha, // <-- AÑADIDO: Pasando 'fecha' a la entidad
    );
  }

  @override
  VisitaAtraccionModel copyWith({
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
    DateTime? fecha, // <-- AÑADIDO: Campo 'fecha' en copyWith
  }) {
    return VisitaAtraccionModel(
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
      fecha: fecha ?? this.fecha, // <-- AÑADIDO: Usando 'fecha' en copyWith
    );
  }
}