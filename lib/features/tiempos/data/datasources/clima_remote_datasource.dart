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
    final respuesta = await client.get(
      Uri.parse('$_urlBase?key=$_claveApi&q=$ciudad&lang=es'),
    );

    if (respuesta.statusCode == 200) {
      return Clima.fromJsonWeatherAPI(json.decode(respuesta.body));
    } else {
      throw Exception('Error al obtener el clima: ${respuesta.statusCode}');
    }
  }
}
