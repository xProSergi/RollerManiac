import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/atraccion.dart';
import '../../domain/entities/parque.dart';
import '../../utils/parque_utils.dart';

abstract class ParquesRemoteDataSource {
  Future<List<Parque>> obtenerParques();
  Future<List<Atraccion>> obtenerAtraccionesDeParque(String parqueId);
  Future<List<Parque>> obtenerParquesPaginados({Parque? ultimoParque, int limite});
}

class ParquesRemoteDataSourceImpl implements ParquesRemoteDataSource {
  final http.Client client;

  ParquesRemoteDataSourceImpl({required this.client});

  @override
  Future<List<Parque>> obtenerParques() async {
    try {
      final response = await client.get(Uri.parse('https://queue-times.com/parks.json'));
      print('Response status: [32m[1m${response.statusCode}[0m');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        final List<Parque> parques = [];

        for (final grupo in data) {
          final List<dynamic>? subparques = grupo['parks'];
          if (subparques != null) {
            for (final parque in subparques) {
              try {
                final id = parque['id']?.toString() ?? '0';
                final nombre = parque['name']?.toString() ?? 'Sin nombre';
                final pais = parque['country']?.toString() ?? 'Desconocido';
                final ciudad = '';
                final lat = double.tryParse(parque['latitude']?.toString() ?? '') ?? 0.0;
                final lon = double.tryParse(parque['longitude']?.toString() ?? '') ?? 0.0;
                final continente = obtenerContinente(pais);

                parques.add(Parque(
                  id: id,
                  nombre: nombre,
                  pais: pais,
                  ciudad: ciudad,
                  latitud: lat,
                  longitud: lon,
                  continente: continente,
                  atracciones: [],
                ));
              } catch (e) {
                print('Error procesando parque: $e');
              }
            }
          }
        }

        print('Parques encontrados: [34m${parques.length}[0m');
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
  @override
  Future<List<Parque>> obtenerParquesPaginados({Parque? ultimoParque, int limite = 10}) async {
    try {
      final response = await client.get(Uri.parse('https://queue-times.com/parks.json'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        final List<Parque> parques = [];

        for (final grupo in data) {
          final List<dynamic>? subparques = grupo['parks'];
          if (subparques != null) {
            for (final parque in subparques) {
              final id = parque['id']?.toString() ?? '0';
              final nombre = parque['name']?.toString() ?? 'Sin nombre';
              final pais = parque['country']?.toString() ?? 'Desconocido';
              final ciudad = '';
              final lat = double.tryParse(parque['latitude']?.toString() ?? '') ?? 0.0;
              final lon = double.tryParse(parque['longitude']?.toString() ?? '') ?? 0.0;
              final continente = obtenerContinente(pais);

              parques.add(Parque(
                id: id,
                nombre: nombre,
                pais: pais,
                ciudad: ciudad,
                latitud: lat,
                longitud: lon,
                continente: continente,
                atracciones: [],
              ));
            }
          }
        }

        // Ordenamos por nombre para tener un criterio consistente
        parques.sort((a, b) => a.nombre.compareTo(b.nombre));

        // Si no hay último parque, devuelve los primeros N
        if (ultimoParque == null) {
          return parques.take(limite).toList();
        }

        // Buscar índice del último parque
        final indexUltimo = parques.indexWhere((p) => p.id == ultimoParque.id);

        if (indexUltimo == -1 || indexUltimo + 1 >= parques.length) {
          return [];
        }

        // Tomar el siguiente bloque después del último parque
        final startIndex = indexUltimo + 1;
        final endIndex = (startIndex + limite) > parques.length ? parques.length : (startIndex + limite);

        return parques.sublist(startIndex, endIndex);
      } else {
        throw Exception('Error al cargar los parques: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en obtenerParquesPaginados: $e');
      return [];
    }
  }


}
