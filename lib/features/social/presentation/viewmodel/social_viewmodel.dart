import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/amigo.dart';
import '../../domain/entities/solicitud_amistad.dart';
import '../../domain/usecases/aceptar_solicitud_usecase.dart';
import '../../domain/usecases/agregar_amigo_usecase.dart';
import '../../domain/usecases/obtener_amigos_usecase.dart';
import '../../domain/usecases/obtener_ranking_usecase.dart';
import '../../domain/usecases/obtener_solicitudes_recibidas_usecase.dart';

class SocialViewModel extends ChangeNotifier {
  final ObtenerSolicitudesRecibidasUseCase obtenerSolicitudesRecibidasUseCase;
  final AgregarAmigoUseCase agregarAmigoUseCase;
  final ObtenerAmigosUseCase obtenerAmigosUseCase;
  final AceptarSolicitudUseCase aceptarSolicitudUseCase;
  final ObtenerRankingUseCase obtenerRankingUseCase;


  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  List<SolicitudAmistad> solicitudes = [];
  List<Amigo> amigos = [];
  List<Amigo> ranking = [];
  String errorMessage = '';

  SocialViewModel({
    required this.obtenerSolicitudesRecibidasUseCase,
    required this.agregarAmigoUseCase,
    required this.obtenerAmigosUseCase,
    required this.aceptarSolicitudUseCase,
    required this.obtenerRankingUseCase,
  });

  Future<void> cargarSolicitudes() async {
    try {
      solicitudes = await obtenerSolicitudesRecibidasUseCase();
      errorMessage = '';
    } catch (e) {
      errorMessage = 'Error al cargar solicitudes: $e';
    }
    notifyListeners();
  }

  Future<void> cargarAmigos() async {
    try {
      amigos = await obtenerAmigosUseCase();
      errorMessage = '';
    } catch (e) {
      errorMessage = 'Error al cargar amigos: $e';
      amigos = [];
    }
    notifyListeners();
  }

  Future<void> cargarRanking() async {
    try {
      ranking = await obtenerRankingUseCase();
      errorMessage = '';
    } catch (e) {
      errorMessage = 'Error al cargar ranking: $e';
    }
    notifyListeners();
  }

  Future<void> agregarAmigoPorUsername(String usernameInput) async {
    errorMessage = '';
    notifyListeners();

    try {
      final currentUser = auth.currentUser;



      String username = usernameInput.toLowerCase();
      if (username.contains('@')) {
        username = username.split('@')[0];
      }

      if (username == currentUser.email!.split('@')[0].toLowerCase()) {
        throw Exception('No puedes agregarte a ti mismo');
      }


      final query = await firestore
          .collection('usuarios')
          .where('username', isEqualTo: username)
          .get();

      if (query.docs.isEmpty) {
        throw Exception('Usuario no encontrado');
      }

      final targetDoc = query.docs.first;
      final targetId = targetDoc.id;

      final nombre = currentUser.displayName ?? currentUser.email!.split('@')[0];


      await firestore
          .collection('usuarios')
          .doc(targetId)
          .collection('solicitudesRecibidas')
          .doc(currentUser.uid)
          .set({
        'email': currentUser.email,
        'nombre': nombre,
        'displayName': nombre,
        'username': currentUser.email!.split('@')[0].toLowerCase(),
        'fecha': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
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
    final batch = firestore.batch();


    final currentUserDoc = await firestore.collection('usuarios').doc(currentUserId).get();
    final currentUserData = currentUserDoc.data() ?? {};
    final currentUserNombre = currentUserData['displayName'] ?? currentUserData['email']?.split('@')[0] ?? '';
    final currentUsername = (currentUserData['username'] ?? currentUserData['email']?.split('@')[0] ?? '').toLowerCase();

    // Agregar amigo a mi colección
    batch.set(
      firestore
          .collection('usuarios')
          .doc(currentUserId)
          .collection('amigos')
          .doc(amigoId),
      {
        'email': amigoEmail,
        'displayName': amigoDisplayName,
        'username': amigoUserName.toLowerCase(),
        'fecha': FieldValue.serverTimestamp(),
      },
    );

    // Agregarme a la colección del amigo
    batch.set(
      firestore
          .collection('usuarios')
          .doc(amigoId)
          .collection('amigos')
          .doc(currentUserId),
      {
        'email': currentUserData['email'] ?? '',
        'displayName': currentUserNombre,
        'username': currentUsername,
        'fecha': FieldValue.serverTimestamp(),
      },
    );

    // Eliminar la solicitud
    batch.delete(
      firestore
          .collection('usuarios')
          .doc(currentUserId)
          .collection('solicitudesRecibidas')
          .doc(amigoId),
    );

    try {
      await batch.commit();
    } catch (e) {
      throw Exception('Error al aceptar solicitud: $e');
    }
  }
}
