import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/visita_entity.dart';
import '../../domain/usecases/obtener_visitas_usecase.dart';
import '../../domain/usecases/obtener_visitas_por_parque_usecase.dart';

class HistorialViewModel extends ChangeNotifier {
  final ObtenerVisitasUseCase _obtenerVisitasUseCase;
  final ObtenerVisitasPorParqueUseCase _obtenerVisitasPorParqueUseCase;
  final FirebaseAuth _auth;

  List<VisitaEntity> _visitas = [];
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

  List<VisitaEntity> get visitas => _visitas;
  Map<String, int> get conteoAtracciones => _conteoAtracciones;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> cargarVisitas() async {
    _setLoading(true);
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('Usuario no autenticado');
      _visitas = await _obtenerVisitasUseCase(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _setLoading(false);
  }

  Future<void> cargarVisitasPorParque(String parqueId) async {
    _setLoading(true);
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('Usuario no autenticado');
      _visitas = await _obtenerVisitasPorParqueUseCase(parqueId, userId);
      _conteoAtracciones = _contarVisitasPorAtraccion(_visitas);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _setLoading(false);
  }

  Map<String, int> _contarVisitasPorAtraccion(List<VisitaEntity> visitas) {
    final Map<String, int> conteo = {};
    for (var visita in visitas) {
      if (visita.atraccionNombre != null && visita.atraccionNombre!.isNotEmpty) {
        conteo[visita.atraccionNombre!] = (conteo[visita.atraccionNombre!] ?? 0) + 1;
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