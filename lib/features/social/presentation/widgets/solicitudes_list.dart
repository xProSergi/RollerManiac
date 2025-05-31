import 'package:flutter/material.dart';
import '../../domain/entities/solicitud_amistad.dart';

class SolicitudesList extends StatelessWidget {
  final List<SolicitudAmistad> solicitudes;
  final Function(String userId) onAceptar;
  final Function(String solicitudId) onRechazar; // NEW: Callback for rejecting

  const SolicitudesList({
    Key? key,
    required this.solicitudes,
    required this.onAceptar,
    required this.onRechazar, // NEW
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: solicitudes.length,
        itemBuilder: (context, index) {
          final solicitud = solicitudes[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6.0),
            color: Colors.blueGrey[800],
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              title: Text(
                solicitud.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Row( // Use a Row to place buttons side-by-side
                mainAxisSize: MainAxisSize.min, // Important to prevent Row from taking full width
                children: [
                  ElevatedButton(
                    onPressed: () => onAceptar(solicitud.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF64B5F6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child: const Text("Aceptar", style: TextStyle(fontSize: 13)),
                  ),
                  const SizedBox(width: 8), // Space between buttons
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.redAccent), // "X" icon
                    onPressed: () => onRechazar(solicitud.id),
                    tooltip: 'Rechazar solicitud',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}