import 'package:flutter/material.dart';

class PerfilScreen extends StatelessWidget {
  static const routeName = '/perfil';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: const Color(0xFF1E293B),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://www.example.com/avatar.png'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Nombre de Usuario',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Email: usuario@example.com',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {

              },
              child: const Text('Cerrar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
