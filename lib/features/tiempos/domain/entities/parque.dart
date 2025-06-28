import '../../utils/clima_utils.dart';
import 'atraccion.dart';
import 'clima.dart';


class Parque {
  final String id;
  final String nombre;
  final String pais;
  final String ciudad;
  final double latitud;
  final double longitud;
  final String continente;
  final List<Atraccion> atracciones;
  final Clima? clima;

  Parque({
    required this.id,
    required this.nombre,
    required this.pais,
    required this.ciudad,
    required this.latitud,
    required this.longitud,
    required this.continente,
    this.atracciones = const [],
    this.clima,
  });

  factory Parque.fromJson(Map<String, dynamic> json) {
    return Parque(
      id: json['id'],
      nombre: json['nombre'],
      pais: json['pais'],
      ciudad: json['ciudad'],
      latitud: (json['latitud'] as num).toDouble(),
      longitud: (json['longitud'] as num).toDouble(),
      continente: json['continente'],
      atracciones: [],
      clima: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'pais': pais,
      'ciudad': ciudad,
      'latitud': latitud,
      'longitud': longitud,
      'continente': continente,
    };
  }

  String get textoCiudadFormateado {
    return ClimaUtils.obtenerCiudadParaClima(nombre, latitud, longitud, pais);
  }
}
