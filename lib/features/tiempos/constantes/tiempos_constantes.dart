// lib/features/tiempos/constantes/tiempos_constantes.dart

import 'package:flutter/material.dart';

class TiemposColores {
  // Colores principales
  static const Color fondoOscuro = Color(0xFF0F172A);
  static const Color tarjetaOscura = Color(0xFF1E293B);
  static const Color fondoClaro = Color(0xFFF8FAFC);
  static const Color tarjetaClara = Colors.white;

  // Colores de texto
  static const Color textoClaro = Colors.white;
  static const Color textoOscuro = Color(0xFF1E293B);
  static const Color textoSecundarioClaro = Color(0xFF94A3B8);
  static const Color textoSecundarioOscuro = Color(0xFF64748B);

  // Colores de estado
  static const Color operativa = Color(0xFF4ADE80);
  static const Color mantenimiento = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color exito = Color(0xFF10B981);
  static const Color info = Color(0xFF3B82F6);

  // Colores de botones
  static const Color botonPrimario = Color(0xFF2563EB);
  static const Color botonSecundario = Color(0xFF7C3AED);
}

class TiemposTextos {
  // Títulos
  static const String tituloApp = 'RollerManiac';
  static const String tituloParques = 'Parques Temáticos';
  static const String tituloDetalles = 'Detalles del Parque';

  // Mensajes
  static const String cargando = 'Cargando parques...';
  static const String sinParques = 'No se encontraron parques';
  static const String sinAtracciones = 'No hay atracciones disponibles';
  static const String enMantenimiento = 'En mantenimiento';
  static const String registrarVisita = 'Registrar visita';
  static const String registrar = 'Registrar';
  static const String visitando = 'Visita registrada en: ';

  // Errores
  static const String errorCargar = 'Error al cargar los parques';
  static const String errorAtracciones = 'Error al cargar atracciones';
  static const String errorSesion = 'Debes iniciar sesión para registrar visitas';
  static const String errorVerificacion = 'Por favor verifica tu email para continuar';

  // Ubicaciones
  static const String warnerMadrid = 'San Martín de la Vega, Madrid, Spain';
  static const String portAventura = 'Salou, Tarragona, Spain';
  static const String ferrariLand = 'Salou, Tarragona, Spain';
}

class TiemposEstilos {
  // Estilos de texto oscuro
  static const TextStyle tituloAppBarOscuro = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: TiemposColores.textoClaro,
    letterSpacing: 1.1,
  );

  static const TextStyle tituloParqueOscuro = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: TiemposColores.textoClaro,
  );

  static const TextStyle subtituloOscuro = TextStyle(
    fontSize: 14,
    color: TiemposColores.textoSecundarioClaro,
  );

  static const TextStyle estadoOperativo = TextStyle(
    fontSize: 13,
    color: Color(0xFF86EFAC),
  );

  static const TextStyle estadoMantenimiento = TextStyle(
    fontSize: 13,
    color: Color(0xFFFCD34D),
  );

  // Estilos de texto claro
  static const TextStyle tituloAppBarClaro = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: TiemposColores.textoClaro,
  );

  static const TextStyle tituloParqueClaro = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: TiemposColores.textoOscuro,
  );

  static const TextStyle subtituloClaro = TextStyle(
    fontSize: 14,
    color: TiemposColores.textoSecundarioOscuro,
  );

  // Estilos de botones
  static const TextStyle botonPrimario = TextStyle(
    color: TiemposColores.textoClaro,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle botonSecundario = TextStyle(
    color: TiemposColores.textoClaro,
    fontSize: 12,
  );
}

class TiemposIconos {
  static const IconData parque = Icons.castle;
  static const IconData atraccion = Icons.attractions_rounded;
  static const IconData ubicacion = Icons.location_on;
  static const IconData clima = Icons.wb_sunny;
  static const IconData error = Icons.error_outline;
}

class TiemposTamanos {
  static const double paddingHorizontal = 16.0;
  static const double paddingVertical = 24.0;
  static const double separacionElementos = 16.0;
  static const double separacionInterna = 12.0;
  static const double radioBordes = 12.0;
  static const double elevacionTarjeta = 1.0;
}