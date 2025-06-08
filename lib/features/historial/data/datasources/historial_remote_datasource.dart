import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/visita_model.dart';

abstract class HistorialRemoteDataSource {
  Future<List<VisitaModel>> obtenerVisitas(String userId);
  Future<void> registrarVisita(VisitaModel visita);
  Future<void> eliminarVisita(String visitaId, String userId);
  Future<List<VisitaModel>> obtenerVisitasPorParque(String parqueId, String userId);
}

class HistorialRemoteDataSourceImpl implements HistorialRemoteDataSource {
  final FirebaseFirestore _firestore;

  HistorialRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<VisitaModel>> obtenerVisitas(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('usuarios')
          .doc(userId)
          .collection('visitas')
          .orderBy('fecha', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) {
        final data = doc.data();

        return VisitaModel.fromJson({
          ...data,
          'id': doc.id,
          'parqueId': data['parqueId']?.toString() ?? '',
          'parqueNombre': data['parqueNombre']?.toString() ?? '',
          'userId': data['userId']?.toString() ?? userId,
        });
      })
          .toList();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('No tienes permisos para acceder a este contenido');
      }
      throw Exception('Error al obtener visitas: ${e.message}');
    } catch (e) {
      throw Exception('Error al obtener visitas: $e');
    }
  }

  @override
  Future<void> registrarVisita(VisitaModel visita) async {
    try {
      final visitaData = visita.toJson();
      // Convertimos la fecha a Timestamp para Firestore
      visitaData['fecha'] = Timestamp.fromDate(visita.fecha);

      await _firestore
          .collection('usuarios')
          .doc(visita.userId)
          .collection('visitas')
          .add(visitaData);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('No tienes permisos para registrar visitas');
      }
      throw Exception('Error al registrar visita: ${e.message}');
    } catch (e) {
      throw Exception('Error al registrar visita: $e');
    }
  }

  @override
  Future<void> eliminarVisita(String visitaId, String userId) async {
    try {
      await _firestore
          .collection('usuarios')
          .doc(userId)
          .collection('visitas')
          .doc(visitaId)
          .delete();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('No tienes permisos para eliminar esta visita');
      }
      throw Exception('Error al eliminar visita: ${e.message}');
    } catch (e) {
      throw Exception('Error al eliminar visita: $e');
    }
  }

  @override
  Future<List<VisitaModel>> obtenerVisitasPorParque(String parqueId, String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('usuarios')
          .doc(userId)
          .collection('visitas_atracciones')
          .where('parqueId', isEqualTo: parqueId)
          .get();

      final visitas = querySnapshot.docs
          .map((doc) => VisitaModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      // Ordenamos en memoria en lugar de en la base de datos
      visitas.sort((a, b) => b.fecha.compareTo(a.fecha));

      return visitas;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('No tienes permisos para acceder a este contenido');
      }
      throw Exception('Error al obtener visitas por parque: ${e.message}');
    } catch (e) {
      throw Exception('Error al obtener visitas por parque: $e');
    }
  }
}