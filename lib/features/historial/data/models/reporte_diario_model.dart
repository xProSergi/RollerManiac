import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/reporte_diario_entity.dart';
import '../../domain/entities/visita_atraccion_entity.dart';
import 'visita_atraccion_model.dart'; // Make sure this path is correct

class ReporteDiarioModel extends ReporteDiarioEntity {
  const ReporteDiarioModel({
    required String id,
    required String userId,
    required String parqueId,
    required String parqueNombre,
    required DateTime fecha,
    DateTime? fechaFin,
    required List<VisitaAtraccionEntity> atraccionesVisitadas,
    Duration? tiempoTotalEnParque,
    String? notas,
    double? valoracionPromedio,
    bool sincronizado = false,
  }) : super(
    id: id,
    userId: userId,
    parqueId: parqueId,
    parqueNombre: parqueNombre,
    fecha: fecha,
    fechaFin: fechaFin,
    atraccionesVisitadas: atraccionesVisitadas,
    tiempoTotalEnParque: tiempoTotalEnParque,
    notas: notas,
    valoracionPromedio: valoracionPromedio,
    sincronizado: sincronizado,
  );

  factory ReporteDiarioModel.fromJson(Map<String, dynamic> json) {
    return ReporteDiarioModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      parqueId: json['parqueId'] as String,
      parqueNombre: json['parqueNombre'] as String,
      fecha: (json['fecha'] as Timestamp).toDate(),
      fechaFin: json['fechaFin'] != null
          ? (json['fechaFin'] as Timestamp).toDate()
          : null,
      atraccionesVisitadas: [], // Initialize empty, repository will populate
      tiempoTotalEnParque: json['tiempoTotalEnParque'] != null
          ? Duration(seconds: json['tiempoTotalEnParque'] as int)
          : null,
      notas: json['notas'] as String?,
      valoracionPromedio: (json['valoracionPromedio'] as num?)?.toDouble(),
      sincronizado: json['sincronizado'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'parqueId': parqueId,
      'parqueNombre': parqueNombre,
      'fecha': Timestamp.fromDate(fecha),
      'fechaFin': fechaFin != null ? Timestamp.fromDate(fechaFin!) : null,
      'tiempoTotalEnParque': tiempoTotalEnParque?.inSeconds,
      'notas': notas,
      'valoracionPromedio': valoracionPromedio,
      'sincronizado': sincronizado,
    };
  }

  factory ReporteDiarioModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReporteDiarioModel(
      id: doc.id,
      userId: data['userId'] as String,
      parqueId: data['parqueId'] as String,
      parqueNombre: data['parqueNombre'] as String,
      fecha: (data['fecha'] as Timestamp).toDate(),
      fechaFin: data['fechaFin'] != null
          ? (data['fechaFin'] as Timestamp).toDate()
          : null,
      atraccionesVisitadas: [], // Se cargarán por separado
      tiempoTotalEnParque: data['tiempoTotalEnParque'] != null
          ? Duration(seconds: data['tiempoTotalEnParque'] as int)
          : null,
      notas: data['notas'] as String?,
      valoracionPromedio: (data['valoracionPromedio'] as num?)?.toDouble(),
      sincronizado: data['sincronizado'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'parqueId': parqueId,
      'parqueNombre': parqueNombre,
      'fecha': Timestamp.fromDate(fecha),
      'fechaFin': fechaFin != null ? Timestamp.fromDate(fechaFin!) : null,
      'tiempoTotalEnParque': tiempoTotalEnParque?.inSeconds,
      'notas': notas,
      'valoracionPromedio': valoracionPromedio,
      'sincronizado': sincronizado,
    };
  }

  factory ReporteDiarioModel.fromEntity(ReporteDiarioEntity entity) {
    return ReporteDiarioModel(
      id: entity.id,
      userId: entity.userId,
      parqueId: entity.parqueId,
      parqueNombre: entity.parqueNombre,
      fecha: entity.fecha,
      fechaFin: entity.fechaFin,
      atraccionesVisitadas: entity.atraccionesVisitadas
          .map((v) => VisitaAtraccionModel.fromEntity(v))
          .toList(),
      tiempoTotalEnParque: entity.tiempoTotalEnParque,
      notas: entity.notas,
      valoracionPromedio: entity.valoracionPromedio,
      sincronizado: entity.sincronizado,
    );
  }

  @override
  ReporteDiarioModel copyWith({
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
    return ReporteDiarioModel(
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
  ReporteDiarioEntity toEntity() {
    return ReporteDiarioEntity(
      id: id,
      userId: userId,
      parqueId: parqueId,
      parqueNombre: parqueNombre,
      fecha: fecha,
      fechaFin: fechaFin,
      atraccionesVisitadas: atraccionesVisitadas,
      tiempoTotalEnParque: tiempoTotalEnParque,
      notas: notas,
      valoracionPromedio: valoracionPromedio,
      sincronizado: sincronizado,
    );
  }
}