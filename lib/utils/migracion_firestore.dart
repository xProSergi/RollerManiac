// lib/utils/migracion_firestore.dart

import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart'; // Ajusta la ruta si está en otro lugar

Future<void> migrarAmigos(String userId) async {
  final firestore = FirebaseFirestore.instance;

  final amigosSnapshot = await firestore
      .collection('usuarios')
      .doc(userId)
      .collection('amigos')
      .get();

  for (final amigoDoc in amigosSnapshot.docs) {
    final data = amigoDoc.data();

    final emailAmigo = data['email'] as String?;
    final nombreAmigo = (data['nombre'] as String?)?.isNotEmpty == true
        ? data['nombre']
        : null;
    final fecha = data['fecha'] as Timestamp?;

    if (emailAmigo == null) {
      print('Amigo sin email en ${amigoDoc.id}, saltando...');
      continue;
    }

    // Buscar userId del amigo por email
    final amigoQuery = await firestore
        .collection('usuarios')
        .where('email', isEqualTo: emailAmigo)
        .limit(1)
        .get();

    if (amigoQuery.docs.isEmpty) {
      print('No encontrado userId para amigo con email $emailAmigo');
      continue;
    }

    final amigoUserId = amigoQuery.docs.first.id;

    final nuevoDocRef = firestore
        .collection('usuarios')
        .doc(userId)
        .collection('amigos')
        .doc(amigoUserId);

    await nuevoDocRef.set({
      'email': emailAmigo,
      'nombre': nombreAmigo ?? '',
      'fecha': fecha ?? FieldValue.serverTimestamp(),
    });



    print('Migrado amigo $amigoUserId para usuario $userId');
  }
}

Future<void> migrarSolicitudesRecibidas(String userId) async {
  final firestore = FirebaseFirestore.instance;

  final solicitudesSnapshot = await firestore
      .collection('usuarios')
      .doc(userId)
      .collection('solicitudesRecibidas')
      .get();

  for (final solicitudDoc in solicitudesSnapshot.docs) {
    final data = solicitudDoc.data();

    final displayName = data['displayName'] as String?;
    final email = data['email'] as String?;
    final ultimoLogin = data['ultimoLogin'] as Timestamp?;
    final userName = data['userName'] as String?;

    // Dentro del documento hay un campo 'fecha' y 'email' del que envió la solicitud
    final fecha = data['fecha'] as Timestamp?;
    final emailRemitente = data['email'] as String?; // Asegúrate si es así o es otro campo

    if (email == null) {
      print('Solicitud sin email en ${solicitudDoc.id}, saltando...');
      continue;
    }

    // Buscar userId remitente por email
    final remitenteQuery = await firestore
        .collection('usuarios')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (remitenteQuery.docs.isEmpty) {
      print('No encontrado userId remitente para email $email');
      continue;
    }

    final remitenteUserId = remitenteQuery.docs.first.id;

    final nuevoDocRef = firestore
        .collection('usuarios')
        .doc(userId)
        .collection('solicitudesRecibidas')
        .doc(remitenteUserId);

    await nuevoDocRef.set({
      'displayName': displayName ?? '',
      'email': email,
      'ultimoLogin': ultimoLogin ?? FieldValue.serverTimestamp(),
      'userName': userName ?? '',
      'fecha': fecha ?? FieldValue.serverTimestamp(),
    });

    // Opcional: borrar doc antiguo con id automático
    // await solicitudDoc.reference.delete();

    print('Migrada solicitud recibida de $remitenteUserId para usuario $userId');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Lista con los userIds que quieres migrar
  List<String> userIds = [
    'kxHmWE4SCEgAydal1UJuuId08683',
    '3hvLhu6cEuNK8A6jE8yPXgCZUY32',
  ];


  for (final userId in userIds) {
    print('--- Migrando usuario $userId ---');
    await migrarAmigos(userId);
    await migrarSolicitudesRecibidas(userId);
  }

  print('Migración finalizada');
}
