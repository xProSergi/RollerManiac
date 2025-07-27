import 'package:firebase_auth/firebase_auth.dart';

class AuthHelper {
  static String obtenerUsuarioActual() {
    final usuario = FirebaseAuth.instance.currentUser;
    if (usuario == null) {
      throw Exception('No hay un usuario autenticado actualmente');
    }
    return usuario.uid;
  }
}
