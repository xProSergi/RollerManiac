import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/parque.dart';
import '../../domain/entities/atraccion.dart';
import '../../domain/entities/clima.dart';
import '../../domain/repositories/parques_repository.dart';
import '../../domain/usecases/obtener_clima_por_ciudad.dart';
import '../../constantes/tiempos_constantes.dart';
import '../../utils/clima_utils.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/parque_utils.dart';
import 'package:geolocator/geolocator.dart';
import 'package:collection/collection.dart';

class TiemposViewModel extends ChangeNotifier {
  final ParquesRepository repository;
  final ObtenerClimaPorCiudad obtenerClimaPorCiudad;

  TiemposViewModel({
    required this.repository,
    required this.obtenerClimaPorCiudad,
  });

  List<Parque> _todosLosParques = [];
  List<Parque> _parquesFiltrados = [];
  List<Parque> _parquesCargados = [];
  bool _cargando = false;
  bool cargandoMas = false;
  bool hayMasParques = false;
  Parque? ultimoParque;
  String? _error;
  final Map<String, Clima> _datosClima = {};
  String _continenteActual = 'Europa';
  String _ordenActual = 'Alfabético';
  Set<String> _favoritos = {};
  Position? _posicionUsuario;


  static const int _parquesPorPagina = 6;
  int _paginaActual = 0;
  bool _hayMasParques = true;


  final Map<String, Parque> _parquesConClimaCache = {};
  final Map<String, double> _distanciaCache = {};
  String _ultimaBusqueda = '';
  List<Parque> _ultimosParquesFiltrados = [];

  List<Parque> get parques => _parquesCargados;
  bool get cargando => _cargando;

  String? get error => _error;
  Clima? getClimaParaParque(String nombreParque) => _datosClima[nombreParque];
  String get continenteActual => _continenteActual;
  String get ordenActual => _ordenActual;
  Set<String> get favoritos => _favoritos;
  Position? get posicionUsuario => _posicionUsuario;


  Parque getParqueConClima(String parqueId) {

    if (_parquesConClimaCache.containsKey(parqueId)) {
      return _parquesConClimaCache[parqueId]!;
    }

    final parque = _todosLosParques.firstWhere((p) => p.id == parqueId);
    final clima = _datosClima[parque.nombre];

    final parqueConClima = Parque(
      id: parque.id,
      nombre: parque.nombre,
      pais: parque.pais,
      ciudad: parque.ciudad,
      latitud: parque.latitud,
      longitud: parque.longitud,
      continente: parque.continente,
      atracciones: parque.atracciones,
      clima: clima,
    );


    _parquesConClimaCache[parqueId] = parqueConClima;

    return parqueConClima;
  }

  Future<void> cargarParques() async {
    _setCargando(true);
    _error = null;

    try {
      // 1. Intentar cargar desde caché
      final prefs = await SharedPreferences.getInstance();
      final parquesCache = prefs.getString('parques_cache');

      if (parquesCache != null) {
        final List<dynamic> decoded = jsonDecode(parquesCache);
        _todosLosParques = decoded.map((e) => Parque.fromJson(e)).toList();
        _filtrarPorContinente(_continenteActual);
        _ordenarParques();
        _reiniciarPaginacion();
        await cargarMasParques();
      }

      // 2. Intentar cargar desde la API
      final parquesNuevos = await repository.obtenerParques();
      if (parquesNuevos.isNotEmpty) {
        _todosLosParques = parquesNuevos;
        _filtrarPorContinente(_continenteActual);
        _ordenarParques();
        _reiniciarPaginacion();
        await cargarMasParques();

        // Guardar en caché
        final parquesJson = jsonEncode(parquesNuevos.map((e) => e.toJson()).toList());
        await prefs.setString('parques_cache', parquesJson);
      } else if (_todosLosParques.isEmpty) {
        _setError('No se encontraron parques disponibles');
      }
    } catch (e) {
      _setError('Error al cargar parques: ${e.toString()}');
      if (_todosLosParques.isEmpty) {
        // Intentar cargar desde un backup si existe
        await _cargarParquesDeBackup();
      }
    } finally {
      _setCargando(false);
    }
  }

  Future<void> _cargarParquesDeBackup() async {
    try {
      final response = await rootBundle.loadString('assets/backup_parques.json');
      final List<dynamic> decoded = jsonDecode(response);
      _todosLosParques = decoded.map((e) => Parque.fromJson(e)).toList();

      if (_todosLosParques.isNotEmpty) {
        _filtrarPorContinente(_continenteActual);
        _ordenarParques();
        _reiniciarPaginacion();
        await cargarMasParques();
      }
    } catch (e) {
      _setError('No se pudieron cargar los parques');
    }
  }

  Future<void> cargarFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    _favoritos = prefs.getStringList('parques_favoritos')?.toSet() ?? {};


    await limpiarCacheNoFavoritos();


    if (_favoritos.isNotEmpty && _todosLosParques.isNotEmpty) {
      debugPrint('Cargando clima de ${_favoritos.length} favoritos existentes');
      await cargarClimaFavoritos();
    }

    notifyListeners();
  }

  Future<void> toggleFavorito(String parqueId) async {
    final prefs = await SharedPreferences.getInstance();
    final parque = _todosLosParques.firstWhere((p) => p.id == parqueId);

    if (_favoritos.contains(parqueId)) {
      _favoritos.remove(parqueId);

      _datosClima.remove(parque.nombre);

      _parquesConClimaCache.remove(parqueId);
    } else {
      _favoritos.add(parqueId);

      await cargarClimaParaParque(parque.id, parque.nombre, parque.latitud, parque.longitud, parque.pais);
    }

    await prefs.setStringList('parques_favoritos', _favoritos.toList());
    await guardarClimaCache();
    notifyListeners();
  }


  Future<void> limpiarCacheNoFavoritos() async {
    final parquesAConservar = <String>{};

    // Obtener nombres de parques favoritos
    for (final parqueId in _favoritos) {
      final parque = _todosLosParques.firstWhere((p) => p.id == parqueId);
      parquesAConservar.add(parque.nombre);
    }


    final parquesARemover = <String>[];
    for (final entry in _datosClima.entries) {
      if (!parquesAConservar.contains(entry.key)) {
        parquesARemover.add(entry.key);
      }
    }

    for (final nombre in parquesARemover) {
      _datosClima.remove(nombre);
    }


    _parquesConClimaCache.clear();


    await guardarClimaCache();
  }

  bool esFavorito(String parqueId) => _favoritos.contains(parqueId);

  // En TiemposViewModel
  Future<void> cambiarContinente(String continente) async {
    if (_continenteActual == continente && _parquesCargados.isNotEmpty) return;

    _setCargando(true);
    _continenteActual = continente;

    try {
      _filtrarPorContinente(continente);

      // Si no hay parques, verificar si es porque no hay datos para ese continente
      if (_parquesFiltrados.isEmpty) {
        // 1. Verificar si tenemos todos los parques cargados
        if (_todosLosParques.isEmpty) {
          await cargarParques();
        }

        // 2. Filtrar nuevamente después de cargar
        _filtrarPorContinente(continente);

        // 3. Si sigue vacío, mostrar mensaje
        if (_parquesFiltrados.isEmpty) {
          _setError('No hay parques disponibles en $continente');
        }
      }

      _ordenarParques();
      _reiniciarPaginacion();
      await cargarMasParques();
    } catch (e) {
      _setError('Error al cambiar continente: ${e.toString()}');
    } finally {
      _setCargando(false);
    }
  }

  Future<void> cambiarOrden(String nuevoOrden) async {
    if (_ordenActual == nuevoOrden) return;

    _ordenActual = nuevoOrden;

    _filtrarPorContinente(_continenteActual);
    if (nuevoOrden == 'Cercanía') {
      await obtenerPosicionUsuario();
      if (_posicionUsuario != null) {
        _ordenarParques(userLat: _posicionUsuario!.latitude, userLon: _posicionUsuario!.longitude);
      }
    } else {
      _ordenarParques();
    }
    _reiniciarPaginacion();
    await cargarMasParques();
    notifyListeners();
  }

  void _filtrarPorContinente(String continente) {
    _parquesFiltrados = _todosLosParques
        .where((p) => p.continente == continente)
        .toList();
  }

  void _ordenarParques({double? userLat, double? userLon}) {

    if (_ordenActual == 'Alfabético') {
      _parquesFiltrados.sort((a, b) => a.nombre.compareTo(b.nombre));
    } else if (_ordenActual == 'Cercanía' && _posicionUsuario != null) {
      _parquesFiltrados.sort((a, b) {
        final distA = calcularDistancia(_posicionUsuario!.latitude, _posicionUsuario!.longitude, a.latitud, a.longitud);
        final distB = calcularDistancia(_posicionUsuario!.latitude, _posicionUsuario!.longitude, b.latitud, b.longitud);
        return distA.compareTo(distB);
      });
    } else if (_ordenActual == 'Favoritos') {
      _parquesFiltrados = _parquesFiltrados.where((p) => _favoritos.contains(p.id)).toList();
    }
  }

  List<Parque> filtrarPorBusqueda(String busqueda) {

    if (busqueda == _ultimaBusqueda && _ultimosParquesFiltrados.isNotEmpty) {
      return _ultimosParquesFiltrados;
    }

    List<Parque> resultado;

    if (busqueda.isEmpty || busqueda.length < 3) {

      resultado = _parquesCargados;
    } else {

      final busquedaLower = busqueda.toLowerCase();
      resultado = _parquesCargados.where((p) =>
      p.nombre.toLowerCase().contains(busquedaLower) ||
          (p.ciudad.isNotEmpty && p.ciudad.toLowerCase().contains(busquedaLower)) ||
          p.pais.toLowerCase().contains(busquedaLower)
      ).toList();
    }


    _ultimaBusqueda = busqueda;
    _ultimosParquesFiltrados = resultado;

    return resultado;
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

    notifyListeners();
  }


  bool necesitaCargarClima(String parqueId) {
    final parque = _todosLosParques.firstWhereOrNull((p) => p.id == parqueId);
    if (parque == null) return false; // El parque no existe

    final clima = _datosClima[parque.nombre];

    // Si no hay datos de clima, o el clima es antiguo, o hubo un error al cargar
    return clima == null || clima.esAntiguo || clima.descripcion == 'Error al cargar';
  }


  Future<void> cargarClimaParaParque(String parqueId, String nombreParque, double latitud, double longitud, String pais) async {
    // Solo cargar clima si el parque está en favoritos
    final parque = _todosLosParques.firstWhere((p) => p.nombre == nombreParque);

    if (!_favoritos.contains(parque.id)) {
      return;
    }


    if (_datosClima.containsKey(nombreParque)) {
      return;
    }

    try {
      final ciudadConsulta = ClimaUtils.obtenerCiudadParaClima(nombreParque, latitud, longitud, pais);

      if (ciudadConsulta.isNotEmpty) {
        final clima = await obtenerClimaPorCiudad.ejecutar(ciudadConsulta);
        _datosClima[nombreParque] = clima;


        _parquesConClimaCache.remove(parque.id);


        await guardarClimaCache();


        notifyListeners();
        return;
      }
    } catch (e) {
      // Si hay error, crea un clima de error para evitar que se quede cargando indefinidamente
      final climaError = Clima(
        temperatura: 0.0,
        descripcion: 'Error al cargar',
        codigoIcono: '/122.png',
        ciudad: 'Error',
        ultimaActualizacion: DateTime.now().toIso8601String(),
        esAntiguo: false,
      );
      _datosClima[nombreParque] = climaError;
      _parquesConClimaCache.remove(parque.id);
      notifyListeners();
    }
  }


  Future<void> cargarClimaFavoritos() async {
    for (final parqueId in _favoritos) {
      final parque = _todosLosParques.firstWhere((p) => p.id == parqueId);
      await cargarClimaParaParque(parque.id, parque.nombre, parque.latitud, parque.longitud, parque.pais);

      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  Future<void> guardarClimaCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final climaMap = <String, dynamic>{};
      _datosClima.forEach((key, clima) {
        climaMap[key] = {
          'temperatura': clima.temperatura,
          'descripcion': clima.descripcion,
          'codigoIcono': clima.codigoIcono,
          'ciudad': clima.ciudad,
          'ultimaActualizacion': clima.ultimaActualizacion,
        };
      });
      await prefs.setString('clima_cache', jsonEncode(climaMap));
      await prefs.setInt('clima_cache_timestamp', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {

    }
  }


  Future<void> forzarActualizarClima(String parqueId) async {
    final parque = _todosLosParques.firstWhere((p) => p.id == parqueId);

    _datosClima.remove(parque.nombre);
    _parquesConClimaCache.remove(parqueId);
    await cargarClimaParaParque(parque.id, parque.nombre, parque.latitud, parque.longitud, parque.pais);
    notifyListeners();
  }

  Future<void> cargarClimaCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final climaCache = prefs.getString('clima_cache');
      final ultimaActualizacion = prefs.getInt('clima_cache_timestamp') ?? 0;
      final ahora = DateTime.now().millisecondsSinceEpoch;

      // Verifica si el cache es antiguo
      final esCacheAntiguo = ahora - ultimaActualizacion > 1800000; // 30 minutos

      if (climaCache != null) {
        final Map<String, dynamic> decoded = jsonDecode(climaCache);
        for (final entry in decoded.entries) {
          final climaData = entry.value as Map<String, dynamic>;
          _datosClima[entry.key] = Clima(
            temperatura: climaData['temperatura'].toDouble(),
            descripcion: climaData['descripcion'],
            codigoIcono: climaData['codigoIcono'],
            ciudad: climaData['ciudad'],
            ultimaActualizacion: climaData['ultimaActualizacion'],
            esAntiguo: esCacheAntiguo,
          );
        }
        // Si el cache es antiguo, actualizar TODOS los parques filtrados
        if (esCacheAntiguo) {
          for (final parque in _parquesFiltrados) {
            await forzarActualizarClima(parque.id);
            await Future.delayed(const Duration(milliseconds: 200));
          }
        }
      }
    } catch (e) {

    }
  }

  void _setCargando(bool value) {
    _cargando = value;
    notifyListeners();
  }

  void _setError(String mensaje) {
    _error = mensaje;
    notifyListeners();
  }

  Future<void> obtenerPosicionUsuario() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('La localización está desactivada');
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permiso de localización denegado');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permiso de localización denegado permanentemente');
      }
      _posicionUsuario = await Geolocator.getCurrentPosition();
      notifyListeners();
    } catch (e) {

    }
  }


  // En TiemposViewModel
  Future<void> cargarMasParques() async {
    if (cargandoMas || !hayMasParques) return;

    cargandoMas = true;
    notifyListeners();

    try {
      final nuevosParques = await repository.obtenerParquesPaginados(ultimoParque: ultimoParque);





      if (nuevosParques.isEmpty) {
        hayMasParques = false;
      } else {
        parques.addAll(nuevosParques);
        ultimoParque = nuevosParques.last;

        // ⚠️ Solo hay más si llegaron exactamente 10
        if (nuevosParques.length < 10) {
          hayMasParques = false;
        }
      }
    } catch (e) {
      print("Error al cargar más parques: $e");
    }

    cargandoMas = false;
    notifyListeners();
  }

  void _reiniciarPaginacion() {
    _paginaActual = 0;
    _parquesCargados.clear();
    _hayMasParques = _parquesFiltrados.isNotEmpty;
    notifyListeners();
  }




  void _limpiarCache() {
    _parquesConClimaCache.clear();
    _distanciaCache.clear();
    _ultimaBusqueda = '';
    _ultimosParquesFiltrados.clear();
  }
}