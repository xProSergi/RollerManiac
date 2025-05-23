import 'package:flutter/material.dart';

import '../../domain/entities/solicitud_amistad.dart';

class SocialWidgets {
  static Widget solicitudesList(List<SolicitudAmistad> solicitudes, Function(SolicitudAmistad) onAceptar) {
    if (solicitudes.isEmpty) {
      return const Text('No hay solicitudes pendientes.');
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: solicitudes.length,
      itemBuilder: (context, index) {
        final solicitud = solicitudes[index];
        return Card(
          child: ListTile(
            title: Text(solicitud.displayName),
            subtitle: Text(solicitud.email),
            trailing: ElevatedButton(
              child: const Text('Aceptar'),
              onPressed: () => onAceptar(solicitud),
            ),
          ),
        );
      },
    );
  }
}
