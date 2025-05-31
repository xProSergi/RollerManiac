import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

    if (user == null) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(TiemposTextos.errorSesion),
          backgroundColor: TiemposColores.error,
        ),
      );
      return;
    }

    final snackBar = ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const CircularProgressIndicator(color: TiemposColores.textoPrincipal),
              const SizedBox(width: 20),
              Expanded(child: Text('${TiemposTextos.registrar} $atraccionNombre...')),
            ],
          ),
          duration: const Duration(minutes: 1),
          backgroundColor: TiemposColores.tarjeta,
        ),
      );

    try {
      await FirebaseService.registrarVisitaAtraccion(
        parque.id,
        parque.nombre,
        atraccionNombre,
      );

      snackBar
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('${TiemposTextos.visitando} $atraccionNombre'),
            backgroundColor: TiemposColores.exito,
          ),
        );
    } catch (e) {
      snackBar
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('${TiemposTextos.errorAtracciones}: ${e.toString()}'),
            backgroundColor: TiemposColores.error,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: TiemposColores.gradienteFondo,
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                title: Text(
                  parque.nombre,
                  style: TiemposEstilos.estiloTituloAppBar,
                ),
                iconTheme: const IconThemeData(color: TiemposColores.textoPrincipal),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TiemposTamanos.paddingHorizontal,
                  ),
                  child: ListView.separated(
                    itemCount: parque.atracciones.length,
                    separatorBuilder: (_, __) => const SizedBox(height: TiemposTamanos.separacionElementos),
                    itemBuilder: (context, index) {
                      final atraccion = parque.atracciones[index];
                      final bool operativa = atraccion.operativa;

                      return Card(
                        color: TiemposColores.tarjeta,
                        elevation: TiemposTamanos.elevacionTarjeta,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(TiemposTamanos.radioBordes),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(TiemposTamanos.separacionInterna),
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
                                      style: TiemposEstilos.estiloTitulo,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      operativa
                                          ? 'Espera: ${atraccion.tiempoEspera} min'
                                          : TiemposTextos.enMantenimiento,
                                      style: operativa
                                          ? TiemposEstilos.estiloEstadoOperativo
                                          : TiemposEstilos.estiloEstadoMantenimiento,
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
                                  style: TiemposEstilos.estiloBotonSecundario,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}