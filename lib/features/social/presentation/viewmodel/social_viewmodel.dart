import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/amigo.dart';
import '../../domain/entities/solicitud_amistad.dart';
import '../../domain/usecases/aceptar_solicitud_usecase.dart';
import '../../domain/usecases/agregar_amigo_usecase.dart';
import '../../domain/usecases/obtener_amigos_usecase.dart';
import '../../domain/usecases/obtener_ranking_usecase.dart';
import '../../domain/usecases/obtener_solicitudes_recibidas_usecase.dart';
import '../../constantes/social_constantes.dart';

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
    int intentos = 0;
    const maxIntentos = 3;

    while (intentos < maxIntentos) {
      try {
        solicitudes = await obtenerSolicitudesRecibidasUseCase();
        errorMessage = '';
        notifyListeners();
        return;
      } catch (e) {
        intentos++;
        if (intentos == maxIntentos) {
          errorMessage = '${SocialTextos.errorCargarSolicitudes} $maxIntentos intentos: ${e.toString().replaceFirst('Exception: ', '')}';
          solicitudes = [];
          notifyListeners();
          rethrow;
        }
        // Espera antes de reintentar
        await Future.delayed(Duration(seconds: intentos));
      }
    }
  }

  Future<void> cargarAmigos() async {
    try {
      amigos = await obtenerAmigosUseCase();
      errorMessage = '';
    } catch (e) {
      errorMessage = '${SocialTextos.errorCargarAmigos} ${e.toString().replaceFirst('Exception: ', '')}';
      amigos = [];
    }
    notifyListeners();
  }

  Future<void> cargarRanking() async {
    try {
      ranking = await obtenerRankingUseCase();
      errorMessage = '';
    } catch (e) {
      errorMessage = '${SocialTextos.errorCargarRanking} ${e.toString().replaceFirst('Exception: ', '')}';
    }
    notifyListeners();
  }

  Future<bool> esAmigoOConSolicitudPendiente(String targetUsername) async {
    final currentUserId = auth.currentUser?.uid;
    if (currentUserId == null) {
      throw Exception(SocialTextos.errorUsuarioNoAutenticado);
    }

    if (amigos.any((amigo) => amigo.username.toLowerCase() == targetUsername.toLowerCase())) {
      return true;
    }

    final sentRequestDoc = await firestore.collection('usuarios').doc(targetUsername.toLowerCase())
        .collection('solicitudesRecibidas').doc(currentUserId).get();

    if (sentRequestDoc.exists) {
      return true;
    }

    if (solicitudes.any((solicitud) => solicitud.username.toLowerCase() == targetUsername.toLowerCase())) {
      return true;
    }

    return false;
  }

  Future<void> agregarAmigoPorUsername(String usernameInput) async {
    print(SocialTextos.logInicioAgregarAmigo);
    print('${SocialTextos.logInputRecibido} $usernameInput');

    final currentUserId = auth.currentUser?.uid;
    if (currentUserId == null) {
      throw Exception(SocialTextos.errorUsuarioNoAutenticado);
    }

    try {

      if (usernameInput.trim().isEmpty) {
        throw Exception(SocialTextos.errorUsernameVacio);
      }

      print('${SocialTextos.logLlamandoUseCase} $usernameInput');
      await agregarAmigoUseCase(usernameInput);
      print(SocialTextos.logUseCaseCompletado);
    } catch (e) {
      print('${SocialTextos.logErrorAgregarAmigo} $e');
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

    try {
      final currentUserDoc =
      await firestore.collection('usuarios').doc(currentUserId).get();
      final currentUserData = currentUserDoc.data() ?? {};
      final currentUserNombre =
          currentUserData[SocialTextos.campoDisplayName] ?? currentUserData[SocialTextos.campoEmail]?.split('@')[0] ?? '';
      final currentUsername =
      (currentUserData[SocialTextos.campoUsername] ?? currentUserData[SocialTextos.campoEmail]?.split('@')[0] ?? '')
          .toLowerCase();

      // Agregar amigo a mi colección
      batch.set(
        firestore
            .collection('usuarios')
            .doc(currentUserId)
            .collection('amigos')
            .doc(amigoId),
        {
          SocialTextos.campoEmail: amigoEmail,
          SocialTextos.campoDisplayName: amigoDisplayName,
          SocialTextos.campoUsername: amigoUserName.toLowerCase(),
          SocialTextos.campoFecha: FieldValue.serverTimestamp(),
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
          SocialTextos.campoEmail: currentUserData[SocialTextos.campoEmail] ?? '',
          SocialTextos.campoDisplayName: currentUserNombre,
          SocialTextos.campoUsername: currentUsername,
          SocialTextos.campoFecha: FieldValue.serverTimestamp(),
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

      await cargarSolicitudes();
      await cargarAmigos();
      await cargarRanking();

      errorMessage = '';
    } catch (e) {
      errorMessage = '${SocialTextos.errorAceptarSolicitud} ${e.toString().replaceFirst('Exception: ', '')}';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> rechazarSolicitud(String solicitudId) async {
    try {
      final currentUserId = auth.currentUser?.uid;
      if (currentUserId == null) {
        throw Exception(SocialTextos.errorUsuarioNoAutenticado);
      }

      await firestore
          .collection('usuarios')
          .doc(currentUserId)
          .collection('solicitudesRecibidas')
          .doc(solicitudId)
          .delete();

      await cargarSolicitudes();
      errorMessage = '';
    } catch (e) {
      errorMessage = '${SocialTextos.errorRechazarSolicitud} ${e.toString().replaceFirst('Exception: ', '')}';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> eliminarAmigo(String amigoId) async {
    try {
      final currentUserId = auth.currentUser?.uid;
      if (currentUserId == null) {
        throw Exception(SocialTextos.errorUsuarioNoAutenticado);
      }

      final batch = firestore.batch();

      // Eliminar al amigo de mi lista
      batch.delete(
        firestore
            .collection('usuarios')
            .doc(currentUserId)
            .collection('amigos')
            .doc(amigoId),
      );

      // Eliminarme de la lista del amigo
      batch.delete(
        firestore
            .collection('usuarios')
            .doc(amigoId)
            .collection('amigos')
            .doc(currentUserId),
      );

      await batch.commit();

      await cargarAmigos();
      await cargarRanking();
      errorMessage = '';
    } catch (e) {
      errorMessage = '${SocialTextos.errorEliminarAmigo} ${e.toString().replaceFirst('Exception: ', '')}';
      notifyListeners();
      rethrow;
    }
  }
}