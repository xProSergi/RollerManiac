import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/visita_entity.dart';

class VisitaModel extends VisitaEntity {
  const VisitaModel({
    required String id,
    required String parqueId,
    required String parqueNombre,
    String? atraccionNombre,
    required DateTime fecha,
    required String userId,
  }) : super(
    id: id,
    parqueId: parqueId,
    parqueNombre: parqueNombre,
    atraccionNombre: atraccionNombre,
    fecha: fecha,
    userId: userId,
  );

  factory VisitaModel.fromJson(Map<String, dynamic> json) {
    final dynamic fechaData = json['fecha'];
    final DateTime fecha;

    if (fechaData is Timestamp) {
      fecha = fechaData.toDate();
    } else if (fechaData is String) {
      fecha = DateTime.parse(fechaData);
    } else {
      throw Exception('Formato de fecha no válido');
    }

    return VisitaModel(
      id: json['id']?.toString() ?? '', // Asegura conversión a String
      parqueId: json['parqueId']?.toString() ?? '', // Asegura conversión a String
      parqueNombre: json['parqueNombre']?.toString() ?? '', // Asegura conversión a String
      atraccionNombre: json['atraccionNombre']?.toString(), // Asegura conversión a String
      fecha: fecha,
      userId: json['userId']?.toString() ?? '', // Asegura conversión a String
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parqueId': parqueId,
      'parqueNombre': parqueNombre,
      'atraccionNombre': atraccionNombre,
      'fecha': Timestamp.fromDate(fecha),
      'userId': userId,
    };
  }
}