import 'package:flutter/material.dart';

class RecuperarPasswordConstantes {
  // Rutas
  static const String routeName = 'RecuperarPassword';
  static const String routePath = '/recuperar';

  // Textos
  static const String titulo = 'Recuperar contraseña';
  static const String instrucciones = 'Introduce tu correo electrónico para recibir las instrucciones:';
  static const String hintCorreo = 'Correo electrónico';
  static const String enviarCorreo = 'Enviar correo de confirmación';
  static const String correoEnviado = 'Correo de recuperación enviado. Por favor, revisa tu bandeja de entrada.';
  static const String revisaCorreo = 'Revisa tu correo para continuar con el cambio de contraseña.';
  static const String errorEnvio = 'Ocurrió un error al enviar el correo';
  static const String errorEmailInvalido = 'El correo electrónico no es válido.';
  static const String errorNoExiste = 'No existe ninguna cuenta con ese correo.';
  static const String errorDemasiadosIntentos = 'Demasiados intentos. Por favor, intenta más tarde.';

  // Imagen
  static const String imagenFondo = 'img/fotoRecPassword.jpg';

  // Colores
  static const Color colorFondoOscuro = Color(0xFF212121); // gris 850
  static const int alphaFondo = 179;
  static const Color colorFondoVerde = Color(0xFF2E7D32); // green[800]
  static const int alphaVerde = 179;
  static const Color colorBlanco = Colors.white;
  static const Color colorBlanco70 = Colors.white70;
  static const Color colorGris = Colors.grey;
  static const Color colorGris200 = Color(0xFFEEEEEE); // grey[200]
  static const Color colorGris600 = Color(0xFF757575); // grey[600]
}