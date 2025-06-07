import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../../../core/utils/validation_utils.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  static String routeName = 'RegistroScreen';
  static String routePath = '/registro';

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _mostrarSnackBar({
    required IconData icon,
    required String message,
    required Color? color,
    required int duration,
  }) {

    final overlay = Overlay.of(context);


    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;


    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(

        bottom: keyboardHeight > 0 ? keyboardHeight : 20,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(26),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(icon, color: Colors.black87, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(Duration(seconds: duration), () {
      overlayEntry.remove();
    });
  }

  Future<void> _registrarUsuario() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;


    final validacionEmail = ValidationUtils.validateEmail(email);
    if (validacionEmail != null) {
      _mostrarSnackBar(
        icon: Icons.error_outline_rounded,
        message: validacionEmail,
        color: Colors.red[100],
        duration: 4,
      );
      return;
    }


    final validacionPassword = ValidationUtils.validatePassword(password);
    if (validacionPassword != null) {
      _mostrarSnackBar(
        icon: Icons.error_outline_rounded,
        message: validacionPassword,
        color: Colors.red[100],
        duration: 4,
      );
      return;
    }

    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );


      await userCredential.user!.sendEmailVerification();

      if (mounted) {
        _mostrarSnackBar(
          icon: Icons.check_circle_outline_rounded,
          message: 'Cuenta creada exitosamente. Por favor, verifica tu correo electrónico antes de iniciar sesión.',
          color: Colors.green[100],
          duration: 5,
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String message = switch (e.code) {
        'email-already-in-use' => 'Ya existe una cuenta con este correo electrónico.',
        'invalid-email' => 'El correo electrónico no es válido.',
        'operation-not-allowed' => 'La creación de cuentas está deshabilitada.',
        'weak-password' => 'La contraseña es muy débil.',
        _ => 'Error: ${e.message}',
      };
      _mostrarSnackBar(
        icon: Icons.warning_rounded,
        message: message,
        color: Colors.orange[100],
        duration: 4,
      );
    } catch (e) {
      _mostrarSnackBar(
        icon: Icons.error_rounded,
        message: 'Ocurrió un error inesperado',
        color: Colors.red[100],
        duration: 4,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('img/imagenLogin.jpg'),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
                ),
              ),
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationX(math.pi),
                child: Container(),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  Text(
                    'Crear cuenta',
                    style: GoogleFonts.interTight(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFB0BEC5),
                    ),
                  ),
                  const SizedBox(height: 80),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          Container(
                            width: size.width > 500 ? 400 : double.infinity,
                            padding: const EdgeInsets.all(24.0),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(128),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  style: GoogleFonts.poppins(color: Colors.black87),
                                  decoration: InputDecoration(
                                    hintText: 'Correo electrónico',
                                    hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: _passwordController,
                                  obscureText: !_passwordVisible,
                                  style: GoogleFonts.poppins(color: Colors.black87),
                                  decoration: InputDecoration(
                                    hintText: 'Contraseña',
                                    hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _passwordVisible ? Icons.visibility : Icons.visibility_off,
                                        color: Colors.grey[700],
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _passwordVisible = !_passwordVisible;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: _registrarUsuario,
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: const Color(0xFF546E7A),
                                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                  child: Text(
                                    'Crear cuenta',
                                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    '¿Ya tienes cuenta? Inicia sesión',
                                    style: GoogleFonts.poppins(color: Colors.black87, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('© ', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white)),
                        Text('Coaster Rewind', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}