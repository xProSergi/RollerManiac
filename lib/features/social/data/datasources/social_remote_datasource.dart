import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/amigo.dart';
import '../../domain/entities/solicitud_amistad.dart';
import '../models/amigo_model.dart';
import '../models/solicitud_amistad_model.dart';

class SocialRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  SocialRemoteDataSource({
    required this.firestore,
    required this.auth,
  });

  String get userId => auth.currentUser!.uid;

  Future<List<SolicitudAmistad>> obtenerSolicitudes() async {
    final user = auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final snapshot = await firestore
        .collection('usuarios')
        .doc(user.uid)
        .collection('solicitudesRecibidas')
        .get();

    return snapshot.docs
        .map((doc) => SolicitudAmistadModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> agregarAmigo(String usernameInput) async {
    try {
      final currentUser = auth.currentUser;
      if (currentUser == null) throw Exception('Usuario no autenticado');

      final currentUserId = currentUser.uid;
      final currentUserEmail = currentUser.email;
      if (currentUserEmail == null) throw Exception('Usuario no tiene email');

      // Como el username es el correo hasta el arroba, corto el username hasta el @
      String username = usernameInput.trim().toLowerCase();
      if (username.contains('@')) {
        username = username.split('@')[0];
      }


      final query = await firestore
          .collection('usuarios')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (query.docs.isEmpty) throw Exception('Usuario no encontrado');

      final targetDoc = query.docs.first;
      final targetId = targetDoc.id;


      final amigoDoc = await firestore
          .collection('usuarios')
          .doc(currentUserId)
          .collection('amigos')
          .doc(targetId)
          .get();

      if (amigoDoc.exists) {
        throw Exception('Ya son amigos');
      }

      // Se crea la solicitud de amistad
      final nombre = currentUser.displayName ?? currentUserEmail.split('@')[0];
      final userUsername = currentUserEmail.split('@')[0].toLowerCase();

      await firestore
          .collection('usuarios')
          .doc(targetId)
          .collection('solicitudesRecibidas')
          .doc(currentUserId)
          .set({
        'email': currentUserEmail,
        'nombre': nombre,
        'displayName': nombre,
        'username': userUsername,
        'fecha': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      print('Error al agregar amigo: $e');
      rethrow;
    }
  }



  Future<void> aceptarSolicitud({
    required String currentUserId,
    required String amigoId,
    required String amigoUserName,
    required String amigoEmail,
    required String amigoDisplayName,
  }) async {
    final currentUserDoc = await firestore.collection('usuarios').doc(currentUserId).get();
    final currentUserData = currentUserDoc.data() ?? {};
    final currentUserNombre = currentUserData['displayName'] ?? currentUserData['email']?.split('@')[0] ?? '';


    await firestore
        .collection('usuarios')
        .doc(currentUserId)
        .collection('amigos')
        .doc(amigoId)
        .set({
      'email': amigoEmail,
      'displayName': amigoDisplayName,
      'username': amigoUserName.toLowerCase(),
      'fecha': FieldValue.serverTimestamp(),
    });


    await firestore
        .collection('usuarios')
        .doc(amigoId)
        .collection('amigos')
        .doc(currentUserId)
        .set({
      'email': currentUserData['email'] ?? '',
      'displayName': currentUserNombre,
      'username': (currentUserData['username'] ?? '').toLowerCase(),
      'fecha': FieldValue.serverTimestamp(),
    });

      // Eliminar solicitud una vez aceptada
    await firestore
        .collection('usuarios')
        .doc(currentUserId)
        .collection('solicitudesRecibidas')
        .doc(amigoId)
        .delete();
  }

  Future<List<Amigo>> obtenerRanking() async {
    final snapshot = await firestore
        .collection('usuarios')
        .doc(userId)
        .collection('amigos')
        .get();

    final amigos = snapshot.docs
        .map((doc) => AmigoModel.fromMap(doc.data(), doc.id))
        .toList();

    for (final amigo in amigos) {
      final amigoId = amigo.id;
      final visitas = await firestore
          .collection('usuarios')
          .doc(amigoId)
          .collection('visitas')
          .get();
      amigo.cantidadParques = visitas.size;
    }

    amigos.sort((a, b) => b.cantidadParques.compareTo(a.cantidadParques));
    return amigos;
  }

  Future<List<Amigo>> obtenerAmigos() async {
    final snapshot = await firestore
        .collection('usuarios')
        .doc(userId)
        .collection('amigos')
        .get();

    return snapshot.docs
        .map((doc) => AmigoModel.fromMap(doc.data(), doc.id))
        .toList();
  }
}