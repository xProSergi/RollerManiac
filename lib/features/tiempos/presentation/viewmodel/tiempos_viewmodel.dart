import 'package:flutter/material.dart';
import '../../domain/entities/parque.dart';
import '../../domain/entities/atraccion.dart';
import '../../domain/entities/clima.dart';
import '../../domain/repositories/parques_repository.dart';
import '../../domain/usecases/obtener_clima_por_ciudad.dart';
import '../../constantes/tiempos_constantes.dart';

class TiemposViewModel extends ChangeNotifier {
  final ParquesRepository repository;
  final ObtenerClimaPorCiudad obtenerClimaPorCiudad;

  TiemposViewModel({
    required this.repository,
    required this.obtenerClimaPorCiudad,
  });

  List<Parque> _parques = [];
  bool _cargando = false;
  String? _error;
  final Map<String, Clima> _datosClima = {};

  List<Parque> get parques => _parques;
  bool get cargando => _cargando;
  String? get error => _error;
  Clima? getClimaParaParque(String nombreParque) => _datosClima[nombreParque];

  Future<void> cargarParques() async {
    _setCargando(true);
    try {
      _parques = await repository.obtenerParques();
      await _cargarDatosClima();
    } catch (e) {
      _setError('${TiemposTextos.errorCargar}: $e');
    } finally {
      _setCargando(false);
    }
  }

  Future<List<Atraccion>> cargarAtracciones(String parqueId) async {
    try {
      return await repository.obtenerAtraccionesDeParque(parqueId);
    } catch (e) {
      _setError('${TiemposTextos.errorAtracciones}: $e');
      return [];
    }
  }

  Future<void> _cargarDatosClima() async {
    for (final parque in _parques) {
      try {
        final ciudadParaClima = obtenerCiudadParaClima(parque.nombre);
        final ciudadConsulta = ciudadParaClima.isNotEmpty ? ciudadParaClima : parque.ciudad;
        final clima = await obtenerClimaPorCiudad.ejecutar(ciudadConsulta);

        _datosClima[parque.nombre] = clima;

        _parques = _parques.map((p) {
          if (p.nombre == parque.nombre) {
            return Parque(
              id: p.id,
              nombre: p.nombre,
              pais: p.pais,
              ciudad: p.ciudad,
              atracciones: p.atracciones,
              clima: clima,
            );
          }
          return p;
        }).toList();
      } catch (e) {
        debugPrint('${TiemposTextos.errorCargar} ${parque.nombre}: $e');
      }
    }
    notifyListeners();
  }

  void _setCargando(bool value) {
    _cargando = value;
    notifyListeners();
  }

  void _setError(String mensaje) {
    _error = mensaje;
    notifyListeners();
  }


 // Esto lo he hecho porque no me devolvía la ciudad donde está el parque
  String obtenerCiudadParaClima(String nombreParque) {
    if (nombreParque == 'Parque Warner Madrid') {
      return 'San Martín de la Vega, Spain';
    } else if (nombreParque == 'PortAventura Park' || nombreParque == 'Ferrari Land') {
      return 'Salou, Tarragona, Spain';
    } else {
      return '';
    }
  }
}