
import '../../domain/entities/solicitud_amistad.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SolicitudAmistadModel extends SolicitudAmistad {
  SolicitudAmistadModel({
    required super.id,
    required super.email,
    required super.nombre,
    required super.displayName,
    required super.username,
    required super.fecha,
  });

  factory SolicitudAmistadModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime? parsedDate;
    final dynamic fechaData = map['fecha'];

    if (fechaData is Timestamp) {
      parsedDate = fechaData.toDate();
    } else if (fechaData is String) {

      try {
        parsedDate = DateTime.parse(fechaData);
      } catch (e) {
        print('Error parseando la fecha "$fechaData": $e');
        parsedDate = null;
      }
    } else {

      parsedDate = null;
    }

    return SolicitudAmistadModel(
      id: id,
      email: map['email'] ?? '',
      nombre: map['nombre'] ?? '',
      displayName: map['displayName'] ?? '',
      username: map['username'] ?? '',
      fecha: parsedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'nombre': nombre,
      'displayName': displayName,
      'username': username,
      'fecha': fecha != null ? Timestamp.fromDate(fecha!) : null,
    };
  }
}