import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:math' as math;
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';


class LoginRollerManiacWidget extends StatefulWidget {
  const LoginRollerManiacWidget({super.key});

  static String routeName = 'LoginRollerManiac';
  static String routePath = '/login';

  @override
  State<LoginRollerManiacWidget> createState() => _LoginRollerManiacWidgetState();
}

class _LoginRollerManiacWidgetState extends State<LoginRollerManiacWidget> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email'],
        
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);
      await guardarDatosUsuario(userCredential.user!);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/principal');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bienvenido ${userCredential.user?.displayName ?? 'usuario'}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al iniciar con Google: $e')),
        );
      }
    }
  }

  Widget _buildSocialIcon(IconData icon) {
    return GestureDetector(
      onTap: () {
        if (icon == FontAwesomeIcons.google) {
          signInWithGoogle();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: FaIcon(icon, size: 20, color: Colors.black87),
      ),
    );
  }

  Future<void> guardarDatosUsuario(User user) async {
    final usuarioRef = FirebaseFirestore.instance.collection('usuarios').doc(user.uid);


    String username = '';
    if (user.email != null && user.email!.contains('@')) {
      username = user.email!.split('@')[0];
    }

    await usuarioRef.set({
      'email': user.email,
      'displayName': user.displayName ?? username,
      'username': username,

      'ultimoLogin': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
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
                    'RollerManiac',
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
                                  style: GoogleFonts.poppins(color: Colors.black87),
                                  decoration: InputDecoration(
                                    hintText: 'Correo',
                                    hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[100],
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
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _passwordVisible ? Icons.visibility : Icons.visibility_off,
                                        color: Colors.grey[700],
                                      ),
                                      onPressed: () {
                                        setState(() => _passwordVisible = !_passwordVisible);
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/recuperar');
                                    },
                                    child: Text(
                                      '¿Olvidaste tu contraseña?',
                                      style: GoogleFonts.poppins(color: Colors.black87, fontSize: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: () async {
                                    final email = _emailController.text.trim();
                                    final password = _passwordController.text.trim();

                                    if (email.isEmpty || password.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Por favor completa todos los campos')),
                                      );
                                      return;
                                    }

                                    try {
                                      final userCredential = await FirebaseAuth.instance
                                          .signInWithEmailAndPassword(email: email, password: password);

                                      await guardarDatosUsuario(userCredential.user!);

                                      Navigator.pushReplacementNamed(context, '/principal');
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Bienvenido ${userCredential.user!.email}')),
                                      );
                                    } on FirebaseAuthException catch (e) {
                                      String message = switch (e.code) {
                                        'invalid-email' => 'Correo inválido.',
                                        'user-not-found' => 'No existe usuario con ese correo.',
                                        'wrong-password' => 'Contraseña incorrecta.',
                                        _ => 'Error: ${e.message}',
                                      };
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
                                    } catch (_) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Ocurrió un error inesperado')),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF546E7A),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Text(
                                    'Iniciar sesión',
                                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                                  ),
                                ),


                                const SizedBox(height: 16),
                                Align(
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.5,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pushNamed(context, '/registro');
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF78909C),
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      child: Text(
                                        'Crear nueva cuenta',
                                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'O continúa con',
                                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.black45),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildSocialIcon(FontAwesomeIcons.google),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
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
