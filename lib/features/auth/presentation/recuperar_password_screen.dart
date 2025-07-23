import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/validation_utils.dart';
import '../constantes/recuperar_password_constantes.dart';

class RecuperarPasswordScreen extends StatefulWidget {
  const RecuperarPasswordScreen({super.key});

  static String routeName = RecuperarPasswordConstantes.routeName;
  static String routePath = RecuperarPasswordConstantes.routePath;

  @override
  State<RecuperarPasswordScreen> createState() => _RecuperarPasswordScreenState();
}

class _RecuperarPasswordScreenState extends State<RecuperarPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _emailEnviado = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _enviarCorreoRecuperacion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      setState(() {
        _emailEnviado = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(RecuperarPasswordConstantes.correoEnviado),
          duration: Duration(seconds: 5),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = switch (e.code) {
        'invalid-email' => RecuperarPasswordConstantes.errorEmailInvalido,
        'user-not-found' => RecuperarPasswordConstantes.errorNoExiste,
        'too-many-requests' => RecuperarPasswordConstantes.errorDemasiadosIntentos,
        _ => 'Error:  [31m${e.message} [0m',
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(RecuperarPasswordConstantes.errorEnvio)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(RecuperarPasswordConstantes.imagenFondo),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    RecuperarPasswordConstantes.colorFondoOscuro.withAlpha(RecuperarPasswordConstantes.alphaFondo),
                    BlendMode.darken,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: RecuperarPasswordConstantes.colorFondoOscuro.withAlpha(RecuperarPasswordConstantes.alphaFondo),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          RecuperarPasswordConstantes.titulo,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            color: RecuperarPasswordConstantes.colorBlanco,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          RecuperarPasswordConstantes.instrucciones,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: RecuperarPasswordConstantes.colorBlanco70,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _emailController,
                          style: GoogleFonts.poppins(color: Colors.black87),
                          validator: ValidationUtils.validateEmail,
                          decoration: InputDecoration(
                            hintText: RecuperarPasswordConstantes.hintCorreo,
                            hintStyle: GoogleFonts.poppins(color: RecuperarPasswordConstantes.colorGris600),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: RecuperarPasswordConstantes.colorGris200,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 20,
                            ),
                            prefixIcon: Icon(Icons.email, color: RecuperarPasswordConstantes.colorGris600),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _enviarCorreoRecuperacion,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: RecuperarPasswordConstantes.colorBlanco,
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              RecuperarPasswordConstantes.enviarCorreo,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_emailEnviado)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: RecuperarPasswordConstantes.colorFondoVerde.withAlpha(RecuperarPasswordConstantes.alphaVerde),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          RecuperarPasswordConstantes.revisaCorreo,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: RecuperarPasswordConstantes.colorBlanco,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}