import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  static DatabaseReference get _databaseRef {
    return FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: 'https://rollermaniac-a54df-default-rtdb.europe-west1.firebasedatabase.app',
    ).ref();
  }

  static Future<void> registrarVisita(String parqueId, String parqueNombre) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final visitaRef = _databaseRef.child('usuarios/$uid/visitas').push();

    await visitaRef.set({
      'parqueId': parqueId,
      'parqueNombre': parqueNombre,
      'fecha': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<Map<String, dynamic>>> obtenerVisitas() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Usuario no autenticado');

    final snapshot = await _databaseRef.child('usuarios/$uid/visitas').get();

    if (!snapshot.exists) return [];

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    final visitas = <Map<String, dynamic>>[];

    data.forEach((_, value) {
      visitas.add(Map<String, dynamic>.from(value));
    });

    return visitas;
  }
}