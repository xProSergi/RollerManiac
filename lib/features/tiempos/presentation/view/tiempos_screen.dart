import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/parque.dart';
import '../../domain/entities/atraccion.dart';
import '../viewmodel/tiempos_viewmodel.dart';
import 'detalles_parque_screen.dart';

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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Parques Temáticos',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue[800],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Consumer<TiemposViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.blue[800]),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Cargando parques...',
                    style: TextStyle(
                      color: Colors.blueGrey[700],
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
                  Icon(Icons.park, size: 60, color: Colors.blueGrey[300]),
                  SizedBox(height: 20),
                  Text(
                    'No se encontraron parques',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.blueGrey[800],
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
              padding: EdgeInsets.all(16),
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
            Icon(Icons.wb_sunny, size: 18, color: Colors.amber[600]),
            SizedBox(width: 4),
            Text(
              '24°C',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey[800],
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          'Soleado',
          style: TextStyle(
            fontSize: 12,
            color: Colors.blueGrey[600],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.park,
                    size: 40,
                    color: Colors.blue[800],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              parque.nombre,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.blueGrey[900],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 12),
                          _buildWeatherInfo(),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.blueGrey[500],
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Madrid, España',
                            style: TextStyle(
                              color: Colors.blueGrey[700],
                              fontSize: 14,
                            ),
                          ),
                          Spacer(),
                          Text(
                            '${parque.atracciones.length} atracciones',
                            style: TextStyle(
                              color: Colors.blue[800],
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
