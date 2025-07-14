import 'package:flutter/material.dart';
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

class TiemposViewModel extends ChangeNotifier {
  final ParquesRepository repository;
  final ObtenerClimaPorCiudad obtenerClimaPorCiudad;

  TiemposViewModel({
    required this.repository,
    required this.obtenerClimaPorCiudad,
  });

  List<Parque> _todosLosParques = [];
  List<Parque> _parquesFiltrados = [];
  List<Parque> _parquesCargados = []; // Lista de parques cargados para lazy loading
  bool _cargando = false;
  bool _cargandoMas = false; // Para indicar cuando se están cargando más parques
  String? _error;
  final Map<String, Clima> _datosClima = {};
  String _continenteActual = 'Europa';
  String _ordenActual = 'Alfabético';
  Set<String> _favoritos = {};
  Position? _posicionUsuario;

  // Variables para lazy loading
  static const int _parquesPorPagina = 6; // Reducido de 8 a 6 para mejor rendimiento
  int _paginaActual = 0;
  bool _hayMasParques = true;

  // Cache para optimizar rendimiento
  final Map<String, Parque> _parquesConClimaCache = {};
  final Map<String, double> _distanciaCache = {};
  String _ultimaBusqueda = '';
  List<Parque> _ultimosParquesFiltrados = [];

  List<Parque> get parques => _parquesCargados;
  bool get cargando => _cargando;
  bool get cargandoMas => _cargandoMas;
  String? get error => _error;
  Clima? getClimaParaParque(String nombreParque) => _datosClima[nombreParque];
  String get continenteActual => _continenteActual;
  String get ordenActual => _ordenActual;
  Set<String> get favoritos => _favoritos;
  Position? get posicionUsuario => _posicionUsuario;
  bool get hayMasParques => _hayMasParques;

  // Getter para obtener un parque con clima actualizado (optimizado con cache)
  Parque getParqueConClima(String parqueId) {
    // Usar cache si está disponible
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

    // Guardar en cache
    _parquesConClimaCache[parqueId] = parqueConClima;

    return parqueConClima;
  }

  Future<void> cargarParques() async {
    bool cacheMostrado = false;
    _setCargando(true);
    await cargarClimaCache(); // Cargar cache del clima
    try {
      final prefs = await SharedPreferences.getInstance();
      final parquesCache = prefs.getString('parques_cache');
      if (parquesCache != null) {
        final List<dynamic> decoded = jsonDecode(parquesCache);
        _todosLosParques = decoded.map((e) => Parque.fromJson(e)).toList();
        _filtrarPorContinente(_continenteActual);
        _ordenarParques();
        _reiniciarPaginacion(); // Reiniciar paginación
        await cargarMasParques(); // Cargar primera página
        _setCargando(false);
        cacheMostrado = true;
      }

      final parquesNuevos = await repository.obtenerParques();
      _todosLosParques = parquesNuevos;
      _filtrarPorContinente(_continenteActual);
      _ordenarParques();
      _reiniciarPaginacion(); // Reiniciar paginación
      await cargarMasParques(); // Cargar primera página

      final parquesJson = jsonEncode(parquesNuevos.map((e) => e.toJson()).toList());
      await prefs.setString('parques_cache', parquesJson);
      notifyListeners();

      // Cargar favoritos después de cargar los parques
      await cargarFavoritos();
    } catch (e) {
      _setError('${TiemposTextos.errorCargar}: $e');
      if (!cacheMostrado) _setCargando(false);
    } finally {
      if (!cacheMostrado) _setCargando(false);
    }
  }

  Future<void> cargarFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    _favoritos = prefs.getStringList('parques_favoritos')?.toSet() ?? {};

    // Limpiar cache de parques que ya no son favoritos
    await limpiarCacheNoFavoritos();

    // Cargar clima de favoritos existentes después de cargar la lista
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
      // Remover clima del cache si ya no es favorito
      _datosClima.remove(parque.nombre);
      // Limpiar cache del parque
      _parquesConClimaCache.remove(parqueId);
    } else {
      _favoritos.add(parqueId);
      // Cargar clima automáticamente cuando se agrega a favoritos
      await cargarClimaParaParque(parque.nombre, parque.latitud, parque.longitud, parque.pais);
    }

    await prefs.setStringList('parques_favoritos', _favoritos.toList());
    await guardarClimaCache(); // Guardar cache actualizado
    notifyListeners();
  }

  // Función para limpiar cache de parques que ya no son favoritos - optimizada
  Future<void> limpiarCacheNoFavoritos() async {
    final parquesAConservar = <String>{};

    // Obtener nombres de parques favoritos
    for (final parqueId in _favoritos) {
      final parque = _todosLosParques.firstWhere((p) => p.id == parqueId);
      parquesAConservar.add(parque.nombre);
    }

    // Remover del cache los parques que ya no son favoritos
    final parquesARemover = <String>[];
    for (final entry in _datosClima.entries) {
      if (!parquesAConservar.contains(entry.key)) {
        parquesARemover.add(entry.key);
      }
    }

    for (final nombre in parquesARemover) {
      _datosClima.remove(nombre);
    }

    // Limpiar cache de parques con clima
    _parquesConClimaCache.clear();

    // Guardar cache limpio
    await guardarClimaCache();
  }

  bool esFavorito(String parqueId) => _favoritos.contains(parqueId);

  void cambiarContinente(String continente) {
    if (_continenteActual == continente) return; // No hacer nada si es el mismo continente

    _continenteActual = continente;
    _filtrarPorContinente(continente);
    _ordenarParques();
    _reiniciarPaginacion(); // Reiniciar paginación
    cargarMasParques(); // Cargar primera página
    notifyListeners();
  }

  Future<void> cambiarOrden(String nuevoOrden) async {
    if (_ordenActual == nuevoOrden) return; // No hacer nada si es el mismo orden

    _ordenActual = nuevoOrden;
    // Restaurar la lista filtrada por continente ANTES de ordenar
    _filtrarPorContinente(_continenteActual);
    if (nuevoOrden == 'Cercanía') {
      await obtenerPosicionUsuario();
      if (_posicionUsuario != null) {
        _ordenarParques(userLat: _posicionUsuario!.latitude, userLon: _posicionUsuario!.longitude);
      }
    } else {
      _ordenarParques();
    }
    _reiniciarPaginacion(); // Reiniciar paginación
    await cargarMasParques(); // Cargar primera página
    notifyListeners();
  }

  void _filtrarPorContinente(String continente) {
    _parquesFiltrados = _todosLosParques
        .where((p) => p.continente == continente)
        .toList();
  }

  void _ordenarParques({double? userLat, double? userLon}) {
    // No duplicar el filtrado aquí, solo ordenar
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
    // Usar cache si la búsqueda no ha cambiado
    if (busqueda == _ultimaBusqueda && _ultimosParquesFiltrados.isNotEmpty) {
      return _ultimosParquesFiltrados;
    }

    List<Parque> resultado;

    if (busqueda.isEmpty || busqueda.length < 3) {
      // Si la búsqueda está vacía o es muy corta, mostrar todos los parques cargados
      resultado = _parquesCargados;
    } else {
      // Filtrar solo los parques que ya están cargados
      final busquedaLower = busqueda.toLowerCase();
      resultado = _parquesCargados.where((p) =>
      p.nombre.toLowerCase().contains(busquedaLower) ||
          (p.ciudad.isNotEmpty && p.ciudad.toLowerCase().contains(busquedaLower)) ||
          p.pais.toLowerCase().contains(busquedaLower)
      ).toList();
    }

    // Actualizar cache
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
    // Ya no cargamos clima automáticamente aquí
    // Se cargará bajo demanda cuando el usuario vea un parque
    notifyListeners();
  }

  // Función para verificar si un parque necesita cargar clima - optimizada
  bool necesitaCargarClima(String nombreParque) {
    final parque = _todosLosParques.firstWhere((p) => p.nombre == nombreParque);

    // Solo necesita cargar si:
    // 1. Está en favoritos
    // 2. No tiene clima cargado
    return _favoritos.contains(parque.id) && !_datosClima.containsKey(nombreParque);
  }

  // Función para cargar clima de un parque específico - optimizada
  Future<void> cargarClimaParaParque(String nombreParque, double latitud, double longitud, String pais) async {
    // Solo cargar clima si el parque está en favoritos
    final parque = _todosLosParques.firstWhere((p) => p.nombre == nombreParque);

    if (!_favoritos.contains(parque.id)) {
      return; // No cargar si no es favorito
    }

    // Verificar si ya tenemos clima para este parque
    if (_datosClima.containsKey(nombreParque)) {
      return; // Ya tenemos datos
    }

    try {
      final ciudadConsulta = ClimaUtils.obtenerCiudadParaClima(nombreParque, latitud, longitud, pais);

      if (ciudadConsulta.isNotEmpty) {
        final clima = await obtenerClimaPorCiudad.ejecutar(ciudadConsulta);
        _datosClima[nombreParque] = clima;

        // Limpiar cache del parque para forzar regeneración
        _parquesConClimaCache.remove(parque.id);

        // Guardar en cache
        await guardarClimaCache();

        // Notificar cambios
        notifyListeners();
        return;
      }
    } catch (e) {
      // Si hay error, crear un clima de error para evitar que se quede cargando indefinidamente
      final climaError = Clima(
        temperatura: 0.0,
        descripcion: 'Error al cargar',
        codigoIcono: '/122.png', // Icono de error
        ciudad: 'Error',
        ultimaActualizacion: DateTime.now().toIso8601String(),
        esAntiguo: false,
      );
      _datosClima[nombreParque] = climaError;
      _parquesConClimaCache.remove(parque.id);
      notifyListeners();
    }
  }

  // Función para cargar clima de todos los favoritos - optimizada
  Future<void> cargarClimaFavoritos() async {
    for (final parqueId in _favoritos) {
      final parque = _todosLosParques.firstWhere((p) => p.id == parqueId);
      await cargarClimaParaParque(parque.nombre, parque.latitud, parque.longitud, parque.pais);
      // Rate limiting entre requests
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
      // Silenciar errores de guardado de cache
    }
  }

  // Nueva función para forzar actualización de clima de un parque
  Future<void> forzarActualizarClima(String parqueId) async {
    final parque = _todosLosParques.firstWhere((p) => p.id == parqueId);
    // Elimina el clima del cache y vuelve a cargarlo
    _datosClima.remove(parque.nombre);
    _parquesConClimaCache.remove(parqueId);
    await cargarClimaParaParque(parque.nombre, parque.latitud, parque.longitud, parque.pais);
    notifyListeners();
  }

  Future<void> cargarClimaCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final climaCache = prefs.getString('clima_cache');
      final ultimaActualizacion = prefs.getInt('clima_cache_timestamp') ?? 0;
      final ahora = DateTime.now().millisecondsSinceEpoch;

      // Verificar si el cache es antiguo (más de 30 minutos)
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
            esAntiguo: esCacheAntiguo, // Marcar como antiguo si corresponde
          );
        }
        // Si el cache es antiguo, actualizar TODOS los parques filtrados (no solo favoritos)
        if (esCacheAntiguo) {
          for (final parque in _parquesFiltrados) {
            await forzarActualizarClima(parque.id);
            await Future.delayed(const Duration(milliseconds: 200));
          }
        }
      }
    } catch (e) {
      // Silenciar errores de cache
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
      // Silenciar errores de localización
    }
  }

  // Función para cargar más parques (lazy loading) - optimizada
  Future<void> cargarMasParques() async {
    if (_cargandoMas || !_hayMasParques) return;

    _cargandoMas = true;
    notifyListeners();

    try {
      final inicio = _paginaActual * _parquesPorPagina;
      final fin = inicio + _parquesPorPagina;

      if (inicio >= _parquesFiltrados.length) {
        _hayMasParques = false;
        _cargandoMas = false;
        notifyListeners();
        return;
      }

      final nuevosParques = _parquesFiltrados.skip(inicio).take(_parquesPorPagina).toList();
      _parquesCargados.addAll(nuevosParques);
      _paginaActual++;

      // Verificar si hay más parques para cargar
      if (fin >= _parquesFiltrados.length) {
        _hayMasParques = false;
      }

    } catch (e) {
      // Silenciar errores de lazy loading
    } finally {
      _cargandoMas = false;
      notifyListeners();
    }
  }

  // Función para reiniciar la paginación cuando cambia el filtro
  void _reiniciarPaginacion() {
    _parquesCargados.clear();
    _paginaActual = 0;
    _hayMasParques = true;
    _limpiarCache(); // Limpiar cache cuando cambia el filtro
  }

  // Función para limpiar cache
  void _limpiarCache() {
    _parquesConClimaCache.clear();
    _distanciaCache.clear();
    _ultimaBusqueda = '';
    _ultimosParquesFiltrados.clear();
  }
}