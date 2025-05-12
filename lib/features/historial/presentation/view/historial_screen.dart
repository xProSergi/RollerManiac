import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../services/firebase_service.dart';

class HistorialScreen extends StatefulWidget {
  final Function() actualizarVisitas;
  final Function()? cargarVisitasCallback;

  const HistorialScreen({
    Key? key,
    required this.actualizarVisitas,
    this.cargarVisitasCallback,
  }) : super(key: key);

  @override
  _HistorialScreenState createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  late FirebaseAuth _auth;
  List<Map<String, dynamic>> visitas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    _cargarVisitas();
  }

  Future<void> _cargarVisitas() async {
    setState(() => isLoading = true);
    try {
      final visitasData = await FirebaseService.obtenerVisitas();

      // Ordenar visitas por fecha (más reciente primero)
      visitasData.sort((a, b) {
        final fechaA = a['fecha'] as Timestamp;
        final fechaB = b['fecha'] as Timestamp;
        return fechaB.compareTo(fechaA);
      });

      setState(() {
        visitas = visitasData;
        isLoading = false;
      });

      // Notificar al padre que los datos se actualizaron
      widget.actualizarVisitas();
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error cargando visitas: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Historial de Visitas',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 1.1,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _cargarVisitas();
              widget.cargarVisitasCallback?.call();
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Actualizar visitas',
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
          : visitas.isEmpty
          ? const Center(
        child: Text(
          'No hay visitas registradas',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      )
          : _buildHistorialContent(),
    );
  }

  Widget _buildHistorialContent() {
    // Contar visitas por parque
    final Map<String, int> visitasPorParque = {};
    final Map<String, Timestamp> ultimasVisitas = {};

    for (var visita in visitas) {
      final nombre = visita['parqueNombre'] as String;
      final fecha = visita['fecha'] as Timestamp;

      visitasPorParque[nombre] = (visitasPorParque[nombre] ?? 0) + 1;

      // Guardar solo la fecha más reciente
      if (!ultimasVisitas.containsKey(nombre)) {
        ultimasVisitas[nombre] = fecha;
      }
    }

    // Ordenar parques por número de visitas (de mayor a menor)
    final nombresOrdenados = visitasPorParque.keys.toList()
      ..sort((a, b) => visitasPorParque[b]!.compareTo(visitasPorParque[a]!));

    return Column(
      children: [
        Expanded(
          flex: 3,
          child: ListView.builder(
            itemCount: nombresOrdenados.length,
            itemBuilder: (context, index) {
              final nombre = nombresOrdenados[index];
              final totalVisitas = visitasPorParque[nombre]!;
              final ultimaVisita = ultimasVisitas[nombre]!.toDate();
              final fechaFormateada = '${ultimaVisita.day}/${ultimaVisita.month}/${ultimaVisita.year}';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: const Color(0xFF1E293B),
                child: ListTile(
                  title: Text(
                    nombre,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  subtitle: Text(
                    'Última visita: $fechaFormateada',
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF38BDF8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      totalVisitas.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (visitasPorParque.values.reduce((a, b) => a > b ? a : b)).toDouble() + 1,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final nombre = nombresOrdenados[group.x.toInt()];
                      return BarTooltipItem(
                        '$nombre\n${rod.toY.toInt()} visitas',
                        const TextStyle(color: Colors.white),
                      );
                    },
                  ),

                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 80,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= nombresOrdenados.length) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Transform.rotate(
                            angle: -0.5,
                            child: Text(
                              nombresOrdenados[index],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withOpacity(0.3),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(nombresOrdenados.length, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: visitasPorParque[nombresOrdenados[index]]!.toDouble(),
                        width: 22,
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.cyanAccent,
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: (visitasPorParque.values.reduce((a, b) => a > b ? a : b)).toDouble() + 1,
                          color: Colors.grey.withOpacity(0.2),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
