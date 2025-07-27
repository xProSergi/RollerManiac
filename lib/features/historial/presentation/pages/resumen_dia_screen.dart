import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/reporte_diario_entity.dart';
import '../../domain/entities/visita_atraccion_entity.dart';
import '../viewmodel/reporte_diario_viewmodel.dart';

class ResumenDiaScreen extends StatefulWidget {
  final String reporteId;

  const ResumenDiaScreen({
    Key? key,
    required this.reporteId,
  }) : super(key: key);

  @override
  State<ResumenDiaScreen> createState() => _ResumenDiaScreenState();
}

class _ResumenDiaScreenState extends State<ResumenDiaScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar el reporte y suscribirse a actualizaciones
    final viewModel = context.read<ReporteDiarioViewModel>();
    // Call cargarReportePorId. It will now handle subscribing to both
    // the main report and the attractions stream internally.
    viewModel.cargarReportePorId(widget.reporteId);
    // The line below is now redundant and can be removed
    // viewModel.suscribirActualizaciones(widget.reporteId);
  }

  @override
  void dispose() {
    // Limpiar estado y cancelar suscripciones al salir
    context.read<ReporteDiarioViewModel>().limpiarEstado();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<ReporteDiarioViewModel>(
          builder: (context, viewModel, _) =>
              Text(viewModel.reporteActual?.parqueNombre ?? 'Resumen del día'),
        ),
      ),
      body: Consumer<ReporteDiarioViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.cargando) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.tieneError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(viewModel.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.cargarReportePorId(widget.reporteId),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final reporte = viewModel.reporteActual;
          if (reporte == null) {
            return const Center(child: Text('No se encontró el reporte'));
          }

          // **CHANGED:** Get the attractions directly from the ViewModel's state.
          // The ViewModel is now responsible for keeping this list updated via its own stream.
          final atracciones = viewModel.atraccionesVisitadas;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoHeader(reporte),
                const SizedBox(height: 20),
                // **CHANGED:** No more StreamBuilder here for attractions.
                // The Consumer above this point already rebuilds when viewModel.atraccionesVisitadas changes.
                _buildAtraccionesList(atracciones),
                const SizedBox(height: 20),
                // Only show the "Finalizar Visita" button if the report is active
                if (reporte.fechaFin == null)
                  _buildFinalizarButton(context, viewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  // **REMOVED:** This method is no longer needed as the ViewModel now manages the stream.
  // Stream<List<VisitaAtraccionEntity>> _getAtraccionesStream(ReporteDiarioViewModel viewModel) {
  //   return viewModel.reporteActual?.atraccionesVisitadas != null
  //       ? Stream.value(viewModel.reporteActual!.atraccionesVisitadas)
  //       : const Stream.empty();
  // }

  Widget _buildInfoHeader(ReporteDiarioEntity reporte) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          reporte.parqueNombre,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text('Fecha: ${_formatDate(reporte.fecha)}'),
        if (reporte.fechaFin != null)
          Text('Finalizado: ${_formatDate(reporte.fechaFin!)}'),
        if (reporte.valoracionPromedio != null)
          Text('Valoración promedio: ${reporte.valoracionPromedio!.toStringAsFixed(1)}/5'),
        if (reporte.tiempoTotalEnParque != null)
          Text('Tiempo en parque: ${_formatDuration(reporte.tiempoTotalEnParque!)}'),
      ],
    );
  }

  Widget _buildAtraccionesList(List<VisitaAtraccionEntity> atracciones) {
    if (atracciones.isEmpty) {
      return const Center(child: Text('No hay atracciones registradas'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: atracciones.length,
      itemBuilder: (context, index) {
        final atraccion = atracciones[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  atraccion.atraccionNombre,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Hora inicio: ${_formatTime(atraccion.horaInicio)}'),
                if (atraccion.horaFin != null)
                  Text('Hora fin: ${_formatTime(atraccion.horaFin!)}'),
                if (atraccion.duracion != null)
                  Text('Duración: ${_formatDuration(atraccion.duracion!)}'),
                if (atraccion.valoracion != null)
                  Text('Valoración: ${atraccion.valoracion}/5'),
                if (atraccion.notas != null && atraccion.notas!.isNotEmpty)
                  Text('Notas: ${atraccion.notas}'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFinalizarButton(BuildContext context, ReporteDiarioViewModel viewModel) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
        onPressed: viewModel.cargando
            ? null
            : () async {
          final success = await viewModel.finalizarDia(
            onReportFinished: () {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Visita finalizada correctamente')),
                );
                // Consider navigating *back* to a previous screen,
                // or to a dedicated "Reporte Finalizado" screen.
                // Navigator.pop(context);
              }
            },
          );

          if (!success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${viewModel.error}')),
            );
          }
        },
        child: viewModel.cargando
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Finalizar Día', style: TextStyle(fontSize: 18)), // Changed text for clarity
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  String _formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}