import 'package:flutter/material.dart';

class SocialColores {
  static const Color fondo = Color(0xFF0F172A);
  static const Color tarjeta = Color(0xFF1E293B);
  static const Color acento = Color(0xFF64B5F6);
  static const Color boton = Color(0xFF64B5F6);
  static const Color separador = Color(0xFF334155);
  static const Color textoClaro = Colors.white;
  static const Color textoClaroSecundario = Colors.white70;
  static const Color textoSecundario = Colors.white70;
  static const Color textoApagado = Colors.white54;
  static const Color error = Colors.redAccent;
  static const Color exito = Colors.green;
}

class SocialTextStyles {
  static const TextStyle tituloPantalla = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: SocialColores.textoClaro,
    letterSpacing: 0.8,
  );

  static const TextStyle tituloSeccion = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: SocialColores.textoClaroSecundario,
  );

  static const TextStyle textoSecundario = TextStyle(
    fontSize: 14,
    color: SocialColores.textoApagado,
  );

  static const TextStyle textoError = TextStyle(
    fontSize: 13,
    color: SocialColores.error,
  );

  static const TextStyle textoBoton = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: SocialColores.textoClaro,
  );

  static const TextStyle nombreUsuario = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: SocialColores.textoClaro,
  );

  static const TextStyle emailUsuario = TextStyle(
    fontSize: 14,
    color: SocialColores.textoClaroSecundario,
  );

  static const TextStyle textoTarjeta = TextStyle(
    fontSize: 16,
    color: SocialColores.textoClaro,
  );
}

class SocialTextos {
  static const String tituloSolicitudes = 'Solicitudes recibidas';
  static const String tituloAmigos = 'Amigos';
  static const String tituloRanking = 'Ranking entre amigos';

  static const String sinSolicitudes = 'No tienes solicitudes pendientes.';
  static const String sinAmigos = 'Aún no tienes amigos agregados.';
  static const String sinRanking = 'No hay datos de ranking disponibles.';

  static const String solicitudEnviada = '¡Solicitud de amistad enviada a';
  static const String errorEnvioSolicitud = 'Error al enviar solicitud:';
}