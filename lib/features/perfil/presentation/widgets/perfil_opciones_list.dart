import 'package:flutter/material.dart';
import '../../constantes/perfil_constantes.dart';

class PerfilOpcionesList extends StatelessWidget {
  const PerfilOpcionesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(PerfilConstantes.iconoEditar),
          title: const Text(PerfilConstantes.editarPerfil),
          trailing: const Icon(PerfilConstantes.iconoArrow, size: 16),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(PerfilConstantes.funcionNoImplementada)),
            );
          },
        ),
        const Divider(height: 0),
        ListTile(
          leading: const Icon(PerfilConstantes.iconoCambiarContrasena),
          title: const Text(PerfilConstantes.cambiarContrasena),
          trailing: const Icon(PerfilConstantes.iconoArrow, size: 16),
          onTap: () {},
        ),
        const Divider(height: 0),
        ListTile(
          leading: const Icon(PerfilConstantes.iconoNotificaciones),
          title: const Text(PerfilConstantes.notificaciones),
          trailing: const Icon(PerfilConstantes.iconoArrow, size: 16),
          onTap: () {},
        ),
        const Divider(height: 0),
        ListTile(
          leading: const Icon(PerfilConstantes.iconoPolitica),
          title: const Text(PerfilConstantes.politicaPrivacidad),
          trailing: const Icon(PerfilConstantes.iconoArrow, size: 16),
          onTap: () {},
        ),
        const Divider(height: 0),
        ListTile(
          leading: const Icon(PerfilConstantes.iconoTerminos),
          title: const Text(PerfilConstantes.terminosCondiciones),
          trailing: const Icon(PerfilConstantes.iconoArrow, size: 16),
          onTap: () {},
        ),
      ],
    );
  }
}
