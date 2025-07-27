import 'dart:async'; // For StreamSubscription
import 'package:dartz/dartz.dart'; // For Either
import 'package:flutter/material.dart'; // For ChangeNotifier and debugPrint
import 'package:uuid/uuid.dart'; // For unique IDs

import '../../../../core/error/failures.dart';
import '../../../../core/utils/auth_helper.dart';

import '../../domain/entities/reporte_diario_entity.dart';
import '../../domain/entities/visita_atraccion_entity.dart';
import '../../domain/usecases/agregar_visita_atraccion_usecase.dart';
import '../../domain/usecases/finalizar_dia_usecase.dart';
import '../../domain/usecases/finalizar_visita_atraccion_usecase.dart';
import '../../domain/usecases/iniciar_nuevo_dia_usecase.dart';
import '../../domain/usecases/obtener_reporte_diario_usecase.dart';
import '../../domain/repositories/historial_repository.dart';

class ReporteDiarioViewModel with ChangeNotifier {
  final ObtenerReporteDiarioUseCase _obtenerReporteDiarioUseCase;
  final IniciarNuevoDiaUseCase _iniciarNuevoDiaUseCase;
  final AgregarVisitaAtraccionUseCase _agregarVisitaAtraccionUseCase;
  final FinalizarVisitaAtraccionUseCase _finalizarVisitaAtraccionUseCase;
  final FinalizarDiaUseCase _finalizarDiaUseCase;
  final HistorialRepository _historialRepository;

  StreamSubscription<List<VisitaAtraccionEntity>>? _atraccionesSubscription;
  List<VisitaAtraccionEntity> _atraccionesVisitadas = [];
  List<VisitaAtraccionEntity> get atraccionesVisitadas => _atraccionesVisitadas;
  ReporteDiarioEntity? _reporteActual;
  bool _cargando = false;
  String? _error;
  StreamSubscription<ReporteDiarioEntity?>? _reporteSubscription;

  ReporteDiarioEntity? get reporteActual => _reporteActual;
  bool get cargando => _cargando;
  String? get error => _error;
  bool get tieneError => _error != null;
  bool get tieneReporteActivo => _reporteActual != null && _reporteActual!.fechaFin == null;

  ReporteDiarioViewModel({
    required ObtenerReporteDiarioUseCase obtenerReporteDiarioUseCase,
    required IniciarNuevoDiaUseCase iniciarNuevoDiaUseCase,
    required AgregarVisitaAtraccionUseCase agregarVisitaAtraccionUseCase,
    required FinalizarVisitaAtraccionUseCase finalizarVisitaAtraccionUseCase,
    required FinalizarDiaUseCase finalizarDiaUseCase,
    required HistorialRepository historialRepository,
  })  : _obtenerReporteDiarioUseCase = obtenerReporteDiarioUseCase,
        _iniciarNuevoDiaUseCase = iniciarNuevoDiaUseCase,
        _agregarVisitaAtraccionUseCase = agregarVisitaAtraccionUseCase,
        _finalizarVisitaAtraccionUseCase = finalizarVisitaAtraccionUseCase,
        _finalizarDiaUseCase = finalizarDiaUseCase,
        _historialRepository = historialRepository;

  Future<void> cargarReporteActual(String userId, DateTime fecha) async {
    _establecerCargando(true);
    _error = null;

    final result = await _historialRepository.obtenerReporteDiarioActual(userId, fecha);

    if (result != null) {
      _reporteActual = result;
      suscribirActualizaciones(result.id);
    } else {
      _reporteActual = null;
      _atraccionesVisitadas = [];
      _reporteSubscription?.cancel();
      _atraccionesSubscription?.cancel();
    }
    _establecerCargando(false);
  }

  Future<void> cargarReportePorId(String reporteId) async {
    _establecerCargando(true);
    _error = null;
    final userId = AuthHelper.obtenerUsuarioActual();
    if (userId == null) {
      _error = 'Usuario no autenticado. Por favor, inicia sesión.';
      _establecerCargando(false);
      return;
    }

    final result = await _obtenerReporteDiarioUseCase(
      ObtenerReporteDiarioParams(userId: userId, reporteId: reporteId),
    );
    _procesarResultado(result);
  }

  Future<void> iniciarNuevoDia({
    required String parqueId,
    required String parqueNombre,
  }) async {
    _establecerCargando(true);
    _error = null;
    final userId = AuthHelper.obtenerUsuarioActual();
    if (userId == null) {
      _error = 'Usuario no autenticado. Por favor, inicia sesión.';
      _establecerCargando(false);
      return;
    }

    final existingReport = await _historialRepository.obtenerReporteDiarioActual(userId, DateTime.now());
    if (existingReport != null) {
      _reporteActual = existingReport;
      suscribirActualizaciones(existingReport.id);
      return;
    }

    final result = await _iniciarNuevoDiaUseCase(
      IniciarNuevoDiaParams(
        userId: userId,
        parqueId: parqueId,
        parqueNombre: parqueNombre,
        fecha: DateTime.now(),
      ),
    );
    result.fold(
          (failure) {
        _error = _mapearError(failure);
        _establecerCargando(false);
      },
          (reporte) {
        _reporteActual = reporte;
        _error = null;
        _establecerCargando(false);
        suscribirActualizaciones(reporte.id);
      },
    );
  }

  Future<void> agregarVisitaAtraccion({
    required String parqueId,
    required String parqueNombre,
    required String atraccionId,
    required String atraccionNombre,
  }) async {
    _establecerCargando(true);
    _error = null;
    try {
      final userId = AuthHelper.obtenerUsuarioActual();
      if (userId == null) {
        _error = 'Usuario no autenticado para agregar visita. Por favor, inicia sesión.';
        notifyListeners();
        _establecerCargando(false);
        return;
      }

      if (_reporteActual == null || _reporteActual!.fechaFin != null) {
        await cargarReporteActual(userId, DateTime.now());

        if (_reporteActual == null) {
          await iniciarNuevoDia(
            parqueId: parqueId,
            parqueNombre: parqueNombre,
          );

          if (_reporteActual == null) {
            _error = 'No se pudo crear un nuevo reporte diario.';
            _establecerCargando(false);
            return;
          }
        }
      }

      final uuid = Uuid();
      final String visitaId = uuid.v4();

      final nuevaVisita = VisitaAtraccionEntity(
        id: visitaId,
        reporteDiarioId: _reporteActual!.id,
        parqueId: parqueId,
        parqueNombre: parqueNombre,
        atraccionId: atraccionId,
        atraccionNombre: atraccionNombre,
        userId: userId,
        horaInicio: DateTime.now(),
        horaFin: null,
        duracion: null,
        valoracion: null,
        notas: null,
        fecha: DateTime.now(), // Ensure 'fecha' is included
      );

      final result = await _agregarVisitaAtraccionUseCase(
        AgregarVisitaAtraccionParams(
          userId: userId,
          reporteId: _reporteActual!.id,
          visita: nuevaVisita,
        ),
      );

      result.fold(
            (failure) => _error = _mapearError(failure),
            (reporteActualizado) {
          _reporteActual = reporteActualizado;
        },
      );
    } catch (e) {
      debugPrint('Error al agregar visita: $e');
      _error = 'Error inesperado al agregar visita a atracción: ${e.toString()}';
    } finally {
      _establecerCargando(false);
    }
  }

  Future<void> finalizarVisitaAtraccion({
    required String atraccionId,
    required int? valoracion,
    required String? notas,
  }) async {
    _establecerCargando(true);
    _error = null;
    try {
      final userId = AuthHelper.obtenerUsuarioActual();
      if (userId == null) {
        _error = 'Usuario no autenticado para finalizar visita a atracción. Por favor, inicia sesión.';
        notifyListeners();
        _establecerCargando(false);
        return;
      }
      if (_reporteActual == null || _reporteActual!.fechaFin != null) {
        _error = 'No hay un reporte diario activo para finalizar la visita a la atracción.';
        notifyListeners();
        _establecerCargando(false);
        return;
      }

      final existingVisit = _reporteActual!.atraccionesVisitadas.firstWhere(
            (v) => v.atraccionId == atraccionId && v.horaFin == null,
        orElse: () => throw NotFoundFailure(message: 'No se encontró una visita activa para esta atracción.'),
      );

      final result = await _finalizarVisitaAtraccionUseCase(
        FinalizarVisitaAtraccionParams(
          reporteId: _reporteActual!.id,
          visitaId: existingVisit.id,
          userId: userId,
          valoracion: valoracion,
          notas: notas,
        ),
      );

      result.fold(
            (failure) => _error = _mapearError(failure),
            (reporteActualizado) {
          _reporteActual = reporteActualizado;
        },
      );
    } catch (e) {
      debugPrint('Error al finalizar visita a atracción: $e');
      _error = 'Error inesperado al finalizar visita a atracción: ${e.toString()}';
    } finally {
      _establecerCargando(false);
    }
  }

  Future<bool> finalizarDia({
    VoidCallback? onReportFinished,
  }) async {
    _establecerCargando(true);
    _error = null;
    final userId = AuthHelper.obtenerUsuarioActual();

    if (userId == null) {
      _error = 'Usuario no autenticado para finalizar el día. Por favor, inicia sesión.';
      notifyListeners();
      _establecerCargando(false);
      return false;
    }

    if (_reporteActual == null) {
      await cargarReporteActual(userId, DateTime.now());
    }

    if (_reporteActual == null || _reporteActual!.fechaFin != null) {
      _error = 'No hay un reporte diario activo para finalizar. Por favor, registra una visita primero.';
      notifyListeners();
      _establecerCargando(false);
      return false;
    }

    final result = await _finalizarDiaUseCase(
      FinalizarDiaParams(
        reporteId: _reporteActual!.id,
        userId: userId,
      ),
    );

    var exito = false;

    result.fold(
          (failure) {
        _error = _mapearError(failure);
        exito = false;
      },
          (reporteActualizado) {
        _reporteActual = reporteActualizado;
        _error = null;
        exito = true;
        onReportFinished?.call();
      },
    );

    _establecerCargando(false);
    return exito;
  }

  void suscribirActualizaciones(String reporteId) {
    _reporteSubscription?.cancel();
    _atraccionesSubscription?.cancel();

    final userId = AuthHelper.obtenerUsuarioActual();

    if (userId == null) {
      _error = 'Usuario no autenticado';
      notifyListeners();
      return;
    }

    _reporteSubscription = _historialRepository
        .obtenerReporteEnTiemReal(reporteId, userId)
        .listen(
          (reporteActualizado) {
        // We only update the main report details here.
        // Attractions are handled by their own stream.
        _reporteActual = reporteActualizado;
        notifyListeners();
      },
      onError: (error) {
        _error = 'Error en actualizaciones del reporte principal: ${error.toString()}';
        notifyListeners();
      },
      cancelOnError: false,
    );

    _atraccionesSubscription = _historialRepository
        .obtenerVisitasAtraccionEnTiempoReal(userId, reporteId)
        .listen(
          (atracciones) {
        debugPrint('Atracciones actualizadas en ViewModel: ${atracciones.length}');
        _atraccionesVisitadas = atracciones;
        notifyListeners();
      },
      onError: (error) {
        _error = 'Error en actualizaciones de atracciones: ${error.toString()}';
        notifyListeners();
      },
      cancelOnError: false,
    );
  }

  void _procesarResultado(Either<Failure, ReporteDiarioEntity> result) {
    result.fold(
          (failure) {
        _error = _mapearError(failure);
        _establecerCargando(false);
      },
          (reporte) {
        _reporteActual = reporte;
        _error = null;
        _establecerCargando(false);
        suscribirActualizaciones(reporte.id);
      },
    );
  }

  String _mapearError(Failure failure) {
    if (failure is ServerFailure) {
      return 'Error del servidor: ${failure.message}';
    } else if (failure is NotFoundFailure) {
      return 'No se encontró el reporte solicitado o recurso relacionado.';
    } else if (failure is InvalidParamsFailure) {
      return 'Parámetros inválidos para la operación: ${failure.message}';
    } else if (failure is ConflictFailure) {
      return 'Conflicto de datos: ${failure.message}';
    } else if (failure is PermissionDeniedFailure) {
      return 'Acceso denegado: ${failure.message}';
    } else if (failure is NetworkFailure) {
      return 'Problema de conexión: ${failure.message}';
    } else {
      return 'Ocurrió un error inesperado. Por favor, inténtalo de nuevo.';
    }
  }

  void _establecerCargando(bool cargando) {
    _cargando = cargando;
    notifyListeners();
  }

  @override
  void limpiarEstado() {
    _reporteActual = null;
    _error = null;
    _cargando = false;
    _reporteSubscription?.cancel();
    _atraccionesSubscription?.cancel();
    _atraccionesVisitadas = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _reporteSubscription?.cancel();
    _atraccionesSubscription?.cancel();
    super.dispose();
  }

  bool tieneAtraccionVisitada(String atraccionId) {
    return _atraccionesVisitadas.any((v) => v.atraccionId == atraccionId);
  }

  int get totalAtraccionesVisitadas => _atraccionesVisitadas.length;

  double? get valoracionPromedio {
    final visitas = _atraccionesVisitadas;
    if (visitas.isEmpty) return null;

    final valoraciones = visitas
        .where((v) => v.valoracion != null)
        .map((v) => v.valoracion!)
        .toList();

    if (valoraciones.isEmpty) return null;

    return valoraciones.reduce((a, b) => a + b) / valoraciones.length;
  }

  Duration? get tiempoTotalCalculado {
    final visitas = _atraccionesVisitadas;
    if (visitas.isEmpty) return null;

    final visitasConFin = visitas.where((v) => v.horaFin != null).toList();
    if (visitasConFin.isEmpty) return null;

    final primera = visitasConFin.reduce(
            (a, b) => a.horaInicio.isBefore(b.horaInicio) ? a : b);
    final ultima = visitasConFin.reduce(
            (a, b) => (a.horaFin ?? a.horaInicio).isAfter(b.horaFin ?? b.horaInicio)
            ? a
            : b);

    return ultima.horaFin!.difference(primera.horaInicio);
  }
}