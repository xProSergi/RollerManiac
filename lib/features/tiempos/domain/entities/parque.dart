import 'atraccion.dart';
import 'clima.dart';

class Parque {
  final String id;
  final String nombre;
  final String pais;
  final String ciudad;
  final List<Atraccion> atracciones;
  final Clima? clima;

  Parque({
    required this.id,
    required this.nombre,
    required this.pais,
    required this.ciudad,
    this.atracciones = const [],
    this.clima,
  });

  factory Parque.fromJson(Map<String, dynamic> json) {
    return Parque(
      id: json['id'].toString(),
      nombre: json['name'] ?? '',
      pais: json['country'] ?? '',
      ciudad: json['city'] ?? '',
    );
  }

  String get textoCiudadFormateado {
    final nombreLower = nombre.toLowerCase();

    if (nombreLower.contains('warner')) {
      return 'San Martín de la Vega, Spain';
    } else if (nombreLower.contains('portaventura') || nombreLower.contains('ferrari land')) {
      return 'Salou, Tarragona, Spain';
    } else {
      return '$ciudad, $pais';
    }
  }
}
