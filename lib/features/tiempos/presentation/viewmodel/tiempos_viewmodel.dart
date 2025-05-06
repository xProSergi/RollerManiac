import 'package:flutter/material.dart';
import '../../domain/entities/parque.dart';
import '../../domain/entities/atraccion.dart';
import '../../domain/repositories/parques_repository.dart';

class TiemposViewModel extends ChangeNotifier {
  final ParquesRepository repository;

  TiemposViewModel(this.repository);

  List<Parque> _parques = [];
  bool _cargando = false;
  String? _error;

  List<Parque> get parques => _parques;
  bool get cargando => _cargando;
  String? get error => _error;

  Future<void> cargarParques() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      _parques = await repository.obtenerParques();
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<List<Atraccion>> cargarAtracciones(int parqueId) async {
    try {
      final atracciones = await repository.obtenerAtraccionesDeParque(parqueId);
      return atracciones;
    } catch (e) {
      print('Error al cargar atracciones: $e');
      return [];
    }
  }


}
