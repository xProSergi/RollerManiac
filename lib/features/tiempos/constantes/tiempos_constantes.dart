import 'package:flutter/material.dart';

class TiemposTextos {
  static const String tituloApp = 'RollerManiac';
  static const String tituloParques = 'Parques Temáticos';
  static const String tituloDetalles = 'Detalles del Parque';
  static const String cargando = 'Cargando parques...';
  static const String sinParques = 'No se encontraron parques';
  static const String sinAtracciones = 'No hay atracciones disponibles';
  static const String enMantenimiento = 'En mantenimiento';
  static const String registrarVisita = 'Registrar visita';
  static const String registrar = 'Registrar';
  static const String visitando = 'Visita registrada en';
  static const String errorCargar = 'Error al cargar los parques';
  static const String errorAtracciones = 'Error al cargar atracciones';
  static const String errorSesion = 'Debes iniciar sesión para registrar visitas';
  static const String errorVerificacion = 'Por favor verifica tu email para continuar';
  static const String warnerMadrid = 'San Martín de la Vega, Madrid, Spain';
  static const String portAventura = 'Salou, Tarragona, Spain';
  static const String ferrariLand = 'Salou, Tarragona, Spain';
}

class TiemposColores {
  static const Color fondo = Color(0xFF0F172A);
  static const Color tarjeta = Color(0xE61E293B); // 90% opacidad
  static const Color textoPrincipal = Colors.white;
  static const Color textoSecundario = Color(0xFF94A3B8);
  static const Color operativa = Color(0xFF4ADE80);
  static const Color mantenimiento = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color exito = Color(0xFF10B981);
  static const Color info = Color(0xFF3B82F6);
  static const Color botonPrimario = Color(0xFF2563EB);
  static const Color botonSecundario = Color(0xFF7C3AED);
  static const Color divisor = Color(0xFF334155);

  static const LinearGradient gradienteFondo = LinearGradient(
    colors: [
      Color(0xFF0056B3), // Azul intenso
      Color(0xFF000033), // Azul noche
    ],
    stops: [0.5, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class TiemposIconos {
  static const IconData parque = Icons.castle;
  static const IconData atraccion = Icons.attractions_rounded;
  static const IconData ubicacion = Icons.location_on;
  static const IconData clima = Icons.wb_sunny;
  static const IconData errorIcon = Icons.error_outline;
}

class TiemposTamanos {
  static const double paddingHorizontal = 16.0;
  static const double paddingVertical = 24.0;
  static const double separacionElementos = 16.0;
  static const double separacionInterna = 12.0;
  static const double radioBordes = 12.0;
  static const double elevacionTarjeta = 4.0;
}

class TiemposEstilos {
  static const TextStyle estiloTituloAppBar = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: TiemposColores.textoPrincipal,
    letterSpacing: 1.1,
    shadows: [
      Shadow(
        color: Colors.black54,
        blurRadius: 2,
        offset: Offset(1, 1),
      ),
    ],
  );

  static const TextStyle estiloTitulo = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: TiemposColores.textoPrincipal,
  );

  static const TextStyle estiloSubtitulo = TextStyle(
    fontSize: 14,
    color: TiemposColores.textoSecundario,
  );

  static const TextStyle estiloEstadoOperativo = TextStyle(
    fontSize: 13,
    color: Color(0xFF86EFAC),
  );

  static const TextStyle estiloEstadoMantenimiento = TextStyle(
    fontSize: 13,
    color: Color(0xFFFCD34D),
  );

  static const TextStyle estiloBotonPrimario = TextStyle(
    color: TiemposColores.textoPrincipal,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle estiloBotonSecundario = TextStyle(
    color: TiemposColores.textoPrincipal,
    fontSize: 12,
  );
}