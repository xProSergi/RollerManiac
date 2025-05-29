import 'package:flutter/material.dart';
import '../../constantes/perfil_constantes.dart';

class PerfilInfoCard extends StatelessWidget {
  final String username;
  final String email;
  final String creationDate;

  const PerfilInfoCard({
    super.key,
    required this.username,
    required this.email,
    required this.creationDate,
  });

  @override
  Widget build(BuildContext context) {
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
              username.isNotEmpty ? username : PerfilConstantes.usuarioDefault,
              style: PerfilConstantes.estiloUsername,
            ),
            const SizedBox(height: 8),
            Text(email, style: PerfilConstantes.estiloEmail),
            const SizedBox(height: 8),
            Text('${PerfilConstantes.miembroDesde} $creationDate',
                style: PerfilConstantes.estiloFecha),
          ],
        ),
      ),
    );
  }
}
