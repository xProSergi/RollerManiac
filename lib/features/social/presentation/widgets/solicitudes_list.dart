import 'package:flutter/material.dart';
import '../../domain/entities/solicitud_amistad.dart';

class SolicitudesList extends StatelessWidget {
  final List<SolicitudAmistad> solicitudes;
  final Function(String userId) onAceptar;

  const SolicitudesList({
    Key? key,
    required this.solicitudes,
    required this.onAceptar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Wrap ListView.builder in a SizedBox to provide explicit width
    return SizedBox(
      width: double.infinity, // Explicitly set width to full available space
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
              subtitle: Text(
                solicitud.email,
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: ElevatedButton(
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
            ),
          );
        },
      ),
    );
  }
}