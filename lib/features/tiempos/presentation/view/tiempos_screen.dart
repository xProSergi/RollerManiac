import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/parque.dart';
import '../../domain/entities/atraccion.dart';
import '../viewmodel/tiempos_viewmodel.dart';
import 'detalles_parque_screen.dart';
import '../../constantes/tiempos_constantes.dart';

class TiemposScreen extends StatefulWidget {
  @override
  _TiemposScreenState createState() => _TiemposScreenState();
}

class _TiemposScreenState extends State<TiemposScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TiemposViewModel>(context, listen: false).cargarParques();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TiemposColores.fondoClaro,
      appBar: AppBar(
        title: Text(
          TiemposTextos.tituloParques,
          style: TiemposEstilos.tituloAppBarClaro,
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: TiemposColores.botonPrimario,
        iconTheme: const IconThemeData(color: TiemposColores.textoClaro),
      ),
      body: Consumer<TiemposViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(TiemposColores.botonPrimario),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    TiemposTextos.cargando,
                    style: TextStyle(
                      color: TiemposColores.textoSecundarioOscuro,
                    ),
                  ),
                ],
              ),
            );
          }

          if (viewModel.parques.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    TiemposIconos.parque,
                    size: 60,
                    color: TiemposColores.textoSecundarioOscuro,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    TiemposTextos.sinParques,
                    style: TextStyle(
                      fontSize: 18,
                      color: TiemposColores.textoOscuro,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.cargarParques(),
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(TiemposTamanos.paddingHorizontal),
              itemCount: viewModel.parques.length,
              itemBuilder: (context, index) {
                final parque = viewModel.parques[index];
                return _ParkCard(
                  parque: parque,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetallesParqueScreen(
                          parque: parque,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ParkCard extends StatelessWidget {
  final Parque parque;
  final VoidCallback onTap;

  const _ParkCard({
    required this.parque,
    required this.onTap,
  });

  Widget _buildWeatherInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              TiemposIconos.clima,
              size: 18,
              color: Colors.amber[600],
            ),
            const SizedBox(width: 4),
            Text(
              '24°C',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: TiemposColores.textoOscuro,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Soleado',
          style: TextStyle(
            fontSize: 12,
            color: TiemposColores.textoSecundarioOscuro,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: TiemposTamanos.elevacionTarjeta,
      margin: EdgeInsets.only(bottom: TiemposTamanos.separacionElementos),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TiemposTamanos.radioBordes),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(TiemposTamanos.radioBordes),
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 100,
                decoration: BoxDecoration(
                  color: TiemposColores.fondoClaro,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(TiemposTamanos.radioBordes),
                    bottomLeft: Radius.circular(TiemposTamanos.radioBordes),
                  ),
                ),
                child: Center(
                  child: Icon(
                    TiemposIconos.parque,
                    size: 40,
                    color: TiemposColores.botonPrimario,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(TiemposTamanos.paddingHorizontal),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              parque.nombre,
                              style: TiemposEstilos.tituloParqueClaro,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildWeatherInfo(),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            TiemposIconos.ubicacion,
                            size: 16,
                            color: TiemposColores.textoSecundarioOscuro,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Madrid, España',
                            style: TextStyle(
                              color: TiemposColores.textoSecundarioOscuro,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${parque.atracciones.length} ${TiemposTextos.registrarVisita.toLowerCase()}',
                            style: TextStyle(
                              color: TiemposColores.botonPrimario,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
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