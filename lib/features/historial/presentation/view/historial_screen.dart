import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
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
      setState(() {
        visitas = visitasData;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando visitas: $e')),
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
              widget.actualizarVisitas();
              _cargarVisitas();
              widget.cargarVisitasCallback?.call();
            },
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : visitas.isEmpty
          ? const Center(
        child: Text(
          'No hay visitas registradas',
          style: TextStyle(color: Colors.white),
        ),
      )
          : _buildHistorialContent(),
    );
  }

  Widget _buildHistorialContent() {

    final Map<String, int> visitasPorParque = {};
    for (var visita in visitas) {
      final nombre = visita['parqueNombre'] as String;
      visitasPorParque[nombre] = (visitasPorParque[nombre] ?? 0) + 1;
    }

    final nombresUnicos = visitasPorParque.keys.toList();
    final conteos = visitasPorParque.values.toList();

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: nombresUnicos.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                  nombresUnicos[index],
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: Text(
                  conteos[index].toString(),
                  style: const TextStyle(color: Colors.white),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (conteos.reduce((a, b) => a > b ? a : b)).toDouble() + 1,
                barTouchData: BarTouchData(enabled: true),
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
                        if (index < 0 || index >= nombresUnicos.length) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Transform.rotate(
                            angle: -0.5,
                            child: Text(
                              nombresUnicos[index],
                              style: const TextStyle(color: Colors.white, fontSize: 10),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(nombresUnicos.length, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: conteos[index].toDouble(),
                        width: 22,
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.cyanAccent,
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
