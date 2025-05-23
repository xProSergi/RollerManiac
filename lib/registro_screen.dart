import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math' as math;

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

  final RegExp emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');

  Future<void> _registrarUsuario() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Correo no válido')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La contraseña debe tener al menos 6 caracteres')),
      );
      return;
    }

    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/principal');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bienvenido ${userCredential.user!.email}')),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
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
                    'Crear Cuenta',
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
                              color: Colors.white.withOpacity(0.5),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
