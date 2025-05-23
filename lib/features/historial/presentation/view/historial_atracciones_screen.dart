import 'package:flutter/material.dart';
import '../../../../services/firebase_service.dart';

class HistorialAtraccionesScreen extends StatelessWidget {
  final String parqueId;
  final String parqueNombre;

  const HistorialAtraccionesScreen({
    Key? key,
    required this.parqueId,
    required this.parqueNombre,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(
          'Atracciones en $parqueNombre',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<Map<String, int>>(
        future: FirebaseService.obtenerConteoVisitasAtracciones(parqueId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No has registrado visitas a atracciones en este parque',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final atracciones = snapshot.data!;
          final atraccionesList = atracciones.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return ListView.builder(
            itemCount: atraccionesList.length,
            itemBuilder: (context, index) {
              final entry = atraccionesList[index];
              return ListTile(
                leading: const Icon(Icons.attractions, color: Colors.cyanAccent),
                title: Text(
                  entry.key,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                subtitle: Text(
                  '${entry.value} ${entry.value == 1 ? 'vez' : 'veces'}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: Colors.white.withOpacity(0.5),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
