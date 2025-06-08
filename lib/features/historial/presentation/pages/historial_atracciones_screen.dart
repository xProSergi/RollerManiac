import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/historial_view_model.dart';
import '../../constantes/historial_constantes.dart';

class HistorialAtraccionesScreen extends StatefulWidget {
  final String parqueId;
  final String parqueNombre;

  const HistorialAtraccionesScreen({
    Key? key,
    required this.parqueId,
    required this.parqueNombre,
  }) : super(key: key);

  @override
  State<HistorialAtraccionesScreen> createState() => _HistorialAtraccionesScreenState();
}

class _HistorialAtraccionesScreenState extends State<HistorialAtraccionesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistorialViewModel>().cargarVisitasPorParque(widget.parqueId);
    });
  }

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
                  widget.parqueNombre,
                  style: HistorialConstantes.estiloTituloAppBar,
                ),
                iconTheme: const IconThemeData(color: Colors.white),
              ),
              Expanded(
                child: Consumer<HistorialViewModel>(
                  builder: (context, viewModel, child) {
                    if (viewModel.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: HistorialConstantes.colorAccento,
                        ),
                      );
                    }

                    if (viewModel.error != null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              viewModel.error!,
                              style: HistorialConstantes.estiloVacio,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => viewModel.cargarVisitasPorParque(widget.parqueId),
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (viewModel.conteoAtracciones.isEmpty) {
                      return const Center(
                        child: Text(
                          'No has registrado visitas a atracciones en este parque',
                          style: HistorialConstantes.estiloVacio,
                        ),
                      );
                    }

                    final atraccionesList = viewModel.conteoAtracciones.entries.toList()
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