import 'atraccion.dart';

class Parque {
  final String id;
  final String nombre;
  final String pais;
  final String ciudad;
  final String? imagenUrl;
  final List<Atraccion> atracciones;

  Parque({
    required this.id,
    required this.nombre,
    required this.pais,
    required this.ciudad,
    this.imagenUrl,
    this.atracciones = const [],
  });

  factory Parque.fromJson(Map<String, dynamic> json) {
    return Parque(
      id: json['id'].toString(),
      nombre: json['name'] ?? '',
      pais: json['country'] ?? '',
      ciudad: json['city'] ?? '',
      imagenUrl: json['image_url'],
    );
  }
}