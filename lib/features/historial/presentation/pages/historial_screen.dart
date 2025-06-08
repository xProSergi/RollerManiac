import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/visita_entity.dart';
import '../viewmodel/historial_view_model.dart';
import 'historial_atracciones_screen.dart';
import '../../constantes/historial_constantes.dart';


class HistorialScreen extends StatefulWidget {
  final VoidCallback? actualizarVisitas;

  const HistorialScreen({
    Key? key,
    this.actualizarVisitas,
  }) : super(key: key);

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistorialViewModel>().cargarVisitas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: HistorialConstantes.colorFondo,
      body: Container(
        decoration: const BoxDecoration(
          gradient: HistorialConstantes.gradienteFondo,
        ),
        child: Consumer<HistorialViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: HistorialConstantes.colorAzulVivo,
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
                      onPressed: () => viewModel.cargarVisitas(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (viewModel.visitas.isEmpty) {
              return const Center(
                child: Text(
                  HistorialConstantes.noHayVisitas,
                  style: HistorialConstantes.estiloVacio,
                ),
              );
            }

            final visitasPorParque = _agruparVisitasPorParque(viewModel.visitas);
            return _buildHistorialContent(visitasPorParque);
          },
        ),
      ),
    );
  }

  Map<String, List<dynamic>> _agruparVisitasPorParque(List<VisitaEntity> visitas) {
    final Map<String, List<dynamic>> visitasPorParque = {};
    for (var visita in visitas) {
      final nombre = visita.parqueNombre;
      if (!visitasPorParque.containsKey(nombre)) {
        visitasPorParque[nombre] = [];
      }
      visitasPorParque[nombre]!.add(visita);
    }
    return visitasPorParque;
  }

  Future<void> _onVisitasActualizadas() async {
    await context.read<HistorialViewModel>().cargarVisitas();
    if (widget.actualizarVisitas != null) {
      widget.actualizarVisitas!();
    }
  }

  Widget _buildHistorialContent(Map<String, List<dynamic>> visitasPorParque) {
    return RefreshIndicator(
      onRefresh: _onVisitasActualizadas,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
        itemCount: visitasPorParque.length,
        itemBuilder: (context, index) {
          final parqueNombre = visitasPorParque.keys.elementAt(index);
          final parqueVisitas = visitasPorParque[parqueNombre]!;
          final parqueId = parqueVisitas.first.parqueId;
          final ultimaVisita = parqueVisitas.first.fecha;

          final dia = ultimaVisita.day.toString().padLeft(2, '0');
          final mes = ultimaVisita.month.toString().padLeft(2, '0');
          final anio = ultimaVisita.year.toString();
          final fechaFormateada = '$dia/$mes/$anio';

          final totalVisitas = parqueVisitas.length;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: HistorialConstantes.colorSuperficie,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [HistorialConstantes.sombraTile],
            ),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text(
                parqueNombre,
                style: HistorialConstantes.estiloTitulo,
              ),
              subtitle: Text(
                '${HistorialConstantes.visitas}: $totalVisitas - ${HistorialConstantes.ultima}: $fechaFormateada',
                style: HistorialConstantes.estiloSubtitulo,
              ),
              leading: CircleAvatar(
                backgroundColor: HistorialConstantes.colorAvatar,
                child: Text(
                  totalVisitas.toString(),
                  style: const TextStyle(
                    color: HistorialConstantes.colorTexto,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: HistorialConstantes.colorAzulVivo,
                size: 20,
              ),
              onTap: () async {
                final historialViewModel = context.read<HistorialViewModel>();
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                      value: historialViewModel,
                      child: HistorialAtraccionesScreen(
                        parqueId: parqueId,
                        parqueNombre: parqueNombre,
                      ),
                    ),
                  ),
                );
                if (mounted) {
                  await historialViewModel.cargarVisitas();
                }
              },
            ),
          );
        },
      ),
    );
  }
}