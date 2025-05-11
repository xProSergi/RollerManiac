import 'package:flutter/material.dart';
import '../../domain/entities/parque.dart';
import '../../domain/entities/atraccion.dart';

class DetallesParqueScreen extends StatelessWidget {
  final Parque parque;

  const DetallesParqueScreen({Key? key, required this.parque}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        centerTitle: true,
        title: Text(
          parque.nombre,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 1.05,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ListView.separated(
          itemCount: parque.atracciones.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final Atraccion atraccion = parque.atracciones[index];
            final bool operativa = atraccion.operativa;

            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.attractions_rounded,
                    color: operativa ? Colors.greenAccent[400] : Colors.amberAccent[200],
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          atraccion.nombre,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          operativa
                              ? 'Espera: ${atraccion.tiempoEspera} min'
                              : 'En mantenimiento',
                          style: TextStyle(
                            color: operativa
                                ? Colors.greenAccent[100]
                                : Colors.amberAccent[100],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.timer_outlined,
                    color: Colors.white54,
                    size: 20,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
