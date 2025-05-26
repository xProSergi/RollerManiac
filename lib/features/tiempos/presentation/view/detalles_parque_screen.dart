import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../domain/entities/parque.dart';
import '../../domain/entities/atraccion.dart';
import '../../../../services/firebase_service.dart';
import '../../constantes/tiempos_constantes.dart';

class DetallesParqueScreen extends StatelessWidget {
  final Parque parque;

  const DetallesParqueScreen({Key? key, required this.parque}) : super(key: key);

  Future<void> _registrarVisitaAtraccion(BuildContext context, String atraccionNombre) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || !user.emailVerified) {
      final mensaje = user == null
          ? TiemposTextos.errorSesion
          : TiemposTextos.errorVerificacion;

      scaffoldMessenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(mensaje),
            backgroundColor: TiemposColores.error,
          ),
        );
      return;
    }

    scaffoldMessenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              CircularProgressIndicator(color: TiemposColores.textoClaro),
              SizedBox(width: 20),
              Expanded(child: Text('Registrando visita...')),
            ],
          ),
          duration: Duration(minutes: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );

    try {
      await FirebaseService.registrarVisitaAtraccion(
        parque.id,
        parque.nombre,
        atraccionNombre,
      );

      scaffoldMessenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('${TiemposTextos.visitando} $atraccionNombre'),
            backgroundColor: TiemposColores.exito,
          ),
        );
    } on FirebaseException catch (e) {
      scaffoldMessenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('${TiemposTextos.errorCargar}: ${e.message ?? 'Error desconocido'}'),
            backgroundColor: TiemposColores.error,
          ),
        );
    } catch (e) {
      scaffoldMessenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('${TiemposTextos.errorCargar}: ${e.toString()}'),
            backgroundColor: TiemposColores.error,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TiemposColores.fondoOscuro,
      appBar: AppBar(
        backgroundColor: TiemposColores.tarjetaOscura,
        elevation: 0,
        centerTitle: true,
        title: Text(
          parque.nombre,
          style: TiemposEstilos.tituloAppBarOscuro,
        ),
        iconTheme: const IconThemeData(color: TiemposColores.textoClaro),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TiemposTamanos.paddingHorizontal,
          vertical: TiemposTamanos.paddingVertical,
        ),
        child: ListView.separated(
          itemCount: parque.atracciones.length,
          separatorBuilder: (_, __) => const SizedBox(height: TiemposTamanos.separacionElementos),
          itemBuilder: (context, index) {
            final Atraccion atraccion = parque.atracciones[index];
            final bool operativa = atraccion.operativa;

            return Container(
              decoration: BoxDecoration(
                color: TiemposColores.tarjetaOscura,
                borderRadius: BorderRadius.circular(TiemposTamanos.radioBordes),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: TiemposTamanos.paddingHorizontal,
                vertical: TiemposTamanos.separacionInterna,
              ),
              child: Row(
                children: [
                  Icon(
                    TiemposIconos.atraccion,
                    color: operativa ? TiemposColores.operativa : TiemposColores.mantenimiento,
                    size: 28,
                  ),
                  const SizedBox(width: TiemposTamanos.separacionInterna),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          atraccion.nombre,
                          style: TiemposEstilos.tituloParqueOscuro,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          operativa
                              ? 'Espera: ${atraccion.tiempoEspera} min'
                              : TiemposTextos.enMantenimiento,
                          style: operativa
                              ? TiemposEstilos.estadoOperativo
                              : TiemposEstilos.estadoMantenimiento,
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _registrarVisitaAtraccion(context, atraccion.nombre),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TiemposColores.botonPrimario,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child: Text(
                      TiemposTextos.registrar,
                      style: TiemposEstilos.botonSecundario,
                    ),
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