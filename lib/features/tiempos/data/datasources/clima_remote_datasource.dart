import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/clima.dart';

abstract class ClimaRemoteDataSource {
  Future<Clima> obtenerClimaPorCiudad(String ciudad);
}

class ClimaRemoteDataSourceImpl implements ClimaRemoteDataSource {
  final http.Client client;

  ClimaRemoteDataSourceImpl({required this.client});

  static const String _claveApi = 'c0f1b1a99e0e441aab4180138251405';
  static const String _urlBase = 'http://api.weatherapi.com/v1/current.json';

  @override
  Future<Clima> obtenerClimaPorCiudad(String ciudad) async {
    try {
      // Limpiar y codificar la ciudad para la URL
      final ciudadCodificada = Uri.encodeComponent(ciudad.trim());

      final respuesta = await client.get(
        Uri.parse('$_urlBase?key=$_claveApi&q=$ciudadCodificada&lang=es&aqi=no'),
      ).timeout(const Duration(seconds: 10));

      if (respuesta.statusCode == 200) {
        final data = json.decode(respuesta.body);

        // Verificar si hay error en la respuesta de la API
        if (data.containsKey('error')) {
          throw Exception('Error de la API del clima: ${data['error']['message']}');
        }

        return Clima.fromJsonWeatherAPI(data);
      } else if (respuesta.statusCode == 400) {
        throw Exception('Ciudad no encontrada: $ciudad');
      } else if (respuesta.statusCode == 401) {
        throw Exception('Error de autenticación con la API del clima');
      } else if (respuesta.statusCode == 429) {
        throw Exception('Límite de consultas excedido. Inténtalo más tarde.');
      } else {
        throw Exception('Error al obtener el clima: ${respuesta.statusCode}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error de conexión: $e');
    }
  }
}
