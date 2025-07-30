import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

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

    required FinalizarDiaUseCase finalizarDiaUseCase,
    required HistorialRepository historialRepository,
  })  : _obtenerReporteDiarioUseCase = obtenerReporteDiarioUseCase,
        _iniciarNuevoDiaUseCase = iniciarNuevoDiaUseCase,
        _agregarVisitaAtraccionUseCase = agregarVisitaAtraccionUseCase,

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

    // Solo usar reportes activos (sin fechaFin)
    final existingReport = await _historialRepository.obtenerReporteDiarioActual(userId, DateTime.now());
    if (existingReport != null && existingReport.fechaFin == null) {
      _reporteActual = existingReport;
      suscribirActualizaciones(existingReport.id);
      _establecerCargando(false);
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

        // Si no hay reporte activo o el reporte está finalizado, crear uno nuevo
        if (_reporteActual == null || _reporteActual!.fechaFin != null) {
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

  // Elimina finalizarVisitaAtraccion y toda referencia a finalizar visita a atracción

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

    if (_reporteActual == null) {
      _error = 'No hay un reporte diario activo para finalizar. Por favor, registra una visita primero.';
      notifyListeners();
      _establecerCargando(false);
      return false;
    }

    // Si el reporte ya está finalizado, no hacer nada y retornar éxito
    if (_reporteActual!.fechaFin != null) {
      debugPrint('Reporte ya finalizado: ${_reporteActual!.fechaFin}');
      _error = null;
      onReportFinished?.call();
      _establecerCargando(false);
      return true;
    }

    final result = await _finalizarDiaUseCase(
      FinalizarDiaParams(
        reporteId: _reporteActual!.id,
        userId: userId,
      ),
    );

    var exito = false;

    await result.fold(
          (failure) async {
        _error = _mapearError(failure);
        exito = false;
      },
          (reporteActualizado) async {
        _reporteActual = reporteActualizado;
        _error = null;
        // Recarga las atracciones visitadas para el reporte finalizado
        final atracciones = await _historialRepository.obtenerVisitas(
          userId, _reporteActual!.id,
        );
        atracciones.fold(
              (failure) => _atraccionesVisitadas = [],
              (lista) => _atraccionesVisitadas = lista,
        );
        exito = true;
        onReportFinished?.call();
        notifyListeners();
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
          (atracciones) async {
        // Si el stream devuelve 0 pero el reporte está finalizado, recarga manualmente
        if (atracciones.isEmpty && _reporteActual?.fechaFin != null) {
          final result = await _historialRepository.obtenerVisitas(userId, reporteId);
          result.fold(
                (failure) => _atraccionesVisitadas = [],
                (lista) => _atraccionesVisitadas = lista,
          );
        } else {
          _atraccionesVisitadas = atracciones;
        }
        debugPrint('Atracciones actualizadas en ViewModel: ${_atraccionesVisitadas.length}');
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

  Future<void> crearNuevoReporte({
    required String parqueId,
    required String parqueNombre,
  }) async {
    _establecerCargando(true);
    _error = null;

    // Limpiar estado actual
    _reporteSubscription?.cancel();
    _atraccionesSubscription?.cancel();
    _atraccionesVisitadas = [];
    _reporteActual = null;

    final userId = AuthHelper.obtenerUsuarioActual();
    if (userId == null) {
      _error = 'Usuario no autenticado. Por favor, inicia sesión.';
      _establecerCargando(false);
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