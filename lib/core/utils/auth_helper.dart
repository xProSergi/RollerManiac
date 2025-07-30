import 'package:firebase_auth/firebase_auth.dart';

class AuthHelper {
  static String? obtenerUsuarioActual() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  static User? obtenerUsuarioCompleto() {
    return FirebaseAuth.instance.currentUser;
  }

  static bool estaAutenticado() {
    return FirebaseAuth.instance.currentUser != null;
  }

  static Future<void> cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
  }
}