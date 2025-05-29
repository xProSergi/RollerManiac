import 'package:flutter/material.dart';
import '../../domain/entities/solicitud_amistad.dart';
import '../../constantes/social_constantes.dart';

class SocialWidgets {
  static Widget solicitudesList(List<SolicitudAmistad> solicitudes, Function(SolicitudAmistad) onAceptar) {
    if (solicitudes.isEmpty) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: SocialColores.tarjeta,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Text(
          SocialTextos.sinSolicitudes,
          style: SocialTextStyles.emailUsuario,
          textAlign: TextAlign.center,
        ),
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