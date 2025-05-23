import 'package:cloud_firestore/cloud_firestore.dart';

class SolicitudAmistad {
  final String id;
  final String email;
  final String nombre;
  final String displayName;
  final String username;
  final DateTime? fecha;

  SolicitudAmistad({
    required this.id,
    required this.email,
    required this.nombre,
    required this.displayName,
    required this.username,
    required this.fecha,
  });
}