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
  final String? imagenUrl;  // <-- Nueva propiedad para la URL de la imagen

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
    this.imagenUrl,  // nullable
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
      atracciones: [], // o parsear si tienes datos
      clima: null,     // o parsear si tienes datos
      imagenUrl: json['imagenUrl'],  // puede ser null
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
      'imagenUrl': imagenUrl,
    };
  }

  String get textoCiudadFormateado {
    return ClimaUtils.obtenerCiudadParaClima(nombre, latitud, longitud, pais);
  }

  Parque copyWith({
    String? id,
    String? nombre,
    String? pais,
    String? ciudad,
    double? latitud,
    double? longitud,
    String? continente,
    List<Atraccion>? atracciones,
    Clima? clima,
    String? imagenUrl,
  }) {
    return Parque(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      pais: pais ?? this.pais,
      ciudad: ciudad ?? this.ciudad,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      continente: continente ?? this.continente,
      atracciones: atracciones ?? this.atracciones,
      clima: clima ?? this.clima,
      imagenUrl: imagenUrl ?? this.imagenUrl,
    );
  }
}
