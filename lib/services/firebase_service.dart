import 'package:flutter/foundation.dart'; // Añade este import
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> registrarVisita(String parqueId, String parqueNombre) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || !user.emailVerified) {
        throw Exception('Usuario no autenticado o email no verificado');
      }

      // Cambia doc(parqueId) por doc() para generar ID automático
      await _firestore
          .collection('usuarios')
          .doc(user.uid)
          .collection('visitas')
          .doc() // ID automático
          .set({
        'parqueId': parqueId,
        'parqueNombre': parqueNombre,
        'fecha': FieldValue.serverTimestamp(),
        'userId': user.uid,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error registrando visita: $e');
      }
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> obtenerVisitas() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final snapshot = await _firestore
          .collection('usuarios')
          .doc(user.uid)
          .collection('visitas')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          ...data,
          'id': doc.id,
        };
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error obteniendo visitas: $e');
      }
      rethrow;
    }
  }
}