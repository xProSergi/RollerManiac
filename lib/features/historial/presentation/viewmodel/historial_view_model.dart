import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/visita_atraccion_entity.dart';
import '../../domain/usecases/obtener_visitas_usecase.dart' hide ObtenerVisitasPorParqueUseCase;
import '../../domain/usecases/obtener_visitas_por_parque_usecase.dart';

class HistorialViewModel extends ChangeNotifier {
  final ObtenerVisitasUseCase _obtenerVisitasUseCase;
  final ObtenerVisitasPorParqueUseCase _obtenerVisitasPorParqueUseCase;
  final FirebaseAuth _auth;

  List<VisitaAtraccionEntity> _visitas = [];
  Map<String, int> _conteoAtracciones = {};
  bool _isLoading = false;
  String? _error;

  HistorialViewModel({
    required ObtenerVisitasUseCase obtenerVisitasUseCase,
    required ObtenerVisitasPorParqueUseCase obtenerVisitasPorParqueUseCase,
    FirebaseAuth? auth,
  })  : _obtenerVisitasUseCase = obtenerVisitasUseCase,
        _obtenerVisitasPorParqueUseCase = obtenerVisitasPorParqueUseCase,
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

      final result = await _obtenerVisitasUseCase(
        userId: userId,
        reporteId: reporteId ?? '', // Provide default or handle null case
      );

      result.fold(
            (failure) {
          _error = failure.message;
          _visitas = [];
        },
            (visitas) {
          _visitas = visitas;
          _conteoAtracciones = _contarVisitasPorAtraccion(visitas);
        },
      );
    } catch (e) {
      _error = e.toString();
      _visitas = [];
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> cargarVisitasPorParque(String parqueId, String reporteId) async {
    _setLoading(true);
    _error = null;
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('Usuario no autenticado');

      // Fix the call to match your use case implementation
      final result = await _obtenerVisitasPorParqueUseCase(
        userId,
        parqueId,
        reporteId
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

  // Inside your HistorialViewModel (or whichever class contains this method)

  Map<String, int> _contarVisitasPorAtraccion(List<VisitaAtraccionEntity> visitas) {
    final Map<String, int> conteo = {};
    for (var visita in visitas) {
      // CHANGE THIS LINE:
      final nombreAtraccion = visita.atraccionNombre; // <--- Changed 'nombre' to 'nombreAtraccion'
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