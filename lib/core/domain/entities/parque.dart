import 'atraccion.dart';


class Parque {
  final String nombre;
  final int id;
  final List<Atraccion> atracciones;

  Parque({required this.nombre, required this.id, this.atracciones = const []});
}

