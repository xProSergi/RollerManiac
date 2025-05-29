import 'package:flutter/material.dart';

class HistorialConstantes {
  // Strings (mantenerlos constantes)
  static const String noHayVisitas = 'No hay visitas registradas';
  static const String errorCargandoVisitas = 'Error cargando visitas:';
  static const String visitas = 'Visitas';
  static const String ultima = 'Última';

  // Paleta de colores
  static const Color colorFondo = Color(0xFF1A1A2E);
  static const Color colorSuperficie = Color(0xFF232946);
  static const Color colorAccento = Color(0xFFEE6C4D); // Color de la noria (rojo/naranja)
  static const Color colorAzulVivo = Color(0xFF00B0FF);
  static const Color colorSecundario = Color(0xFF98C1D9);
  static const Color colorTerciario = Color(0xFF3D5A80);
  static const Color colorTexto = Color(0xFFE0FBFC);
  static const Color colorTextoSecundario = Color(0xFFA5A5A5);
  static const Color colorError = Color(0xFFEE6C4D);
  static const Color colorAvatar = Color(0xFF00B0FF);

  // Nuevos colores para el degradado
  static const Color degradadoAzulInicio = Color(0xFF0056B3);
  static const Color degradadoAzulFin = Color(0xFF000033);

  // Sombra
  static const BoxShadow sombraTile = BoxShadow(
    color: Colors.black54,
    blurRadius: 8,
    offset: Offset(0, 4),
  );

  // Gradiente
  static const LinearGradient gradienteFondo = LinearGradient(
    colors: [degradadoAzulInicio, degradadoAzulFin],
    stops: [0.5, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // TextStyles
  // TextStyles
  static const TextStyle estiloTitulo = TextStyle(
    color: colorTexto,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle estiloVacio = TextStyle(
    color: colorTextoSecundario,
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle estiloSubtitulo = TextStyle(
    color: colorTextoSecundario,
  );

// Change this line:
  static const TextStyle estiloTituloAppBar = TextStyle(
    color: colorTexto, // Changed from degradadoAzulInicio to colorTexto
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
}
