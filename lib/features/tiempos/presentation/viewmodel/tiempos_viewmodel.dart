import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/atraccion.dart';
import '../../domain/entities/clima.dart';
import '../../domain/entities/parque.dart';
import '../../domain/repositories/parques_repository.dart';
import '../../domain/usecases/get_parques.dart';
import '../../domain/usecases/obtener_clima_por_ciudad.dart';
import '../../utils/parque_utils.dart';

import '../../../historial/domain/repositories/historial_repository.dart';

class TiemposViewModel extends ChangeNotifier {
  final GetParques _getParques;
  final ObtenerClimaPorCiudad _obtenerClimaPorCiudad;
  final ParquesRepository _parquesRepository;
  final HistorialRepository _historialRepository;

  TiemposViewModel({
    required GetParques getParques,
    required ObtenerClimaPorCiudad obtenerClimaPorCiudad,
    required ParquesRepository parquesRepository,
    required HistorialRepository historialRepository, // <-- Añadido
  })  : _getParques = getParques,
        _obtenerClimaPorCiudad = obtenerClimaPorCiudad,
        _parquesRepository = parquesRepository,
        _historialRepository = historialRepository;

  // STATE
  bool _cargando = false;
  bool _cargandoMas = false;
  String? _error;
  String _continenteActual = 'Europa';
  String _ordenActual = 'Alfabético';
  Set<String> _favoritos = {};
  Position? _posicionUsuario;
  Set<String> _cargandoClima = {};

  List<Parque> _parquesApi = [];
  List<Parque> _parquesFuente = [];
  List<Parque> _parquesVisibles = [];

  static const int _loteDeCarga = 15;

  // GETTERS
  bool get cargando => _cargando;
  bool get cargandoMas => _cargandoMas;
  String? get error => _error;
  List<Parque> get parques => _parquesVisibles;
  String get continenteActual => _continenteActual;
  String get ordenActual => _ordenActual;
  bool esFavorito(String parqueId) => _favoritos.contains(parqueId);
  bool get hayMasParques => _parquesVisibles.length < _parquesFuente.length;
  bool estaCargandoClima(String parqueId) => _cargandoClima.contains(parqueId);
  Position? get posicionUsuario => _posicionUsuario;

  Future<void> inicializar() async {
    if (_cargando) return;
    _setCargando(true);
    await _cargarFavoritos();
    await _cargarParquesDeApi();
    _setCargando(false);
  }

  Future<void> _cargarParquesDeApi() async {
    _error = null;
    try {
      final parques = await _getParques();
      _parquesApi = parques;
      _aplicarFiltrosYOrden(notificar: false);
    } catch (e) {
      _error = 'Error al cargar parques: $e';
    }
  }

  void cargarMasParques() {
    if (_cargandoMas || !hayMasParques) return;
    _setCargandoMas(true);
    Timer(const Duration(milliseconds: 300), () {
      final nuevos = _parquesFuente.skip(_parquesVisibles.length).take(_loteDeCarga);
      _parquesVisibles.addAll(nuevos);
      _setCargandoMas(false);
    });
  }

  Future<void> registrarVisitaParque(String parqueId, String parqueNombre) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _error = 'Debes iniciar sesión para registrar visitas';
        notifyListeners();
        return;
      }

      // 1. Buscar si ya hay un reporte diario activo (sin fechaFin) para hoy
      final reporte = await _historialRepository.obtenerReporteDiarioActual(user.uid, DateTime.now());

      if (reporte != null && reporte.fechaFin == null) {
        // Ya hay un reporte activo, no crees uno nuevo
        // Puedes notificar a la UI si quieres
        return;
      }

      // 2. Si no hay reporte activo, crea uno nuevo
      await _historialRepository.iniciarNuevoDia(
        userId: user.uid,
        parqueId: parqueId,
        parqueNombre: parqueNombre,
        fecha: DateTime.now(),
      );
    } catch (e) {
      _error = 'Error al registrar visita al parque: $e';
      notifyListeners();
    }
  }

  Future<void> cambiarContinente(String nuevoContinente) async {
    if (_continenteActual == nuevoContinente) return;
    _continenteActual = nuevoContinente;
    _setCargando(true);
    _aplicarFiltrosYOrden();
    _setCargando(false);
  }

  Future<void> cambiarOrden(String nuevoOrden) async {
    if (_ordenActual == nuevoOrden) return;
    _ordenActual = nuevoOrden;
    if (nuevoOrden == 'Cercanía' && _posicionUsuario == null) {
      await _obtenerPosicionUsuario();
    }
    _setCargando(true);
    _aplicarFiltrosYOrden();
    _setCargando(false);
  }

  void _aplicarFiltrosYOrden({bool notificar = true}) {
    List<Parque> filtrados = _parquesApi.where((p) => p.continente == _continenteActual).toList();

    switch (_ordenActual) {
      case 'Alfabético':
        filtrados.sort((a, b) => a.nombre.compareTo(b.nombre));
        break;
      case 'Cercanía':
        if (_posicionUsuario != null) {
          filtrados.sort((a, b) =>
              calcularDistancia(_posicionUsuario!.latitude, _posicionUsuario!.longitude, a.latitud, a.longitud)
                  .compareTo(calcularDistancia(_posicionUsuario!.latitude, _posicionUsuario!.longitude, b.latitud, b.longitud))
          );
        }
        break;
      case 'Favoritos':
        filtrados.sort((a, b) {
          final favA = esFavorito(a.id);
          final favB = esFavorito(b.id);
          if (favA && !favB) return -1;
          if (!favA && favB) return 1;
          return a.nombre.compareTo(b.nombre);
        });
        break;
    }
    _parquesFuente = filtrados;
    _parquesVisibles = _parquesFuente.take(_loteDeCarga).toList();
    if (notificar) notifyListeners();
  }

  List<Parque> filtrarPorBusqueda(String busqueda) {
    if (busqueda.isEmpty) return _parquesVisibles;
    final lower = busqueda.toLowerCase();
    return _parquesFuente.where((p) => p.nombre.toLowerCase().contains(lower) || p.ciudad.toLowerCase().contains(lower)).toList();
  }

  Future<void> _cargarFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    _favoritos = prefs.getStringList('parques_favoritos')?.toSet() ?? {};
  }

  Future<void> toggleFavorito(String parqueId) async {
    final prefs = await SharedPreferences.getInstance();
    if (_favoritos.contains(parqueId)) {
      _favoritos.remove(parqueId);
    } else {
      _favoritos.add(parqueId);
    }
    await prefs.setStringList('parques_favoritos', _favoritos.toList());
    if (_ordenActual == 'Favoritos') _aplicarFiltrosYOrden();
    notifyListeners();
  }

  Parque? getParqueConClima(String parqueId) {
    try {
      return _parquesVisibles.firstWhere((p) => p.id == parqueId);
    } catch (_) {
      try {
        return _parquesFuente.firstWhere((p) => p.id == parqueId);
      } catch (_) {
        return null;
      }
    }
  }

  bool necesitaCargarClima(String parqueId) {
    final parque = getParqueConClima(parqueId);
    return parque?.clima == null || (parque!.clima!.esAntiguo && !_cargandoClima.contains(parqueId));
  }

  Future<void> cargarClimaParaParque(Parque parque) async {
    if (estaCargandoClima(parque.id)) return;

    _cargandoClima.add(parque.id);
    notifyListeners();

    try {
      final clima = await _obtenerClimaPorCiudad(Params(ciudad: parque.textoCiudadFormateado));
      _actualizarClimaEnParque(parque.id, clima);
    } catch (e) {
      _actualizarClimaEnParque(parque.id, Clima.error());
    }

    _cargandoClima.remove(parque.id);
    notifyListeners();
  }

  Future<void> forzarActualizarClima(String parqueId) async {
    final parque = getParqueConClima(parqueId);
    if (parque != null) {
      await cargarClimaParaParque(parque);
    }
  }

  void _actualizarClimaEnParque(String parqueId, Clima clima) {
    // Actualizar en la lista de la API
    int indexApi = _parquesApi.indexWhere((p) => p.id == parqueId);
    if (indexApi != -1) {
      _parquesApi[indexApi] = _parquesApi[indexApi].copyWith(clima: clima);
    }

    // Actualizar en la lista de la fuente de datos
    int indexFuente = _parquesFuente.indexWhere((p) => p.id == parqueId);
    if (indexFuente != -1) {
      _parquesFuente[indexFuente] = _parquesFuente[indexFuente].copyWith(clima: clima);
    }

    // Actualizar en la lista visible
    int indexVisible = _parquesVisibles.indexWhere((p) => p.id == parqueId);
    if (indexVisible != -1) {
      _parquesVisibles[indexVisible] = _parquesVisibles[indexVisible].copyWith(clima: clima);
    }

    notifyListeners();
  }

  // --- OTROS MÉTODOS ---

  Future<List<Atraccion>> cargarAtracciones(String parqueId) async {
    try {
      return await _parquesRepository.obtenerAtraccionesDeParque(parqueId);
    } catch (e) {
      _error = 'Error al cargar atracciones: $e';
      notifyListeners();
      return [];
    }
  }

  Future<void> _obtenerPosicionUsuario() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) return;

      _posicionUsuario = await Geolocator.getCurrentPosition();
    } catch (e) {
      // Manejar error si es necesario
    }
  }

  // --- HELPERS DE ESTADO ---

  void _setCargando(bool value) {
    _cargando = value;
    notifyListeners();
  }

  void _setCargandoMas(bool value) {
    _cargandoMas = value;
    notifyListeners();
  }
}
