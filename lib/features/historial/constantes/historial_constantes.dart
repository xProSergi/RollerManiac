import 'package:flutter/material.dart';

class HistorialConstantes {
  // Strings
  static const String noHayVisitas = 'No hay visitas registradas';
  static const String errorCargandoVisitas = 'Error cargando visitas:';
  static const String visitas = 'Visitas';
  static const String ultima = 'Última';

  // Colores
  static const Color colorFondo = Color(0xFF0F172A);
  static const Color colorAccento = Colors.cyanAccent;
  static const Color colorAvatar = Colors.cyan;
  static const Color colorTexto = Colors.white;
  static const Color colorTextoSecundario = Colors.white70;
  static const Color colorError = Colors.red;

  // TextStyles
  static const TextStyle estiloTitulo = TextStyle(
    color: colorTexto,
    fontSize: 16,
  );

  static const TextStyle estiloVacio = TextStyle(
    color: colorTexto,
    fontSize: 18,
  );

  static const TextStyle estiloSubtitulo = TextStyle(
    color: colorTextoSecundario,
  );
}
