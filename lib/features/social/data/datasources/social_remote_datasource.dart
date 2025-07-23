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
    try {
      final currentUser = auth.currentUser!;
      if (currentUser.email == null) {
        throw Exception('Usuario no tiene email asociado');
      }

      final input = usernameInput.trim().toLowerCase();
      final currentUsername = currentUser.email!.split('@')[0].toLowerCase();

      QuerySnapshot query;
      if (input.contains('@')) {
        final emailLowerCase = input.toLowerCase();
        query = await firestore
            .collection('usuarios')
            .where('email', isEqualTo: emailLowerCase)
            .get();

        if (query.docs.isEmpty) {
          throw Exception('No se encontró ningún usuario con ese correo electrónico');
        }
      } else {
        query = await firestore
            .collection('usuarios')
            .where('username', isEqualTo: input)
            .limit(1)
            .get();
      }

      if (query.docs.isEmpty) {
        throw Exception(input.contains('@')
            ? 'No se encontró ningún usuario con ese correo electrónico'
            : 'No se encontró ningún usuario con ese nombre');
      }

      final targetDoc = query.docs.first;
      final targetId = targetDoc.id;

      if (targetId == currentUser.uid) {
        throw Exception('No puedes agregarte a ti mismo');
      }


      final amigoDoc = await firestore
          .collection('usuarios')
          .doc(currentUser.uid)
          .collection('amigos')
          .doc(targetId)
          .get();

      if (amigoDoc.exists) {
        throw Exception('Ya son amigos');
      }


      final solicitudExistente = await firestore
          .collection('usuarios')
          .doc(targetId)
          .collection('solicitudesRecibidas')
          .doc(currentUser.uid)
          .get();

      if (solicitudExistente.exists) {
        throw Exception('Ya existe una solicitud pendiente para este usuario');
      }


      await firestore
          .collection('usuarios')
          .doc(targetId)
          .collection('solicitudesRecibidas')
          .doc(currentUser.uid)
          .set({
        'username': currentUsername,
        'email': currentUser.email,
        'displayName': currentUser.displayName ?? currentUsername,
        'fecha': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      if (e is FirebaseException) {
        throw Exception('Error en la operación: ${e.message}');
      }
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

    final solicitudDoc = await firestore
        .collection('usuarios')
        .doc(currentUserId)
        .collection('solicitudesRecibidas')
        .doc(amigoId)
        .get();

    if (!solicitudDoc.exists) {
      throw Exception('La solicitud ya no existe');
    }

    final amigoDoc = await firestore
        .collection('usuarios')
        .doc(amigoId)
        .get();

    if (!amigoDoc.exists) {
      throw Exception('El usuario ya no existe');
    }

    final currentUserDoc = await firestore
        .collection('usuarios')
        .doc(currentUserId)
        .get();

    if (!currentUserDoc.exists) {
      throw Exception('Tu usuario no existe');
    }

    final batch = firestore.batch();
    final currentUserData = currentUserDoc.data() ?? {};

    final currentUsername = (currentUserData['username'] ??
        currentUserData['email']?.split('@')[0] ??
        '').toLowerCase();
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

    // Obtener los datos del usuario actual
    final currentUserDoc = await firestore.collection('usuarios').doc(userId).get();
    if (currentUserDoc.exists) {
      final data = currentUserDoc.data()!;
      final currentUser = AmigoModel(
        id: userId,
        email: data['email'] ?? '',
        displayName: data['displayName'] ?? '',
        username: data['username'] ?? '',
        cantidadParques: 0,
      );
      amigos.add(currentUser);
    }


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