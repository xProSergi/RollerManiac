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

  static const LinearGradient gradienteFondo = LinearGradient(
    colors: [
      Color(0xFF0056B3),
      Color(0xFF000033),
    ],
    stops: [0.5, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
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
  static const String textoAgregar = 'Agregar amigo (user o correo)';
  static const String tituloSolicitudes = 'Solicitudes recibidas';
  static const String tituloAmigos = 'Amigos';
  static const String tituloRanking = 'Ranking entre amigos';

  static const String sinSolicitudes = 'No tienes solicitudes pendientes.';
  static const String sinAmigos = 'Aún no tienes amigos agregados.';
  static const String sinRanking = 'No hay datos de ranking disponibles.';

  static const String solicitudEnviada = '¡Solicitud de amistad enviada a';
  static const String errorEnvioSolicitud = 'Error al enviar solicitud:';


  static const String tituloRechazarSolicitud = 'Rechazar Solicitud';
  static const String mensajeRechazarSolicitud = '¿Estás seguro de que quieres rechazar esta solicitud de amistad?';
  static const String botonCancelar = 'Cancelar';
  static const String botonRechazar = 'Rechazar';
  static const String solicitudRechazada = 'Solicitud rechazada.';
  static const String errorRechazarSolicitud = 'Error al rechazar solicitud:';


  static const String tituloEliminarAmigo = 'Eliminar Amigo';
  static const String mensajeEliminarAmigo = '¿Estás seguro de que quieres eliminar a este amigo?';
  static const String botonEliminar = 'Eliminar';
  static const String amigoEliminado = 'Amigo eliminado correctamente.';
  static const String errorEliminarAmigo = 'Error al eliminar amigo:';


  static const String errorUsuarioNoAutenticado = 'Usuario no autenticado.';
  static const String errorUsernameVacio = 'El nombre de usuario no puede estar vacío';
  static const String errorCargarSolicitudes = 'Error al cargar solicitudes después de';
  static const String errorCargarAmigos = 'Error al cargar amigos:';
  static const String errorCargarRanking = 'Error al cargar ranking:';
  static const String errorAceptarSolicitud = 'Error al aceptar solicitud:';


  static const String logInicioAgregarAmigo = '=== INICIO agregarAmigoPorUsername ===';
  static const String logInputRecibido = 'Input recibido en viewmodel:';
  static const String logLlamandoUseCase = 'Llamando a agregarAmigoUseCase con input:';
  static const String logUseCaseCompletado = 'agregarAmigoUseCase completado exitosamente';
  static const String logErrorAgregarAmigo = 'Error en agregarAmigoPorUsername:';


  static const String campoEmail = 'email';
  static const String campoDisplayName = 'displayName';
  static const String campoUsername = 'username';
  static const String campoFecha = 'fecha';
}