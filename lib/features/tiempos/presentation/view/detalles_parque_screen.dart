import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/parque.dart';
import '../../domain/entities/atraccion.dart';
import '../../../../services/firebase_service.dart';
import '../../constantes/tiempos_constantes.dart';
import 'package:provider/provider.dart';
import '../../../historial/presentation/viewmodel/reporte_diario_viewmodel.dart';

class DetallesParqueScreen extends StatefulWidget {
  final Parque parque;

  const DetallesParqueScreen({Key? key, required this.parque}) : super(key: key);

  @override
  State<DetallesParqueScreen> createState() => _DetallesParqueScreenState();
}

class _DetallesParqueScreenState extends State<DetallesParqueScreen> {
  String _ordenActual = 'Alfabético';

  List<Atraccion> get _atraccionesOrdenadas {
    final atracciones = List<Atraccion>.from(widget.parque.atracciones ?? []);
    switch (_ordenActual) {
      case 'Tiempo ↑':
        atracciones.sort((a, b) => (a.tiempoEspera ?? 9999).compareTo(b.tiempoEspera ?? 9999));
        break;
      case 'Tiempo ↓':
        atracciones.sort((a, b) => (b.tiempoEspera ?? -1).compareTo(a.tiempoEspera ?? -1));
        break;
      case 'Alfabético':
      default:
        atracciones.sort((a, b) => a.nombre.compareTo(b.nombre));
    }
    return atracciones;
  }

  Future<void> _registrarVisitaAtraccion(BuildContext context, String atraccionNombre, String atraccionId) async {
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

    scaffoldMessenger.hideCurrentSnackBar();
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const CircularProgressIndicator(color: TiemposColores.textoPrincipal),
            const SizedBox(width: 20),
            Expanded(child: Text('${TiemposTextos.registrar} $atraccionNombre...')),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: TiemposColores.tarjeta,
      ),
    );

    try {
      await context.read<ReporteDiarioViewModel>().agregarVisitaAtraccion(
        parqueId: widget.parque.id,
        parqueNombre: widget.parque.nombre,
        atraccionId: atraccionId,
        atraccionNombre: atraccionNombre,
      );

      if (!context.mounted) return;

      scaffoldMessenger.hideCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('${TiemposTextos.visitando} $atraccionNombre'),
          backgroundColor: TiemposColores.exito,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      scaffoldMessenger.hideCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('${TiemposTextos.errorAtracciones}: ${e.toString()}'),
          backgroundColor: TiemposColores.error,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.parque.nombre,
          style: TiemposEstilos.estiloTituloAppBar,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: TiemposColores.gradienteFondo,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Botones de orden justo debajo del AppBar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: TiemposColores.tarjeta.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSortButton('Alfabético', Icons.sort_by_alpha),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSortButton('Tiempo ↑', Icons.arrow_upward),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSortButton('Tiempo ↓', Icons.arrow_downward),
                    ),
                  ],
                ),
              ),
              // LISTA DE ATRACCIONES
              Expanded(
                child: _atraccionesOrdenadas.isEmpty
                    ? Center(
                  child: Text(
                    'No hay atracciones para mostrar.',
                    style: TextStyle(color: TiemposColores.textoSecundario),
                  ),
                )
                    : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: _atraccionesOrdenadas.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final atraccion = _atraccionesOrdenadas[index];
                    return Card(
                      color: TiemposColores.tarjeta,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.attractions, color: TiemposColores.botonPrimario),
                        title: Text(
                          atraccion.nombre,
                          style: TiemposEstilos.estiloTitulo.copyWith(fontSize: 18),
                        ),
                        subtitle: atraccion.tiempoEspera != null
                            ? Text(
                          'Espera: ${atraccion.tiempoEspera} min',
                          style: TiemposEstilos.estiloSubtitulo,
                        )
                            : Text(
                          'Sin datos de espera',
                          style: TiemposEstilos.estiloSubtitulo,
                        ),
                        trailing: ElevatedButton(
                          onPressed: () => _registrarVisitaAtraccion(context, atraccion.nombre, atraccion.nombre),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TiemposColores.botonPrimario,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          ),
                          child: Text(
                            'Visitar',
                            style: TiemposEstilos.estiloBotonPrimario.copyWith(fontSize: 12),
                          ),
                        ),
                      ),
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

  Widget _buildSortButton(String label, IconData icon) {
    final isSelected = _ordenActual == label;
    return ElevatedButton(
      onPressed: () => setState(() => _ordenActual = label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? TiemposColores.botonPrimario
            : Colors.white.withOpacity(0.18),
        foregroundColor: isSelected
            ? Colors.white
            : TiemposColores.textoSecundario,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        elevation: isSelected ? 4 : 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}