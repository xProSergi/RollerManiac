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
    print('=== INICIO agregarAmigo ===');
    print('Input recibido: $usernameInput');

    try {
      final currentUser = auth.currentUser!;
      print('Usuario actual: ${currentUser.email}');

      if (currentUser.email == null) {
        throw Exception('Usuario no tiene email asociado');
      }


      String input = usernameInput.trim().toLowerCase();
      print('Input normalizado: $input');


      final currentUsername = currentUser.email!.split('@')[0].toLowerCase();
      print('Username actual: $currentUsername');


      QuerySnapshot query;
      if (input.contains('@')) {

        print('=== INICIO BÚSQUEDA POR EMAIL ===');
        print('Email original: $input');
        try {

          final emailLowerCase = input.toLowerCase();
          print('Email en minúsculas: $emailLowerCase');

          print('Iniciando búsqueda en Firestore...');

          final userQuery = await firestore
              .collection('usuarios')
              .where('email', isEqualTo: emailLowerCase)
              .get();

          print('Búsqueda completada. Documentos encontrados: ${userQuery.docs.length}');


          if (userQuery.docs.isEmpty) {
            print('NO SE ENCONTRÓ EL USUARIO');
            print('Buscando todos los usuarios para debug...');
            final allUsers = await firestore
                .collection('usuarios')
                .get();

            print('Total de usuarios en la base de datos: ${allUsers.docs.length}');
            print('=== LISTA DE USUARIOS ===');
            for (var doc in allUsers.docs) {
              final userData = doc.data() as Map<String, dynamic>;
              print('----------------------------------------');
              print('ID: ${doc.id}');
              print('Email: ${userData['email']}');
              print('Username: ${userData['username']}');
              print('DisplayName: ${userData['displayName']}');
              print('----------------------------------------');
            }

            throw Exception('No se encontró ningún usuario con ese correo electrónico');
          }


          query = userQuery;

          final foundUser = query.docs.first.data() as Map<String, dynamic>;
          print('=== USUARIO ENCONTRADO ===');
          print('ID: ${query.docs.first.id}');
          print('Email: ${foundUser['email']}');
          print('Username: ${foundUser['username']}');
          print('DisplayName: ${foundUser['displayName']}');
          print('=== FIN BÚSQUEDA POR EMAIL ===');
        } catch (e) {
          print('=== ERROR EN BÚSQUEDA POR EMAIL ===');
          print('Error detallado: $e');
          if (e is FirebaseException) {
            print('Código de error Firebase: ${e.code}');
            print('Mensaje de error Firebase: ${e.message}');
          }
          print('=== FIN ERROR ===');
          rethrow;
        }
      } else {

        print('=== INICIO BÚSQUEDA POR USERNAME ===');
        print('Username a buscar: $input');
        query = await firestore
            .collection('usuarios')
            .where('username', isEqualTo: input)
            .limit(1)
            .get();
        print('Búsqueda completada. Documentos encontrados: ${query.docs.length}');
        print('=== FIN BÚSQUEDA POR USERNAME ===');
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

      // Verificar si ya son amigos
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

      print('Intentando crear solicitud:');
      print('Usuario actual (remitente) ID: ${currentUser.uid}');
      print('Usuario destino ID: $targetId');

      // Crear la solicitud
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
      print('Error detallado al agregar amigo:');
      print(e);
      if (e is FirebaseException) {
        print('Código de error: ${e.code}');
        print('Mensaje de error: ${e.message}');
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

    // Verificar que los documentos existan antes de la operación
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