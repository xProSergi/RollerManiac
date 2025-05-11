import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class RegistroScreen extends StatefulWidget {
  const RegistroScreen({Key? key}) : super(key: key);

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

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

      Navigator.pushReplacementNamed(context, '/principal');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bienvenido ${userCredential.user!.email}')),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('img/imagenLogin.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black26, BlendMode.darken),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 48.0),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Correo electrónico',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Contraseña',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  ElevatedButton(
                    onPressed: _registrarUsuario,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    ),
                    child: const Text('Crear cuenta'),
                  ),
                  const SizedBox(height: 24.0),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      '¿Ya tienes cuenta? Iniciar sesión',
                      style: TextStyle(color: Colors.white70),
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
