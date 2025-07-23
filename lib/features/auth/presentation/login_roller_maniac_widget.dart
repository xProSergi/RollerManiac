import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:math' as math;
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/utils/validation_utils.dart';
import '../constantes/login_constantes.dart';

class LoginRollerManiacWidget extends StatefulWidget {
  const LoginRollerManiacWidget({super.key});

  static String routeName = LoginConstantes.routeName;
  static String routePath = LoginConstantes.routePath;

  @override
  State<LoginRollerManiacWidget> createState() => _LoginRollerManiacWidgetState();
}

class _LoginRollerManiacWidgetState extends State<LoginRollerManiacWidget> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;
  final _formKey = GlobalKey<FormState>();

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

    /* Con el overlay hago que si tengo que mostrar un mensaje, se muestre por encima del resto
   *y  que si el teclado está abierto, el mensaje se muestre por encima del teclado para que no tape el mensaje
   */

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

  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);


      if (!userCredential.user!.emailVerified) {
        if (mounted) {
          await FirebaseAuth.instance.signOut();
          _mostrarSnackBar(
            icon: Icons.warning_rounded,
            message: LoginConstantes.porFavorVerificaCorreo,
            color: Colors.orange[100],
            duration: 5,
          );
        }
        return;
      }

      await guardarDatosUsuario(userCredential.user!);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/principal');
        _mostrarSnackBar(
          icon: Icons.check_circle_outline_rounded,
          message: LoginConstantes.bienvenido(userCredential.user!.email!),
          color: Colors.green[100],
          duration: 3,
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = switch (e.code) {
        'invalid-email' => 'Correo inválido.',
        'user-not-found' => 'No existe usuario con ese correo.',
        'wrong-password' => 'Contraseña incorrecta.',
        'user-disabled' => 'Esta cuenta ha sido deshabilitada.',
        'too-many-requests' => 'Demasiados intentos fallidos. Por favor, intenta más tarde.',
        'network-request-failed' => 'Error de conexión. Por favor, verifica tu conexión a internet.',
        _ => 'Error: ${e.message}',
      };
      _mostrarSnackBar(
        icon: Icons.error_outline_rounded,
        message: message,
        color: Colors.red[100],
        duration: 4,
      );
    } on SocketException catch (_) {
      _mostrarSnackBar(
        icon: Icons.wifi_off_rounded,
        message: LoginConstantes.noHayConexionInternet,
        color: Colors.red[100],
        duration: 4,
      );
    } catch (_) {
      if (!mounted) return;
      _mostrarSnackBar(
        icon: Icons.error_rounded,
        message: LoginConstantes.errorInesperado,
        color: Colors.red[100],
        duration: 4,
      );
    }
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
        _mostrarSnackBar(
          icon: Icons.check_circle_outline_rounded,
          message: LoginConstantes.bienvenido(userCredential.user?.displayName ?? 'usuario'),
          color: Colors.green[100],
          duration: 3,
        );
      }
    } catch (e) {
      if (mounted) {
        _mostrarSnackBar(
          icon: Icons.error_outline_rounded,
          message: LoginConstantes.errorAlIniciarConGoogle(e.toString()),
          color: Colors.red[100],
          duration: 4,
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
          color: Colors.white.withAlpha(230),
          shape: BoxShape.circle,
        ),
        child: FaIcon(icon, size: 20, color: Colors.black87),
      ),
    );
  }

  Future<void> guardarDatosUsuario(User user) async {
    try {
      final usuarioRef = FirebaseFirestore.instance.collection('usuarios').doc(user.uid);

      String username = '';
      if (user.email != null && user.email!.contains('@')) {
        username = user.email!.split('@')[0].toLowerCase();
      }

      await usuarioRef.set({
        'email': user.email ?? '',
        'displayName': user.displayName ?? username,
        'username': username,
        'ultimoLogin': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'emailVerified': user.emailVerified,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error guardando datos de usuario: $e');
      rethrow;
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
                  image: AssetImage(LoginConstantes.imagenLogin),
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
                    LoginConstantes.titulo,
                    style: GoogleFonts.interTight(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: LoginConstantes.colorFondoTitulo,
                    ),
                  ),
                  const SizedBox(height: 80),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Form(
                        key: _formKey,
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
                                  TextFormField(
                                    controller: _emailController,
                                    style: GoogleFonts.poppins(color: Colors.black87),
                                    validator: ValidationUtils.validateEmail,
                                    decoration: InputDecoration(
                                      hintText: LoginConstantes.correo,
                                      hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: !_passwordVisible,
                                    style: GoogleFonts.poppins(color: Colors.black87),
                                    validator: (password) => ValidationUtils.validatePassword(password, isLogin: true),
                                    decoration: InputDecoration(
                                      hintText: LoginConstantes.contrasena,
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
                                        LoginConstantes.olvidasteContrasena,
                                        style: GoogleFonts.poppins(color: Colors.black87, fontSize: 12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: _handleEmailLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: LoginConstantes.colorBotonLogin,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: Text(
                                      LoginConstantes.iniciarSesion,
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
                                          backgroundColor: LoginConstantes.colorBotonRegistro,
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        child: Text(
                                          LoginConstantes.crearCuenta,
                                          style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    LoginConstantes.oContinuaCon,
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
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(LoginConstantes.copyright, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white)),
                        Text(LoginConstantes.copyrightNombre, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white)),
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
