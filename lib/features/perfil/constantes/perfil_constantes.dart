import 'package:flutter/material.dart';

class PerfilConstantes {
  // Strings
  static const String usuarioDefault = 'Usuario';
  static const String miembroDesde = 'Miembro desde';
  static const String cerrarSesion = 'Cerrar sesión';
  static const String editarPerfil = 'Editar perfil';
  static const String cambiarContrasena = 'Cambiar contraseña';
  static const String notificaciones = 'Notificaciones';
  static const String creditos = 'Créditos';
  static const String manualUsuario = 'Manual de usuario';
  static const String funcionNoImplementada = 'Función aún no implementada';
  static const String textoCreditos =
      'Tiempos de espera: Powered by Queue-times.com (2025)\n'
      'Fotografías realizadas por Coaster Rewind';
  static const String tituloCambiarContrasena = 'Cambiar contraseña';
  static const String labelNuevaContrasena = 'Nueva contraseña';
  static const String hintNuevaContrasena = 'Introduce tu nueva contraseña';
  static const String textoCancelar = 'Cerrar';
  static const String textoGuardar = 'Guardar';
  static const String errorContrasenaCorta = 'La contraseña debe tener al menos 6 caracteres';
  static const String exitoContrasenaActualizada = 'Contraseña actualizada correctamente';
  static const String errorContrasena =  'Error al actualizar la contraseña';
  static const String fechaNoDisponible = 'Fecha no disponible';
  // Colores
  static const Color colorFondo = Color(0xFF0F172A);
  static const Color colorTarjeta = Color(0xFF1E293B);
  static const Color colorBotonCerrarSesion = Colors.redAccent;
  static const Color colorTextoPrincipal = Colors.white;
  static const Color colorTextoSecundario = Color(0xFFCBD5E1);
  static const Color colorTextoFecha = Color(0xFF94A3B8);
  static const Color colorDivisor = Color(0xFF334155);

  // Gradiente
  static const LinearGradient gradienteFondo = LinearGradient(
    colors: [Color(0xFF0056B3), Color(0xFF000033)],
    stops: [0.5, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Iconos
  static const IconData iconoCerrarSesion = Icons.logout;
  static const IconData iconoEditar = Icons.edit;
  static const IconData iconoCambiarContrasena = Icons.lock;
  static const IconData iconoNotificaciones = Icons.notifications;
  static const IconData iconoPolitica = Icons.privacy_tip;
  static const IconData iconoTerminos = Icons.article;
  static const IconData iconoArrow = Icons.arrow_forward_ios;
  static const IconData iconoCreditos = Icons.info;

  // TextStyles
  static const TextStyle estiloUsername = TextStyle(
    color: colorTextoPrincipal,
    fontWeight: FontWeight.bold,
    fontSize: 24,
    shadows: [Shadow(color: Colors.black54, blurRadius: 2, offset: Offset(1, 1))],
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
    color: Colors.white,
  );

  static const TextStyle estiloOpcion = TextStyle(
    color: colorTextoPrincipal,
    fontSize: 16,
  );
}
