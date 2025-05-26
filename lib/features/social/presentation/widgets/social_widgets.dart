import 'package:flutter/material.dart';
import '../../domain/entities/solicitud_amistad.dart';
import '../../constantes/social_constantes.dart';

class SocialWidgets {
  static Widget solicitudesList(List<SolicitudAmistad> solicitudes, Function(SolicitudAmistad) onAceptar) {
    if (solicitudes.isEmpty) {
      return Text(
        SocialTextos.sinSolicitudes,
        style: SocialTextStyles.emailUsuario,
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: solicitudes.length,
      itemBuilder: (context, index) {
        final solicitud = solicitudes[index];
        return Card(
          color: SocialColores.tarjeta,
          child: ListTile(
            title: Text(solicitud.displayName, style: SocialTextStyles.nombreUsuario),
            subtitle: Text(solicitud.email, style: SocialTextStyles.emailUsuario),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: SocialColores.boton,
              ),
              child: Text('Aceptar', style: SocialTextStyles.textoBoton),
              onPressed: () => onAceptar(solicitud),
            ),
          ),
        );
      },
    );
  }
}