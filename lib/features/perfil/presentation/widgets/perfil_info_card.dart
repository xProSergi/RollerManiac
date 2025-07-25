import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constantes/perfil_constantes.dart';

class PerfilInfoCard extends StatelessWidget {
  final String displayName; // Cambiado aquí
  final String email;
  final DateTime? creationDate;

  const PerfilInfoCard({
    super.key,
    required this.displayName, // Cambiado aquí
    required this.email,
    required this.creationDate,
  });

  @override
  Widget build(BuildContext context) {
    final String fechaFormateada = creationDate != null
        ? DateFormat('dd/MM/yyyy').format(creationDate!)
        : PerfilConstantes.fechaNoDisponible;

    return Card(
      color: PerfilConstantes.colorTarjeta,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              displayName.isNotEmpty ? displayName : PerfilConstantes.usuarioDefault, // Cambiado aquí
              style: PerfilConstantes.estiloUsername,
            ),
            const SizedBox(height: 8),
            Text(email, style: PerfilConstantes.estiloEmail),
            const SizedBox(height: 8),
            Text(
              '${PerfilConstantes.miembroDesde} $fechaFormateada',
              style: PerfilConstantes.estiloFecha,
            ),
          ],
        ),
      ),
    );
  }
}