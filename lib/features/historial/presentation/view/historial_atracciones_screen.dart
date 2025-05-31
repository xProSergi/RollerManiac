import 'package:flutter/material.dart';
import '../../../../services/firebase_service.dart';
import '../../constantes/historial_constantes.dart';

class HistorialAtraccionesScreen extends StatelessWidget {
  final String parqueId;
  final String parqueNombre;

  const HistorialAtraccionesScreen({
    Key? key,
    required this.parqueId,
    required this.parqueNombre,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HistorialConstantes.colorFondo,
      body: Container(
        decoration: const BoxDecoration(
          gradient: HistorialConstantes.gradienteFondo,
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                title: Text(
                  parqueNombre,
                  style: HistorialConstantes.estiloTituloAppBar,
                ),
                iconTheme: const IconThemeData(color: Colors.white),
              ),
              Expanded(
                child: FutureBuilder<Map<String, int>>(
                  future: FirebaseService.obtenerConteoVisitasAtracciones(parqueId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: HistorialConstantes.colorAccento,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          '${HistorialConstantes.errorCargandoVisitas} ${snapshot.error}',
                          style: const TextStyle(color: HistorialConstantes.colorError),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'No has registrado visitas a atracciones en este parque',
                          style: HistorialConstantes.estiloVacio,
                        ),
                      );
                    }

                    final atracciones = snapshot.data!;
                    final atraccionesList = atracciones.entries.toList()
                      ..sort((a, b) => b.value.compareTo(a.value));

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: atraccionesList.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final entry = atraccionesList[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: HistorialConstantes.colorSuperficie,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [HistorialConstantes.sombraTile],
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            leading: const Icon(
                              Icons.attractions,
                              color: HistorialConstantes.colorAccento,
                              size: 28,
                            ),
                            title: Text(
                              entry.key,
                              style: HistorialConstantes.estiloTitulo,
                            ),
                            subtitle: Text(
                              '${entry.value} ${entry.value == 1 ? 'vez' : 'veces'}',
                              style: HistorialConstantes.estiloSubtitulo,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
