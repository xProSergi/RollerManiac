import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/exceptions.dart';
import '../models/reporte_diario_model.dart';
import '../models/visita_atraccion_model.dart';
// import '../models/visita_model.dart'; // REMOVED: Assuming VisitaModel is for general park visits and no longer used directly for persistence

abstract class HistorialRemoteDataSource {
  // CORRECTED: This now correctly reflects the signature used for attraction visits
  Future<List<VisitaAtraccionModel>> obtenerVisitas(String userId, String reporteId);
  // REMOVED: If registrarVisita was for a 'visitas' collection that no longer exists
  // Future<void> registrarVisita(VisitaModel visita);
  // Future<void> eliminarVisita(String visitaId, String userId);

  // CORRECTED: Now takes reporteId as it will be used in a where clause
  Future<List<VisitaAtraccionModel>> obtenerVisitasPorParque(String parqueId, String userId, String reporteId);

  // Daily Report methods
  Future<ReporteDiarioModel> obtenerReportePorId(String userId, String reporteId);
  Stream<ReporteDiarioModel?> obtenerReporteEnTiemReal(String reporteId, String userId);
  // Added: Stream for real-time attraction updates
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
    required String reporteId, // Ensure reporteId is passed
    required VisitaAtraccionModel visita,
  });
  Future<ReporteDiarioModel> finalizarVisitaAtraccion({
    required String reporteId,
    required String visitaId,
    required String userId,
    int? valoracion,
    String? notas,
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
          .collection('visitas_atracciones') // CORRECTED PATH
          .where('reporteDiarioId', isEqualTo: reporteId) // Filter by reporteId
          .get();

      return snapshot.docs
          .map((doc) => VisitaAtraccionModel.fromFirestore(doc, reporteId))
          .toList();
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

  // REMOVED registrarVisita and eliminarVisita methods if they targeted the old 'visitas' collection.
  // If you still use 'visitas_generales', you can put them back with correct collection path.

  @override
  Future<List<VisitaAtraccionModel>> obtenerVisitasPorParque(String parqueId, String userId, String reporteId) async {
    try {
      final snapshot = await firestore
          .collection('usuarios')
          .doc(userId)
          .collection('visitas_atracciones') // CORRECTED PATH
          .where('reporteDiarioId', isEqualTo: reporteId) // Filter by reporteId
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

  // --- Daily Report Methods ---
  @override
  Future<ReporteDiarioModel> obtenerReportePorId(String userId, String reporteId) async {
    try {
      final doc = await firestore
          .collection('usuarios')
          .doc(userId)
          .collection('reportesDiarios') // Assuming this is correct
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
        .collection('visitas_atracciones') // CORRECTED PATH
        .where('reporteDiarioId', isEqualTo: reporteId)
        .orderBy('fecha', descending: false) // Order by timestamp
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => VisitaAtraccionModel.fromFirestore(doc, reporteId))
        .toList());
  }

  @override
  Future<ReporteDiarioModel?> obtenerReporteDiarioActual(String userId, DateTime fecha) async {
    try {
      final startOfDay = DateTime(fecha.year, fecha.month, fecha.day);
      final endOfDay = startOfDay.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));

      final snapshot = await firestore
          .collection('usuarios')
          .doc(userId)
          .collection('reportesDiarios') // Assuming this is correct
          .where('fecha', isGreaterThanOrEqualTo: startOfDay)
          .where('fecha', isLessThanOrEqualTo: endOfDay)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }
      return ReporteDiarioModel.fromFirestore(snapshot.docs.first);
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
          .collection('reportesDiarios') // Assuming this is correct
          .where('fecha', isGreaterThanOrEqualTo: fechaInicio)
          .where('fecha', isLessThanOrEqualTo: fechaFin)
          .orderBy('fecha')
          .get();

      return snapshot.docs.map((doc) => ReporteDiarioModel.fromFirestore(doc)).toList();
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
      final newDocRef = firestore.collection('usuarios').doc(userId).collection('reportesDiarios').doc(); // Assuming this is correct
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
      // Use the ID from the model, which should already be generated by the UseCase/ViewModel
      final visitaDocRef = firestore
          .collection('usuarios')
          .doc(userId)
          .collection('visitas_atracciones') // CORRECTED PATH
          .doc(visita.id); // Use the ID from the incoming model

      // Ensure the 'reporteDiarioId' is set correctly within the model's data
      // (it should be part of VisitaAtraccionModel.toFirestore() if it's in the entity)
      // If not, explicitly add it here:
      final Map<String, dynamic> dataToSave = visita.toFirestore();
      dataToSave['reporteDiarioId'] = reporteId; // Ensure it's explicitly set for the query

      await visitaDocRef.set(dataToSave);

      // Now, return the ReporteDiarioModel, fetched to include latest data
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
  Future<ReporteDiarioModel> finalizarVisitaAtraccion({
    required String reporteId,
    required String visitaId,
    required String userId,
    int? valoracion,
    String? notas,
  }) async {
    try {
      final visitaDocRef = firestore
          .collection('usuarios')
          .doc(userId)
          .collection('visitas_atracciones') // CORRECTED PATH
          .doc(visitaId);

      final visitaDoc = await visitaDocRef.get();
      if (!visitaDoc.exists) {
        throw NotFoundException(message: 'Visita de atracción no encontrada.');
      }

      final currentData = visitaDoc.data() as Map<String, dynamic>;
      // 'fecha' is the horaInicio for attraction visits
      final horaInicioTimestamp = currentData['fecha'] as Timestamp;
      final horaInicio = horaInicioTimestamp.toDate();
      final horaFin = DateTime.now();
      final duracion = horaFin.difference(horaInicio);

      await visitaDocRef.update({
        'horaFin': Timestamp.fromDate(horaFin),
        'duracion': duracion.inSeconds, // Store duration in seconds
        'valoracion': valoracion,
        'notas': notas,
      });

      // Fetch and return the updated ReporteDiarioModel
      return await obtenerReportePorId(userId, reporteId);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw PermissionDeniedException(message: 'Permiso denegado para finalizar visita a atracción.');
      } else if (e.code == 'not-found') {
        throw NotFoundException(message: 'Visita o reporte diario no encontrado.');
      } else {
        throw ServerException(message: 'Error al finalizar visita a atracción: ${e.message}');
      }
    } catch (e) {
      throw ServerException(message: 'Error inesperado al finalizar visita a atracción: $e');
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
          .collection('reportesDiarios') // Assuming this is correct
          .doc(reporteId);

      await reporteDocRef.update({
        'fechaFin': Timestamp.now(), // Mark the end of the day
        // You might calculate total time spent in park, etc. here
      });

      // Fetch and return the updated ReporteDiarioModel
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
          .collection('reportesDiarios') // Assuming this is correct
          .doc(reporte.id)
          .update(reporte.toJson()); // Use update for existing, set for new or replace

      // Fetch and return the updated ReporteDiarioModel
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