import 'package:flutter/material.dart';
import '../../domain/entities/parque.dart';
import '../../domain/entities/atraccion.dart';

class DetallesParqueScreen extends StatelessWidget {
  final Parque parque;

  const DetallesParqueScreen({Key? key, required this.parque}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          parque.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: parque.atracciones.length,
        itemBuilder: (context, index) {
          final Atraccion atraccion = parque.atracciones[index];

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              leading: CircleAvatar(
                backgroundColor: atraccion.operativa
                    ? Colors.green[100]
                    : Colors.orange[100],
                child: Icon(
                  Icons.attractions,
                  color: atraccion.operativa
                      ? Colors.green[800]
                      : Colors.orange[800],
                ),
              ),
              title: Text(
                atraccion.nombre,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                atraccion.operativa
                    ? 'Espera: ${atraccion.tiempoEspera} min'
                    : 'En mantenimiento',
                style: TextStyle(
                  color: atraccion.operativa
                      ? Colors.green[800]
                      : Colors.orange[800],
                ),
              ),
              trailing: const Icon(Icons.timer, color: Colors.blue),
            ),
          );
        },
      ),
    );
  }
}
