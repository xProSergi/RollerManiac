import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/atraccion.dart';
import '../../domain/entities/parque.dart';

abstract class ParquesRemoteDataSource {
  Future<List<Parque>> obtenerParques();
  Future<List<Atraccion>> obtenerAtraccionesDeParque(String parqueId);
}

class ParquesRemoteDataSourceImpl implements ParquesRemoteDataSource {
  final http.Client client;

  ParquesRemoteDataSourceImpl({required this.client});

  @override
  Future<List<Parque>> obtenerParques() async {
    try {
      final response = await client.get(Uri.parse('https://queue-times.com/parks.json'));
      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        final List<Parque> parques = [];

        final ciudadesPorNombre = {
          'Parque Warner Madrid': 'Madrid',
          'Parque de Atracciones Madrid': 'Madrid',
          'PortAventura Park': 'Tarragona',
          'Ferrari Land': 'Tarragona',
        };

        for (final grupo in data) {
          final List<dynamic>? subparques = grupo['parks'];
          if (subparques != null) {
            for (final parque in subparques) {
              try {
                if (parque['country']?.toString() == 'Spain') {
                  final id = parque['id']?.toString() ?? '0';
                  final nombre = parque['name']?.toString() ?? 'Sin nombre';
                  final pais = parque['country']?.toString() ?? 'Desconocido';
                  final ciudad = ciudadesPorNombre[nombre] ?? 'Desconocida';

                  parques.add(Parque(
                    id: id,
                    nombre: nombre,
                    pais: pais,
                    ciudad: ciudad,
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
        return parques;
      } else {
        throw Exception('Error al cargar los parques: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en obtenerParques: $e');
      return [];
    }
  }

  @override
  Future<List<Atraccion>> obtenerAtraccionesDeParque(String parqueId) async {
    try {
      final response = await client.get(
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
