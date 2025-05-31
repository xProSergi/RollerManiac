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
      errorMessage = 'Error al cargar solicitudes: ${e.toString().replaceFirst('Exception: ', '')}';
    }
    notifyListeners();
  }

  Future<void> cargarAmigos() async {
    try {
      amigos = await obtenerAmigosUseCase();
      errorMessage = '';
    } catch (e) {
      errorMessage = 'Error al cargar amigos: ${e.toString().replaceFirst('Exception: ', '')}';
      amigos = [];
    }
    notifyListeners();
  }

  Future<void> cargarRanking() async {
    try {
      ranking = await obtenerRankingUseCase();
      errorMessage = '';
    } catch (e) {
      errorMessage = 'Error al cargar ranking: ${e.toString().replaceFirst('Exception: ', '')}';
    }
    notifyListeners();
  }

  // --- NEW: Check if user is already a friend or has a pending request ---
  Future<bool> esAmigoOConSolicitudPendiente(String targetUsername) async {
    final currentUserId = auth.currentUser?.uid;
    if (currentUserId == null) {
      throw Exception('Usuario no autenticado.');
    }

    // 1. Check if already friends
    // We can use the cached `amigos` list first for a quick check.
    if (amigos.any((amigo) => amigo.username.toLowerCase() == targetUsername.toLowerCase())) {
      return true;
    }
    // For a more robust check, especially if `amigos` list might be outdated or not fully loaded,
    // you could query Firestore directly:
    // final friendDoc = await firestore.collection('usuarios').doc(currentUserId)
    //     .collection('amigos').doc(targetUserId).get(); // You'd need targetUserId here
    // if (friendDoc.exists) { return true; }


    // 2. Check for pending requests sent by current user to target user
    final sentRequestDoc = await firestore.collection('usuarios').doc(targetUsername.toLowerCase()) // assuming targetUsername is the target user's UID or a unique identifier in the main users collection
        .collection('solicitudesRecibidas').doc(currentUserId).get();

    if (sentRequestDoc.exists) {
      return true; // Current user already sent a request to target
    }

    // 3. Check for pending requests received by current user from target user
    // We can use the cached `solicitudes` list for a quick check.
    if (solicitudes.any((solicitud) => solicitud.username.toLowerCase() == targetUsername.toLowerCase())) {
      return true;
    }
    // For a more robust check, especially if `solicitudes` list might be outdated,
    // you could query Firestore directly:
    // final receivedRequestDoc = await firestore.collection('usuarios').doc(currentUserId)
    //     .collection('solicitudesRecibidas').doc(targetUserId).get(); // You'd need targetUserId here
    // if (receivedRequestDoc.exists) { return true; }


    return false; // No existing friendship or pending request found
  }

  Future<void> agregarAmigoPorUsername(String usernameInput) async {
    final currentUserId = auth.currentUser?.uid;
    if (currentUserId == null) {
      throw Exception('Usuario no autenticado.');
    }

    // First, find the target user's ID based on usernameInput
    final targetUserQuery = await firestore.collection('usuarios')
        .where('username', isEqualTo: usernameInput.toLowerCase())
        .limit(1)
        .get();

    if (targetUserQuery.docs.isEmpty) {
      throw Exception('Usuario no encontrado.');
    }

    final targetUserId = targetUserQuery.docs.first.id;

    // Prevent sending request to self
    if (targetUserId == currentUserId) {
      throw Exception('No puedes enviarte una solicitud a ti mismo.');
    }

    // Check if already friends or has pending request BEFORE sending
    final isAlreadyRelated = await esAmigoOConSolicitudPendiente(usernameInput); // Using username for check
    if (isAlreadyRelated) {
      throw Exception('Ya eres amigo de este usuario o una solicitud ya está pendiente.');
    }

    try {
      await agregarAmigoUseCase(usernameInput); // This needs the target user's username
      errorMessage = '';
      notifyListeners();
    } catch (e) {
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
          currentUserData['displayName'] ?? currentUserData['email']?.split('@')[0] ?? '';
      final currentUsername =
      (currentUserData['username'] ?? currentUserData['email']?.split('@')[0] ?? '')
          .toLowerCase();

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

      await batch.commit();

      await cargarSolicitudes();
      await cargarAmigos();
      await cargarRanking();

      errorMessage = '';
    } catch (e) {
      errorMessage = 'Error al aceptar solicitud: ${e.toString().replaceFirst('Exception: ', '')}';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> rechazarSolicitud(String solicitudId) async {
    try {
      final currentUserId = auth.currentUser?.uid;
      if (currentUserId == null) {
        throw Exception('Usuario no autenticado.');
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
      errorMessage = 'Error al rechazar solicitud: ${e.toString().replaceFirst('Exception: ', '')}';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> eliminarAmigo(String amigoId) async {
    try {
      final currentUserId = auth.currentUser?.uid;
      if (currentUserId == null) {
        throw Exception('Usuario no autenticado.');
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
      errorMessage = 'Error al eliminar amigo: ${e.toString().replaceFirst('Exception: ', '')}';
      notifyListeners();
      rethrow;
    }
  }
}