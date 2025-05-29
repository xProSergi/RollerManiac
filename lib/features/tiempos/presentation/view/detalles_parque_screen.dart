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
          content: Text(TiemposConstantes.errorSesion),
          backgroundColor: TiemposConstantes.error,
        ),
      );
      return;
    }

    final snackBar = ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [ // Correctly opened children list
              const CircularProgressIndicator(color: TiemposConstantes.textoPrincipal),
              const SizedBox(width: 20),
              Expanded(child: Text('${TiemposConstantes.registrar} $atraccionNombre...')),
            ], // Correctly closed children list
          ), // Correctly closed Row
          duration: const Duration(minutes: 1),
          backgroundColor: TiemposConstantes.tarjeta,
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
    content: Text('${TiemposConstantes.visitando} $atraccionNombre'),
    backgroundColor: TiemposConstantes.exito,
    ),
    );
    } catch (e) {
    snackBar
    ..hideCurrentSnackBar()
    ..showSnackBar(
    SnackBar(
    content: Text('${TiemposConstantes.errorAtracciones}: ${e.toString()}'),
    backgroundColor: TiemposConstantes.error,
    ),
    );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: TiemposConstantes.gradienteFondo,
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
                  style: TiemposConstantes.estiloTituloAppBar,
                ),
                iconTheme: const IconThemeData(color: TiemposConstantes.textoPrincipal),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TiemposConstantes.paddingHorizontal,
                  ),
                  child: ListView.separated(
                    itemCount: parque.atracciones.length,
                    separatorBuilder: (_, __) => const SizedBox(height: TiemposConstantes.separacionElementos),
                    itemBuilder: (context, index) {
                      final atraccion = parque.atracciones[index];
                      final bool operativa = atraccion.operativa;

                      return Card(
                        color: TiemposConstantes.tarjeta,
                        elevation: TiemposConstantes.elevacionTarjeta,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(TiemposConstantes.radioBordes),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(TiemposConstantes.separacionInterna),
                          child: Row(
                            children: [
                              Icon(
                                TiemposConstantes.atraccion,
                                color: operativa ? TiemposConstantes.operativa : TiemposConstantes.mantenimiento,
                                size: 28,
                              ),
                              const SizedBox(width: TiemposConstantes.separacionInterna),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      atraccion.nombre,
                                      style: TiemposConstantes.estiloTitulo,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      operativa
                                          ? 'Espera: ${atraccion.tiempoEspera} min'
                                          : TiemposConstantes.enMantenimiento,
                                      style: operativa
                                          ? TiemposConstantes.estiloEstadoOperativo
                                          : TiemposConstantes.estiloEstadoMantenimiento,
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => _registrarVisitaAtraccion(context, atraccion.nombre),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: TiemposConstantes.botonPrimario,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                child: Text(
                                  TiemposConstantes.registrar,
                                  style: TiemposConstantes.estiloBotonSecundario,
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