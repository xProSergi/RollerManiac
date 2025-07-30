import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../../tiempos/presentation/view/pantalla_principal.dart';
import '../../domain/entities/reporte_diario_entity.dart';
import '../../domain/entities/visita_atraccion_entity.dart';
import '../viewmodel/reporte_diario_viewmodel.dart';
import '../../../tiempos/constantes/tiempos_constantes.dart';

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
  final GlobalKey _screenshotKey = GlobalKey();
  bool _compartiendo = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<ReporteDiarioViewModel>();
      viewModel.cargarReportePorId(widget.reporteId);
    });
  }

  @override
  void dispose() {
    context.read<ReporteDiarioViewModel>().limpiarEstado();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TiemposColores.fondo,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => PantallaPrincipal()),
                  (route) => false,
            );
          },
        ),
        title: Consumer<ReporteDiarioViewModel>(
          builder: (context, viewModel, _) {
            final nombreParque = viewModel.reporteActual?.parqueNombre ?? 'Resumen del día';
            final idReporte = viewModel.reporteActual?.id ?? '';
            // Print para depuración
            print('Mostrando reporteId: $idReporte, parqueNombre: $nombreParque');
            return Text(
              nombreParque,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            );
          },
        ),
        centerTitle: true,
        actions: [
          Consumer<ReporteDiarioViewModel>(
            builder: (context, viewModel, _) {
              if (viewModel.reporteActual != null && viewModel.atraccionesVisitadas.isNotEmpty) {
                return IconButton(
                  onPressed: _compartiendo ? null : _compartirResumen,
                  icon: _compartiendo
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(
                    Icons.share_rounded,
                    color: Colors.white,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<ReporteDiarioViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.cargando) {
            return const Center(
              child: CircularProgressIndicator(
                color: TiemposColores.textoPrincipal,
              ),
            );
          }

          if (viewModel.tieneError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    TiemposIconos.errorIcon,
                    color: TiemposColores.error,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    viewModel.error!,
                    style: const TextStyle(
                      color: TiemposColores.textoPrincipal,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => viewModel.cargarReportePorId(widget.reporteId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TiemposColores.botonPrimario,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text(
                      'Reintentar',
                      style: TiemposEstilos.estiloBotonPrimario,
                    ),
                  ),
                ],
              ),
            );
          }

          final reporte = viewModel.reporteActual;
          if (reporte == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: TiemposColores.textoSecundario,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No se encontró el reporte',
                    style: TextStyle(
                      color: TiemposColores.textoPrincipal,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          // Print para depuración
          print('Pantalla Resumen: reporteId: ${reporte.id}, parqueNombre: ${reporte.parqueNombre}, fechaFin: ${reporte.fechaFin}');

          final atracciones = viewModel.atraccionesVisitadas;

          return Container(
            decoration: const BoxDecoration(
              gradient: TiemposColores.gradienteFondo,
            ),
            child: Column(
              children: [
                // Contenido principal
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(TiemposTamanos.paddingHorizontal),
                    child: RepaintBoundary(
                      key: _screenshotKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Marca de agua dentro de la captura
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.15),
                                    Colors.white.withOpacity(0.05),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.favorite_rounded,
                                    color: Colors.pink[300],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Made with ',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    'RollerManiac',
                                    style: TextStyle(
                                      color: Colors.blue[200],
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                      shadows: [
                                        Shadow(
                                          color: Colors.blue[400]!.withOpacity(0.3),
                                          offset: const Offset(0, 1),
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.attractions_rounded,
                                    color: Colors.blue[200],
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          _buildInfoHeader(reporte),
                          const SizedBox(height: TiemposTamanos.separacionElementos),
                          _buildAtraccionesList(atracciones),
                          const SizedBox(height: TiemposTamanos.separacionElementos),
                          if (reporte.fechaFin == null)
                            _buildFinalizarButton(context, viewModel),
                          if (reporte.fechaFin != null)
                            _buildNuevoReporteButton(context, viewModel, reporte),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Consumer<ReporteDiarioViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.reporteActual != null && viewModel.atraccionesVisitadas.isNotEmpty) {
            return FloatingActionButton.extended(
              onPressed: _compartiendo ? null : _compartirResumen,
              backgroundColor: TiemposColores.botonSecundario,
              icon: _compartiendo
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.share_rounded),
              label: Text(
                _compartiendo ? 'Compartiendo...' : 'Compartir',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildInfoHeader(ReporteDiarioEntity reporte) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: TiemposColores.tarjeta,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: TiemposColores.operativa.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      TiemposColores.operativa.withOpacity(0.2),
                      TiemposColores.botonPrimario.withOpacity(0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: TiemposColores.operativa.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  TiemposIconos.parque,
                  color: TiemposColores.operativa,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reporte.parqueNombre,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: TiemposColores.textoPrincipal,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: TiemposColores.botonSecundario.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: TiemposColores.botonSecundario.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '¡Tu aventura en el parque!',
                        style: TextStyle(
                          fontSize: 12,
                          color: TiemposColores.botonSecundario,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoRow('📅 Fecha', _formatDate(reporte.fecha)),
          if (reporte.fechaFin != null)
            _buildInfoRow('⏰ Finalizado', _formatDate(reporte.fechaFin!)),
          if (reporte.valoracionPromedio != null)
            _buildInfoRow('⭐ Valoración promedio', '${reporte.valoracionPromedio!.toStringAsFixed(1)}/5'),
          if (reporte.tiempoTotalEnParque != null)
            _buildInfoRow('⏱️ Tiempo en parque', _formatDuration(reporte.tiempoTotalEnParque!)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TiemposColores.fondo.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TiemposColores.divisor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                color: TiemposColores.textoSecundario,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                color: TiemposColores.textoPrincipal,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAtraccionesList(List<VisitaAtraccionEntity> atracciones) {
    if (atracciones.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: TiemposColores.tarjeta,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: TiemposColores.divisor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: TiemposColores.textoSecundario.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: TiemposColores.textoSecundario.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                TiemposIconos.atraccion,
                color: TiemposColores.textoSecundario,
                size: 56,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No hay atracciones registradas',
              style: TextStyle(
                color: TiemposColores.textoSecundario,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Registra tu primera atracción para ver tu progreso',
              style: TextStyle(
                color: TiemposColores.textoSecundario.withOpacity(0.7),
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TiemposColores.tarjeta,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: TiemposColores.divisor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      TiemposColores.botonSecundario.withOpacity(0.2),
                      TiemposColores.operativa.withOpacity(0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: TiemposColores.botonSecundario.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  TiemposIconos.atraccion,
                  color: TiemposColores.botonSecundario,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Atracciones visitadas',
                      style: TiemposEstilos.estiloTitulo.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: TiemposColores.textoPrincipal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${atracciones.length} atracciones registradas',
                      style: TextStyle(
                        color: TiemposColores.textoSecundario,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: atracciones.length,
          itemBuilder: (context, index) {
            final atraccion = atracciones[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: TiemposColores.tarjeta,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: TiemposColores.divisor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                TiemposColores.operativa.withOpacity(0.2),
                                TiemposColores.botonPrimario.withOpacity(0.2),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: TiemposColores.operativa.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            TiemposIconos.atraccion,
                            color: TiemposColores.operativa,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            atraccion.atraccionNombre,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: TiemposColores.textoPrincipal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          color: TiemposColores.textoSecundario,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatTime(atraccion.horaInicio),
                          style: const TextStyle(
                            color: TiemposColores.textoSecundario,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    if (atraccion.valoracion != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${atraccion.valoracion}/5',
                            style: const TextStyle(
                              color: TiemposColores.textoSecundario,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (atraccion.notas != null && atraccion.notas!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: TiemposColores.fondo.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: TiemposColores.divisor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.note_rounded,
                              color: TiemposColores.textoSecundario,
                              size: 18,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                atraccion.notas!,
                                style: const TextStyle(
                                  color: TiemposColores.textoSecundario,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFinalizarButton(BuildContext context, ReporteDiarioViewModel viewModel) {
    return Center(
      child: Container(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: TiemposColores.botonPrimario,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(TiemposTamanos.radioBordes),
            ),
            elevation: 6,
          ),
          onPressed: viewModel.cargando
              ? null
              : () async {
            final success = await viewModel.finalizarDia(
              onReportFinished: () {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Visita finalizada correctamente'),
                      backgroundColor: TiemposColores.exito,
                    ),
                  );
                }
              },
            );

            if (!success && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${viewModel.error}'),
                  backgroundColor: TiemposColores.error,
                ),
              );
            }
          },
          child: viewModel.cargando
              ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
              : const Text(
            'Finalizar Día',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNuevoReporteButton(BuildContext context, ReporteDiarioViewModel viewModel, ReporteDiarioEntity reporte) {
    return Center(
      child: Container(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: TiemposColores.botonSecundario,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(TiemposTamanos.radioBordes),
            ),
            elevation: 6,
          ),
          onPressed: viewModel.cargando
              ? null
              : () async {
            await viewModel.crearNuevoReporte(
              parqueId: reporte.parqueId,
              parqueNombre: reporte.parqueNombre,
            );

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Nuevo reporte creado'),
                  backgroundColor: TiemposColores.exito,
                ),
              );
            }
          },
          child: viewModel.cargando
              ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
              : const Text(
            'Crear Nuevo Reporte',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _compartirResumen() async {
    setState(() {
      _compartiendo = true;
    });

    try {
      // Esperar a que el widget se renderice completamente
      await Future.delayed(const Duration(milliseconds: 1500));

      // Obtener el contexto del widget que queremos capturar
      final RenderRepaintBoundary boundary = _screenshotKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      // Capturar la imagen con mayor resolución y calidad
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final Uint8List pngBytes = byteData.buffer.asUint8List();

        // Guardar la imagen temporalmente
        final directory = await getTemporaryDirectory();
        final imagePath = '${directory.path}/resumen_visita_${DateTime.now().millisecondsSinceEpoch}.png';
        final imageFile = File(imagePath);
        await imageFile.writeAsBytes(pngBytes);

        // Compartir la imagen
        final viewModel = context.read<ReporteDiarioViewModel>();
        await Share.shareXFiles(
          [XFile(imagePath)],
          text: '¡Mira mi visita a ${viewModel.reporteActual?.parqueNombre ?? "el parque"}! 🎢',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al compartir: $e'),
            backgroundColor: TiemposColores.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _compartiendo = false;
        });
      }
    }
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

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}