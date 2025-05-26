import 'package:flutter/material.dart';

class PerfilConstantes {
  // Strings
  static const String usuarioDefault = 'Usuario';
  static const String miembroDesde = 'Miembro desde';
  static const String cerrarSesion = 'Cerrar sesión';
  static const String editarPerfil = 'Editar perfil';
  static const String cambiarContrasena = 'Cambiar contraseña';
  static const String notificaciones = 'Notificaciones';
  static const String politicaPrivacidad = 'Política de privacidad';
  static const String terminosCondiciones = 'Términos y condiciones';
  static const String funcionNoImplementada = 'Función aún no implementada';

  // Colores
  static const Color colorFondo = Color(0xFF0F172A);
  static const Color colorTarjeta = Color(0xFF1E293B);
  static const Color colorBotonCerrarSesion = Colors.redAccent;
  static const Color colorTextoPrincipal = Colors.white;
  static const Color colorTextoSecundario = Colors.white70;
  static const Color colorTextoFecha = Colors.white54;

  // Iconos
  static const IconData iconoCerrarSesion = Icons.logout;
  static const IconData iconoEditar = Icons.edit;
  static const IconData iconoCambiarContrasena = Icons.lock;
  static const IconData iconoNotificaciones = Icons.notifications;
  static const IconData iconoPolitica = Icons.privacy_tip;
  static const IconData iconoTerminos = Icons.article;
  static const IconData iconoArrow = Icons.arrow_forward_ios;

  // TextStyles
  static const TextStyle estiloUsername = TextStyle(
    color: colorTextoPrincipal,
    fontWeight: FontWeight.bold,
    fontSize: 24,
  );

  static const TextStyle estiloEmail = TextStyle(
    color: colorTextoSecundario,
    fontSize: 16,
  );

  static const TextStyle estiloFecha = TextStyle(
    color: colorTextoFecha,
    fontStyle: FontStyle.italic,
    fontSize: 14,
  );

  static const TextStyle estiloBotonCerrarSesion = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
}
