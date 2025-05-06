import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/atraccion.dart';
import '../../domain/entities/parque.dart';
import '../../domain/repositories/parques_repository.dart';

class ParquesRepositoryImpl implements ParquesRepository {
  @override
  Future<List<Parque>> obtenerParques() async {
    try {
      final response = await http.get(Uri.parse('https://queue-times.com/parks.json'));
      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        final List<Parque> parques = [];

        for (final grupo in data) {
          final List<dynamic>? subparques = grupo['parks'];
          if (subparques != null) {
            for (final parque in subparques) {
              try {

                if (parque['country']?.toString() == 'Spain') {
                  final id = parque['id'] is int
                      ? parque['id'].toString()
                      : parque['id']?.toString() ?? '0';
                  final nombre = parque['name']?.toString() ?? 'Sin nombre';
                  final pais = parque['country']?.toString() ?? 'Desconocido';
                  final ciudad = parque['city']?.toString() ?? 'Desconocida';
                  final imagenUrl = parque['image_url']?.toString();

                  parques.add(Parque(
                    id: id,
                    nombre: nombre,
                    pais: pais,
                    ciudad: ciudad,
                    imagenUrl: imagenUrl,
                    atracciones: [],
                  ));
                }
              } catch (e) {
                print('Error procesando parque: $e');
              }
            }
          }
        }

        print('Parques de España encontrados: ${parques.length}');
        if (parques.isEmpty) {
          print('No se encontraron parques de España en la respuesta');
        }
        return parques;
      } else {
        throw Exception('Error al cargar los parques: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en obtenerParques: $e');
      rethrow;
    }
  }

  @override
  Future<List<Atraccion>> obtenerAtraccionesDeParque(int parqueId) async {
    try {
      final response = await http.get(
        Uri.parse('https://queue-times.com/parks/$parqueId/queue_times.json'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<Atraccion> atracciones = [];


        if (data.containsKey('rides') && data['rides'] is List) {
          for (final ride in data['rides']) {
            atracciones.add(Atraccion(
              nombre: ride['name']?.toString() ?? 'Sin nombre',
              tiempoEspera: ride['wait_time'] is int ? ride['wait_time'] : 0,
              operativa: ride['is_open'] == true,
            ));
          }
        }


        if (data.containsKey('lands') && data['lands'] is List) {
          for (final land in data['lands']) {
            final List<dynamic>? rides = land['rides'];
            if (rides != null) {
              for (final ride in rides) {
                atracciones.add(Atraccion(
                  nombre: ride['name']?.toString() ?? 'Sin nombre',
                  tiempoEspera: ride['wait_time'] is int ? ride['wait_time'] : 0,
                  operativa: ride['is_open'] == true,
                ));
              }
            }
          }
        }

        return atracciones;
      } else {
        print('Error al obtener atracciones para el parque $parqueId: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error en obtenerAtraccionesDeParque para el parque $parqueId: $e');
      return [];
    }
  }
}
