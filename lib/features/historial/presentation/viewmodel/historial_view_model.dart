import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/visita_atraccion_entity.dart';
import '../../domain/entities/reporte_diario_entity.dart';
import '../../domain/usecases/obtener_visitas_usecase.dart';
import '../../domain/usecases/obtener_visitas_por_parque_usecase.dart';
import '../../domain/usecases/obtener_todas_visitas_usecase.dart';
import '../../domain/repositories/historial_repository.dart';

class HistorialViewModel extends ChangeNotifier {
  final ObtenerVisitasUseCase _obtenerVisitasUseCase;
  final ObtenerVisitasPorParqueUseCase _obtenerVisitasPorParqueUseCase;
  final ObtenerTodasVisitasUseCase _obtenerTodasVisitasUseCase;
  final HistorialRepository _historialRepository;
  final FirebaseAuth _auth;

  List<VisitaAtraccionEntity> _visitas = [];
  Map<String, int> _conteoAtracciones = {};
  bool _isLoading = false;
  String? _error;

  HistorialViewModel({
    required ObtenerVisitasUseCase obtenerVisitasUseCase,
    required ObtenerVisitasPorParqueUseCase obtenerVisitasPorParqueUseCase,
    required ObtenerTodasVisitasUseCase obtenerTodasVisitasUseCase,
    required HistorialRepository historialRepository,
    FirebaseAuth? auth,
  })  : _obtenerVisitasUseCase = obtenerVisitasUseCase,
        _obtenerVisitasPorParqueUseCase = obtenerVisitasPorParqueUseCase,
        _obtenerTodasVisitasUseCase = obtenerTodasVisitasUseCase,
        _historialRepository = historialRepository,
        _auth = auth ?? FirebaseAuth.instance;

  List<VisitaAtraccionEntity> get visitas => _visitas;
  Map<String, int> get conteoAtracciones => _conteoAtracciones;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> cargarVisitas({String? reporteId}) async {
    _setLoading(true);
    _error = null;
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('Usuario no autenticado');


      await _cargarTodasLasVisitas(userId);
    } catch (e) {
      _error = e.toString();
      _visitas = [];
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> _cargarTodasLasVisitas(String userId) async {
    try {

      final result = await _obtenerTodasVisitasUseCase(userId);

      result.fold(
            (failure) {
          _error = failure.message;
          _visitas = [];
          _conteoAtracciones = {};
        },
            (todasLasVisitas) {
          _visitas = todasLasVisitas;
          _conteoAtracciones = _contarVisitasPorAtraccion(todasLasVisitas);
        },
      );
    } catch (e) {
      _error = 'Error cargando todas las visitas: $e';
      _visitas = [];
      _conteoAtracciones = {};
    }
  }

  Future<void> cargarVisitasPorParque(String parqueId, String reporteId) async {
    _setLoading(true);
    _error = null;
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('Usuario no autenticado');

      final result = await _obtenerVisitasPorParqueUseCase(
        userId,
        parqueId,
        reporteId,
      );

      result.fold(
            (failure) {
          _error = failure.message;
          _visitas = [];
          _conteoAtracciones = {};
        },
            (visitas) {
          _visitas = visitas;
          _conteoAtracciones = _contarVisitasPorAtraccion(visitas);
        },
      );
    } catch (e) {
      _error = e.toString();
      _visitas = [];
      _conteoAtracciones = {};
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Map<String, int> _contarVisitasPorAtraccion(List<VisitaAtraccionEntity> visitas) {
    final Map<String, int> conteo = {};
    for (var visita in visitas) {
      final nombreAtraccion = visita.atraccionNombre;
      if (nombreAtraccion.isNotEmpty) {
        conteo[nombreAtraccion] = (conteo[nombreAtraccion] ?? 0) + 1;
      }
    }
    return conteo;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void limpiarError() {
    _error = null;
    notifyListeners();
  }
}