// features/historial/data/models/visita_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/visita_entity.dart';

class VisitaModel extends VisitaEntity {
  const VisitaModel({
    required String id,
    required String parqueId,
    required String parqueNombre,
    String? atraccionId,
    String? atraccionNombre,
    required DateTime fecha,
    required String userId,
    required TipoVisita tipo,
    Duration? duracion,
    String? notas,
    String? reporteDiarioId,
  }) : super(
    id: id,
    parqueId: parqueId,
    parqueNombre: parqueNombre,
    atraccionId: atraccionId,
    atraccionNombre: atraccionNombre,
    fecha: fecha,
    userId: userId,
    tipo: tipo,
    duracion: duracion,
    notas: notas,
    reporteDiarioId: reporteDiarioId,
  );

  factory VisitaModel.fromJson(Map<String, dynamic> json) {
    return VisitaModel(
      id: json['id'] as String,
      parqueId: json['parqueId'] as String,
      parqueNombre: json['parqueNombre'] as String,
      atraccionId: json['atraccionId'] as String?,
      atraccionNombre: json['atraccionNombre'] as String?,
      fecha: (json['fecha'] as Timestamp).toDate(),
      userId: json['userId'] as String,
      tipo: TipoVisita.values.firstWhere(
            (e) => e.toString() == 'TipoVisita.${json['tipo']}',
        orElse: () => TipoVisita.parque,
      ),
      duracion: json['duracion'] != null
          ? Duration(seconds: json['duracion'] as int)
          : null,
      notas: json['notas'] as String?,
      reporteDiarioId: json['reporteDiarioId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parqueId': parqueId,
      'parqueNombre': parqueNombre,
      'atraccionId': atraccionId,
      'atraccionNombre': atraccionNombre,
      'fecha': Timestamp.fromDate(fecha),
      'userId': userId,
      'tipo': tipo.toString().split('.').last,
      'duracion': duracion?.inSeconds,
      'notas': notas,
      'reporteDiarioId': reporteDiarioId,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      // 'id': id, // Consider if you need to store the ID as a field or rely on doc.id
      'parqueId': parqueId,
      'parqueNombre': parqueNombre,
      'atraccionId': atraccionId,
      'atraccionNombre': atraccionNombre,
      'fecha': Timestamp.fromDate(fecha),
      'userId': userId,
      'tipo': tipo.toString().split('.').last,
      'duracion': duracion?.inSeconds,
      'notas': notas,
      'reporteDiarioId': reporteDiarioId,
    };
  }

  factory VisitaModel.fromEntity(VisitaEntity entity) {
    return VisitaModel(
      id: entity.id,
      parqueId: entity.parqueId,
      parqueNombre: entity.parqueNombre,
      atraccionId: entity.atraccionId,
      atraccionNombre: entity.atraccionNombre,
      fecha: entity.fecha,
      userId: entity.userId,
      tipo: entity.tipo,
      duracion: entity.duracion,
      notas: entity.notas,
      reporteDiarioId: entity.reporteDiarioId,
    );
  }

  @override
  VisitaEntity toEntity() {
    return VisitaEntity(
      id: id,
      parqueId: parqueId,
      parqueNombre: parqueNombre,
      atraccionId: atraccionId,
      atraccionNombre: atraccionNombre,
      fecha: fecha,
      userId: userId,
      tipo: tipo,
      duracion: duracion,
      notas: notas,
      reporteDiarioId: reporteDiarioId,
    );
  }
}