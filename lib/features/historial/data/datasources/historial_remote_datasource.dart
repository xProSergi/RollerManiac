import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/exceptions.dart';
import '../models/reporte_diario_model.dart';
import '../models/visita_atraccion_model.dart';


abstract class HistorialRemoteDataSource {

  Future<List<VisitaAtraccionModel>> obtenerVisitas(String userId, String reporteId);


  Future<List<VisitaAtraccionModel>> obtenerVisitasPorParque(String parqueId, String userId, String reporteId);


  Future<List<VisitaAtraccionModel>> obtenerTodasLasVisitas(String userId);


  Future<ReporteDiarioModel> obtenerReportePorId(String userId, String reporteId);
  Stream<ReporteDiarioModel?> obtenerReporteEnTiemReal(String reporteId, String userId);

  Stream<List<VisitaAtraccionModel>> obtenerVisitasAtraccionEnTiempoReal(String userId, String reporteId);

  Future<ReporteDiarioModel?> obtenerReporteDiarioActual(String userId, DateTime fecha);
  Future<List<ReporteDiarioModel>> obtenerReportesPorRango(
      String userId, {required DateTime fechaInicio, required DateTime fechaFin});
  Future<ReporteDiarioModel> iniciarNuevoDia({
    required String userId,
    required String parqueId,
    required String parqueNombre,
    required DateTime fecha,
  });
  Future<ReporteDiarioModel> agregarVisitaAtraccion({
    required String userId,
    required String reporteId,
    required VisitaAtraccionModel visita,
  });
  Future<ReporteDiarioModel> finalizarDia({required String reporteId, required String userId});
  Future<ReporteDiarioModel> actualizarReporteDiario(ReporteDiarioModel reporte);
}

class HistorialRemoteDataSourceImpl implements HistorialRemoteDataSource {
  final FirebaseFirestore firestore;

  HistorialRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<VisitaAtraccionModel>> obtenerVisitas(String userId, String reporteId) async {
    try {
      final snapshot = await firestore
          .collection('usuarios')
          .doc(userId)
          .collection('visitas_atracciones')
          .where('reporteDiarioId', isEqualTo: reporteId)
          .get();

      return snapshot.docs.map((doc) {
        return VisitaAtraccionModel.fromFirestore(doc, reporteId);
      }).toList();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw PermissionDeniedException(message: 'Permiso denegado para obtener visitas.');
      } else {
        throw ServerException(message: 'Error al obtener visitas: ${e.message}');
      }
    } catch (e) {
      throw ServerException(message: 'Error inesperado al obtener visitas: $e');
    }
  }

  @override
  Future<List<VisitaAtraccionModel>> obtenerVisitasPorParque(String parqueId, String userId, String reporteId) async {
    try {
      final snapshot = await firestore
          .collection('usuarios')
          .doc(userId)
          .collection('visitas_atracciones')
          .where('reporteDiarioId', isEqualTo: reporteId)
          .where('parqueId', isEqualTo: parqueId)
          .get();

      return snapshot.docs
          .map((doc) => VisitaAtraccionModel.fromFirestore(doc, reporteId))
          .toList();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw PermissionDeniedException(message: 'Permiso denegado para obtener visitas por parque.');
      } else {
        throw ServerException(message: 'Error al obtener visitas por parque: ${e.message}');
      }
    } catch (e) {
      throw ServerException(message: 'Error inesperado al obtener visitas por parque: $e');
    }
  }

  @override
  Future<List<VisitaAtraccionModel>> obtenerTodasLasVisitas(String userId) async {
    try {
      final snapshot = await firestore
          .collection('usuarios')
          .doc(userId)
          .collection('visitas_atracciones')
          .orderBy('fecha', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        final reporteId = data['reporteDiarioId'] as String? ?? '';
        return VisitaAtraccionModel.fromFirestore(doc, reporteId);
      }).toList();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw PermissionDeniedException(message: 'Permiso denegado para obtener todas las visitas.');
      } else {
        throw ServerException(message: 'Error al obtener todas las visitas: ${e.message}');
      }
    } catch (e) {
      throw ServerException(message: 'Error inesperado al obtener todas las visitas: $e');
    }
  }

  // --- Daily Report Methods ---
  @override
  Future<ReporteDiarioModel> obtenerReportePorId(String userId, String reporteId) async {
    try {
      final doc = await firestore
          .collection('usuarios')
          .doc(userId)
          .collection('reportesDiarios')
          .doc(reporteId)
          .get();

      if (!doc.exists) {
        throw NotFoundException(message: 'Reporte diario no encontrado.');
      }
      return ReporteDiarioModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw PermissionDeniedException(message: 'Permiso denegado para obtener reporte.');
      } else {
        throw ServerException(message: 'Error al obtener reporte diario por ID: ${e.message}');
      }
    } catch (e) {
      throw ServerException(message: 'Error inesperado al obtener reporte diario por ID: $e');
    }
  }

  @override
  Stream<ReporteDiarioModel?> obtenerReporteEnTiemReal(String reporteId, String userId) {
    return firestore
        .collection('usuarios')
        .doc(userId)
        .collection('reportesDiarios')
        .doc(reporteId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      return ReporteDiarioModel.fromFirestore(snapshot);
    });
  }

  @override
  Stream<List<VisitaAtraccionModel>> obtenerVisitasAtraccionEnTiempoReal(String userId, String reporteId) {
    return firestore
        .collection('usuarios')
        .doc(userId)
        .collection('visitas_atracciones')
        .where('reporteDiarioId', isEqualTo: reporteId)
        .orderBy('fecha', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => VisitaAtraccionModel.fromFirestore(doc, reporteId))
          .toList();
    });
  }

  @override
  Future<ReporteDiarioModel?> obtenerReporteDiarioActual(String userId, DateTime fecha) async {
    try {
      final startOfDay = DateTime(fecha.year, fecha.month, fecha.day);
      final endOfDay = startOfDay.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));

      // Primero buscar reportes activos del día actual
      final snapshotActivos = await firestore
          .collection('usuarios')
          .doc(userId)
          .collection('reportesDiarios')
          .where('fecha', isGreaterThanOrEqualTo: startOfDay)
          .where('fecha', isLessThanOrEqualTo: endOfDay)
          .where('fechaFin', isNull: true)
          .limit(1)
          .get();

      if (snapshotActivos.docs.isNotEmpty) {
        return ReporteDiarioModel.fromFirestore(snapshotActivos.docs.first);
      }


      final snapshotReciente = await firestore
          .collection('usuarios')
          .doc(userId)
          .collection('reportesDiarios')
          .where('fecha', isGreaterThanOrEqualTo: startOfDay)
          .where('fecha', isLessThanOrEqualTo: endOfDay)
          .orderBy('fecha', descending: true)
          .limit(1)
          .get();

      if (snapshotReciente.docs.isEmpty) {
        return null;
      }
      return ReporteDiarioModel.fromFirestore(snapshotReciente.docs.first);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw PermissionDeniedException(message: 'Permiso denegado para obtener reporte diario actual.');
      } else {
        throw ServerException(message: 'Error al obtener reporte diario actual: ${e.message}');
      }
    } catch (e) {
      throw ServerException(message: 'Error inesperado al obtener reporte diario actual: $e');
    }
  }

  @override
  Future<List<ReporteDiarioModel>> obtenerReportesPorRango(
      String userId, {required DateTime fechaInicio, required DateTime fechaFin}) async {
    try {
      final snapshot = await firestore
          .collection('usuarios')
          .doc(userId)
          .collection('reportesDiarios')
          .where('fecha', isGreaterThanOrEqualTo: fechaInicio)
          .where('fecha', isLessThanOrEqualTo: fechaFin)
          .orderBy('fecha')
          .get();

      return snapshot.docs.map((doc) {
        return ReporteDiarioModel.fromFirestore(doc);
      }).toList();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw PermissionDeniedException(message: 'Permiso denegado para obtener reportes por rango.');
      } else {
        throw ServerException(message: 'Error al obtener reportes por rango: ${e.message}');
      }
    } catch (e) {
      throw ServerException(message: 'Error inesperado al obtener reportes por rango: $e');
    }
  }

  @override
  Future<ReporteDiarioModel> iniciarNuevoDia({
    required String userId,
    required String parqueId,
    required String parqueNombre,
    required DateTime fecha,
  }) async {
    try {
      final newDocRef = firestore.collection('usuarios').doc(userId).collection('reportesDiarios').doc();
      final reporteModel = ReporteDiarioModel(
        id: newDocRef.id,
        userId: userId,
        parqueId: parqueId,
        parqueNombre: parqueNombre,
        fecha: fecha,
        atraccionesVisitadas: [],
      );
      await newDocRef.set(reporteModel.toJson());
      return reporteModel;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw PermissionDeniedException(message: 'Permiso denegado para iniciar nuevo día.');
      } else {
        throw ServerException(message: 'Error al iniciar nuevo día: ${e.message}');
      }
    } catch (e) {
      throw ServerException(message: 'Error inesperado al iniciar nuevo día: $e');
    }
  }

  @override
  Future<ReporteDiarioModel> agregarVisitaAtraccion({
    required String userId,
    required String reporteId,
    required VisitaAtraccionModel visita,
  }) async {
    try {
      final visitaDocRef = firestore
          .collection('usuarios')
          .doc(userId)
          .collection('visitas_atracciones')
          .doc(visita.id);

      final DateTime horaInicio = visita.horaInicio;
      final DateTime horaFin = DateTime.now();
      final duracion = horaFin.difference(horaInicio);

      final Map<String, dynamic> dataToSave = visita.toFirestore();
      dataToSave['reporteDiarioId'] = reporteId;
      dataToSave['horaFin'] = Timestamp.fromDate(horaFin);
      dataToSave['duracion'] = duracion.inSeconds;

      await visitaDocRef.set(dataToSave);

      return await obtenerReportePorId(userId, reporteId);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw PermissionDeniedException(message: 'Permiso denegado para agregar visita a atracción.');
      } else if (e.code == 'not-found') {
        throw NotFoundException(message: 'Reporte diario no encontrado para agregar visita.');
      } else {
        throw ServerException(message: 'Error al agregar visita a atracción: ${e.message}');
      }
    } catch (e) {
      throw ServerException(message: 'Error inesperado al agregar visita a atracción: $e');
    }
  }

  @override
  Future<ReporteDiarioModel> finalizarDia({
    required String reporteId,
    required String userId,
  }) async {
    try {
      final reporteDocRef = firestore
          .collection('usuarios')
          .doc(userId)
          .collection('reportesDiarios')
          .doc(reporteId);

      await reporteDocRef.update({
        'fechaFin': Timestamp.now(),

      });


      return await obtenerReportePorId(userId, reporteId);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw PermissionDeniedException(message: 'Permiso denegado para finalizar día.');
      } else if (e.code == 'not-found') {
        throw NotFoundException(message: 'Reporte diario no encontrado.');
      } else {
        throw ServerException(message: 'Error al finalizar día: ${e.message}');
      }
    } catch (e) {
      throw ServerException(message: 'Error inesperado al finalizar día: $e');
    }
  }

  @override
  Future<ReporteDiarioModel> actualizarReporteDiario(ReporteDiarioModel reporte) async {
    try {
      await firestore
          .collection('usuarios')
          .doc(reporte.userId)
          .collection('reportesDiarios')
          .doc(reporte.id)
          .update(reporte.toJson());


      return await obtenerReportePorId(reporte.userId, reporte.id);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw PermissionDeniedException(message: 'Permiso denegado para actualizar reporte diario.');
      } else if (e.code == 'not-found') {
        throw NotFoundException(message: 'Reporte diario no encontrado para actualizar.');
      } else {
        throw ServerException(message: 'Error al actualizar reporte diario: ${e.message}');
      }
    } catch (e) {
      throw ServerException(message: 'Error inesperado al actualizar reporte diario: $e');
    }
  }
}