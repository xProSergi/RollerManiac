import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/visita_atraccion_entity.dart';
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
      _cargarVisitas();
    });
  }

  Future<void> _cargarVisitas() async {
    final viewModel = context.read<HistorialViewModel>();
    await viewModel.cargarVisitas();
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
            // Debug: Mostrar información del estado
            print('HistorialScreen - isLoading: ${viewModel.isLoading}');
            print('HistorialScreen - error: ${viewModel.error}');
            print('HistorialScreen - visitas.length: ${viewModel.visitas.length}');

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
                    Icon(
                      Icons.error_outline,
                      color: HistorialConstantes.colorAzulVivo,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      viewModel.error!,
                      style: HistorialConstantes.estiloVacio,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _cargarVisitas,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HistorialConstantes.colorAzulVivo,
                      ),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (viewModel.visitas.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      color: HistorialConstantes.colorAzulVivo,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      HistorialConstantes.noHayVisitas,
                      style: HistorialConstantes.estiloVacio,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Registra tu primera visita a un parque para ver tu historial',
                      style: TextStyle(
                        color: HistorialConstantes.colorAzulVivo.withOpacity(0.7),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            // Agrupa solo por visitas a atracciones
            final visitasPorParque = _agruparVisitasPorParque(viewModel.visitas.cast<VisitaAtraccionEntity>());

            // Ordena el mapa de mayor a menor por número de visitas al parque
            final visitasPorParqueOrdenado = Map.fromEntries(
                visitasPorParque.entries.toList()
                  ..sort((a, b) => b.value.length.compareTo(a.value.length))
            );

            return _buildHistorialContent(visitasPorParqueOrdenado);
          },
        ),
      ),
    );
  }

  Map<String, List<dynamic>> _agruparVisitasPorParque(List<VisitaAtraccionEntity> visitas) {

    final Map<String, List<VisitaAtraccionEntity>> visitasPorReporte = {};
    for (var visita in visitas) {
      final reporteId = visita.reporteDiarioId;
      if (!visitasPorReporte.containsKey(reporteId)) {
        visitasPorReporte[reporteId] = [];
      }
      visitasPorReporte[reporteId]!.add(visita);
    }

    // Luego agrupar por parque para mostrar en la UI
    final Map<String, List<dynamic>> visitasPorParque = {};
    for (var reporteVisitas in visitasPorReporte.values) {
      if (reporteVisitas.isNotEmpty) {
        final primeraVisita = reporteVisitas.first;
        final parqueNombre = primeraVisita.parqueNombre;

        if (!visitasPorParque.containsKey(parqueNombre)) {
          visitasPorParque[parqueNombre] = [];
        }


        visitasPorParque[parqueNombre]!.add({
          'parqueId': primeraVisita.parqueId,
          'parqueNombre': parqueNombre,
          'reporteId': primeraVisita.reporteDiarioId,
          'fecha': primeraVisita.fecha,
          'totalAtracciones': reporteVisitas.length,
        });
      }
    }

    return visitasPorParque;
  }

  Future<void> _onVisitasActualizadas() async {
    final viewModel = context.read<HistorialViewModel>();
    await viewModel.cargarVisitas();

    if (widget.actualizarVisitas != null) {
      widget.actualizarVisitas!();
    }
  }

  Widget _buildHistorialContent(Map<String, List<dynamic>> visitasPorParque) {
    return RefreshIndicator(
      onRefresh: _onVisitasActualizadas,
      child: Column(
        children: [
          // Header con información y botón de limpiar
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Historial de Visitas',
                        style: HistorialConstantes.estiloTitulo.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Consumer<HistorialViewModel>(
                        builder: (context, viewModel, child) {
                          return Text(
                            '${viewModel.visitas.length} atracciones visitadas en ${visitasPorParque.length} parques diferentes',
                            style: TextStyle(
                              color: HistorialConstantes.colorAzulVivo.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _mostrarDialogoLimpiarDatos(),
                  icon: const Icon(
                    Icons.cleaning_services,
                    color: HistorialConstantes.colorAzulVivo,
                  ),
                  tooltip: 'Limpiar datos antiguos',
                ),
              ],
            ),
          ),
          // Lista de parques
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              itemCount: visitasPorParque.length,
              itemBuilder: (context, index) {
                final parqueNombre = visitasPorParque.keys.elementAt(index);
                final parqueVisitas = visitasPorParque[parqueNombre]!;

                // Ordenar por fecha para obtener la más reciente
                parqueVisitas.sort((a, b) => b['fecha'].compareTo(a['fecha']));

                final parqueId = parqueVisitas.first['parqueId'];
                final ultimaVisita = parqueVisitas.first['fecha'];
                final reporteId = parqueVisitas.first['reporteId'];
                final dia = ultimaVisita.day.toString().padLeft(2, '0');
                final mes = ultimaVisita.month.toString().padLeft(2, '0');
                final anio = ultimaVisita.year.toString();
                final fechaFormateada = '$dia/$mes/$anio';

                // Contar el número de reportes (visitas al parque)
                final totalVisitasAlParque = parqueVisitas.length;


                final totalAtraccionesVisitadas = parqueVisitas.fold<int>(
                    0, (sum, visita) => sum + (visita['totalAtracciones'] as int)
                );

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
                      '$totalVisitasAlParque visitas al parque - ${HistorialConstantes.ultima}: $fechaFormateada',
                      style: HistorialConstantes.estiloSubtitulo,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: HistorialConstantes.colorAvatar,
                      child: Text(
                        totalVisitasAlParque.toString(),
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
                              reporteId: reporteId,
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
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoLimpiarDatos() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar Datos Antiguos'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar todas las visitas antiguas? '
              'Esto no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _limpiarDatosAntiguos();
            },
            child: const Text('Limpiar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _limpiarDatosAntiguos() async {
    // Por ahora solo recargar los datos
    // TODO: Implementar limpieza real de datos
    await _cargarVisitas();
  }
}