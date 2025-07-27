import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;


  // static Future<void> registrarVisita(String parqueId, String parqueNombre) async {
  //   try {
  //     final user = _auth.currentUser;
  //     if (user == null) throw Exception('Usuario no autenticado');
  //
  //     Registrar visita principal
  //     await _firestore
  //         .collection('usuarios')
      //     .doc(user.uid)
      //     .collection('visitas')
      //     .add({
      //   'parqueId': parqueId,
      //   'parqueNombre': parqueNombre,
      //   'fecha': FieldValue.serverTimestamp(),
      //   'userId': user.uid,
      // });
      //

      // await _iniciarReporteDiario(user.uid, parqueId, parqueNombre);
    // } catch (e) {
    //   if (kDebugMode) {
    //     print('Error registrando visita: $e');
    //   }
    //   rethrow;
    // }
  // }

  // static Future<void> _iniciarReporteDiario(String userId, String parqueId, String parqueNombre) async {
  //   try {
  //     final ahora = DateTime.now();
  //     final fechaInicio = DateTime(ahora.year, ahora.month, ahora.day);
  //
  //     final reporteSnapshot = await _firestore
  //         .collection('usuarios')
  //         .doc(userId)
  //         .collection('reportes_diarios')
  //         .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(fechaInicio))
  //         .where('fecha', isLessThan: Timestamp.fromDate(fechaInicio.add(const Duration(days: 1))))
  //         .limit(1)
  //         .get();
  //
  //     if (reporteSnapshot.docs.isEmpty) {
  //       await _firestore
  //           .collection('usuarios')
  //           .doc(userId)
  //           .collection('reportes_diarios')
  //           .add({
  //         'fecha': Timestamp.fromDate(ahora),
  //         'parqueId': parqueId,
  //         'parqueNombre': parqueNombre,
  //         'userId': userId,
  //         'atraccionesVisitadas': [],
  //         'notas': null,
  //         'valoracionPromedio': null,
  //         'fechaFin': null,
  //         'sincronizado': false,
  //         'creadoEn': FieldValue.serverTimestamp(),
  //         'actualizadoEn': FieldValue.serverTimestamp(),
  //       });
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('Error iniciando reporte diario: $e');
  //     }
  //     throw e;
  //   }
  // }
  //
  //
  // static Future<void> registrarVisitaAtraccion(
  //     String parqueId,
  //     String parqueNombre,
  //     String atraccionNombre,
  //     ) async {
  //   try {
  //     final user = _auth.currentUser;
  //     if (user == null) throw Exception('Usuario no autenticado');
  //
  //     await _firestore
  //         .collection('usuarios')
  //         .doc(user.uid)
  //         .collection('visitas_atracciones')
  //         .add({
  //       'parqueId': parqueId,
  //       'parqueNombre': parqueNombre,
  //       'atraccionNombre': atraccionNombre,
  //       'fecha': FieldValue.serverTimestamp(),
  //       'userId': user.uid,
  //     });
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('Error registrando visita a atracción: $e');
  //     }
  //     rethrow;
  //   }
  // }
  //
  //
  // static Future<List<Map<String, dynamic>>> obtenerVisitas() async {
  //   try {
  //     final user = _auth.currentUser;
  //     if (user == null) throw Exception('Usuario no autenticado');
  //
  //     final snapshot = await _firestore
  //         .collection('usuarios')
  //         .doc(user.uid)
  //         .collection('visitas')
  //         .orderBy('fecha', descending: true)
  //         .get();
  //
  //     return snapshot.docs.map((doc) => {
  //       ...doc.data(),
  //       'id': doc.id,
  //     }).toList();
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('Error obteniendo visitas: $e');
  //     }
  //     rethrow;
  //   }
  // }


  // static Future<List<Map<String, dynamic>>> obtenerVisitasAtracciones(String parqueId) async {
  //   try {
  //     final user = _auth.currentUser;
  //     if (user == null) throw Exception('Usuario no autenticado');
  //
  //     final snapshot = await _firestore
  //         .collection('usuarios')
  //         .doc(user.uid)
  //         .collection('visitas_atracciones')
  //         .where('parqueId', isEqualTo: parqueId)
  //         .get();
  //
  //     return snapshot.docs.map((doc) => {
  //       ...doc.data(),
  //       'id': doc.id,
  //     }).toList();
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('Error obteniendo visitas a atracciones: $e');
  //     }
  //     rethrow;
  //   }
  // }
  //
  //
  // static Future<Map<String, int>> obtenerConteoVisitasAtracciones(String parqueId) async {
  //   try {
  //     final user = _auth.currentUser;
  //     if (user == null) throw Exception('Usuario no autenticado');
  //
  //     final snapshot = await _firestore
  //         .collection('usuarios')
  //         .doc(user.uid)
  //         .collection('visitas_atracciones')
  //         .where('parqueId', isEqualTo: parqueId)
  //         .get();
  //
  //     final conteo = <String, int>{};
  //
  //     for (var doc in snapshot.docs) {
  //       final data = doc.data();
  //       final nombre = data['atraccionNombre'] as String? ?? 'Desconocida';
  //       conteo[nombre] = (conteo[nombre] ?? 0) + 1;
  //     }
  //
  //     return conteo;
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('Error en obtenerConteoVisitasAtracciones: $e');
  //     }
  //     rethrow;
  //   }
  // }


  static Future<Map<String, Map<String, dynamic>>> obtenerDetalleVisitasAtracciones(String parqueId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final visitasSnapshot = await _firestore
        .collection('usuarios')
        .doc(user.uid)
        .collection('visitas_atracciones')
        .where('parqueId', isEqualTo: parqueId)
        .get();

    Map<String, Map<String, dynamic>> conteo = {};

    for (final doc in visitasSnapshot.docs) {
      final data = doc.data();
      final atraccionNombre = data['atraccionNombre'] as String? ?? 'Desconocida';
      final fecha = data['fecha'] as Timestamp?;

      if (!conteo.containsKey(atraccionNombre)) {
        conteo[atraccionNombre] = {
          'visitas': 0,
          'ultimaFecha': fecha,
        };
      }

      final visitasActuales = (conteo[atraccionNombre]!['visitas'] as num).toInt();
      conteo[atraccionNombre]!['visitas'] = visitasActuales + 1;

      if (fecha != null) {
        final ultimaFecha = conteo[atraccionNombre]!['ultimaFecha'] as Timestamp?;
        if (ultimaFecha == null || fecha.toDate().isAfter(ultimaFecha.toDate())) {
          conteo[atraccionNombre]!['ultimaFecha'] = fecha;
        }
      }
    }

    return conteo;
  }
}
