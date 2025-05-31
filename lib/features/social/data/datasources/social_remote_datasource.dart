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
    final snapshot = await firestore
        .collection('usuarios')
        .doc(userId)
        .collection('solicitudesRecibidas')
        .get();

    return snapshot.docs
        .map((doc) => SolicitudAmistadModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> agregarAmigo(String usernameInput) async {
    final currentUser = auth.currentUser!;
    String username = usernameInput.trim().toLowerCase();
    if (username.contains('@')) {
      username = username.split('@')[0];
    }

    if (username == currentUser.email!.split('@')[0].toLowerCase()) {
      throw Exception('No puedes agregarte a ti mismo');
    }

    final query = await firestore
        .collection('usuarios')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    // --- IMPORTANT CHANGE HERE ---
    // Throw the exception immediately if the user is not found
    if (query.docs.isEmpty) {
      throw Exception('Usuario no encontrado');
    }
    // --- END IMPORTANT CHANGE ---

    final targetDoc = query.docs.first;
    final targetId = targetDoc.id;

    final amigoDoc = await firestore
        .collection('usuarios')
        .doc(currentUser.uid)
        .collection('amigos')
        .doc(targetId)
        .get();

    if (amigoDoc.exists) throw Exception('Ya son amigos');

    final displayName = currentUser.displayName ?? currentUser.email!.split('@')[0];

    await firestore
        .collection('usuarios')
        .doc(targetId)
        .collection('solicitudesRecibidas')
        .doc(currentUser.uid)
        .set({
      'email': currentUser.email,
      'nombre': displayName,
      'displayName': displayName,
      'username': currentUser.email!.split('@')[0].toLowerCase(),
      'fecha': FieldValue.serverTimestamp(),
    });
  }

  Future<void> aceptarSolicitud({
    required String currentUserId,
    required String amigoId,
    required String amigoUserName,
    required String amigoEmail,
    required String amigoDisplayName,
  }) async {
    final currentUserDoc =
    await firestore.collection('usuarios').doc(currentUserId).get();
    final currentUserData = currentUserDoc.data() ?? {};

    final batch = firestore.batch();

    final currentUsername = (currentUserData['username'] ??
        currentUserData['email']?.split('@')[0] ??
        '')
        .toLowerCase();
    final currentDisplayName =
        currentUserData['displayName'] ?? currentUserData['email']?.split('@')[0] ?? '';

    // Añadir amigo a ambos usuarios
    batch.set(
      firestore.collection('usuarios').doc(currentUserId).collection('amigos').doc(amigoId),
      {
        'email': amigoEmail,
        'displayName': amigoDisplayName,
        'username': amigoUserName.toLowerCase(),
        'fecha': FieldValue.serverTimestamp(),
      },
    );

    batch.set(
      firestore.collection('usuarios').doc(amigoId).collection('amigos').doc(currentUserId),
      {
        'email': currentUserData['email'] ?? '',
        'displayName': currentDisplayName,
        'username': currentUsername,
        'fecha': FieldValue.serverTimestamp(),
      },
    );

    // Eliminar solicitud recibida
    batch.delete(
      firestore
          .collection('usuarios')
          .doc(currentUserId)
          .collection('solicitudesRecibidas')
          .doc(amigoId),
    );

    await batch.commit();
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
      final visitas = await firestore
          .collection('usuarios')
          .doc(amigo.id)
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