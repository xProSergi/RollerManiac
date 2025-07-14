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
  Future<Clima> obtenerClimaPorCiudad(String ciudadOcoords) async {
    try {
      String url;
      if (ciudadOcoords.startsWith('COORDS:')) {
        final coords = ciudadOcoords.replaceFirst('COORDS:', '').split(',');
        final lat = coords[0];
        final lon = coords[1];
        // Cambia aquí tu API KEY y la URL si usas OpenWeather
        url = 'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=8275d8318ca6f13de6e6a135e98240a6&units=metric&lang=es';
        final respuesta = await client.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
        if (respuesta.statusCode == 200) {
          final data = json.decode(respuesta.body);
          // Adaptar a tu modelo Clima
          return Clima(
            temperatura: data['main']['temp'].toDouble(),
            descripcion: data['weather'][0]['description'],
            codigoIcono: 'https://openweathermap.org/img/wn/${data['weather'][0]['icon']}@2x.png',
            ciudad: data['name'],
            ultimaActualizacion: DateTime.fromMillisecondsSinceEpoch(data['dt'] * 1000).toIso8601String(),
            esAntiguo: false,
          );
        } else {
          throw Exception('Error OpenWeather: ${respuesta.statusCode}');
        }
      } else {
        // Limpiar y codificar la ciudad para la URL
        final ciudadCodificada = Uri.encodeComponent(ciudadOcoords.trim());
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
          throw Exception('Ciudad no encontrada: $ciudadOcoords');
        } else if (respuesta.statusCode == 401) {
          throw Exception('Error de autenticación con la API del clima');
        } else if (respuesta.statusCode == 429) {
          throw Exception('Límite de consultas excedido. Inténtalo más tarde.');
        } else {
          throw Exception('Error al obtener el clima: ${respuesta.statusCode}');
        }
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error de conexión: $e');
    }
  }
}
