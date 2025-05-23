import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../services/firebase_service.dart';
import 'historial_atracciones_screen.dart';

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
    final Map<String, List<Map<String, dynamic>>> visitasPorParque = {};

    for (var visita in visitas) {
      final nombre = visita['parqueNombre'] as String;
      if (!visitasPorParque.containsKey(nombre)) {
        visitasPorParque[nombre] = [];
      }
      visitasPorParque[nombre]!.add(visita);
    }

    return ListView.builder(
      itemCount: visitasPorParque.length,
      itemBuilder: (context, index) {
        final parqueNombre = visitasPorParque.keys.elementAt(index);
        final parqueVisitas = visitasPorParque[parqueNombre]!;
        final parqueId = parqueVisitas.first['parqueId'].toString();
        final totalVisitas = parqueVisitas.length;
        final ultimaVisita = parqueVisitas.first['fecha'];
        final fechaFormateada =
            '${ultimaVisita.toDate().day}/${ultimaVisita.toDate().month}/${ultimaVisita.toDate().year}';

        return ListTile(
          title: Text(
            parqueNombre,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          subtitle: Text(
            'Visitas: $totalVisitas - Última: $fechaFormateada',
            style: TextStyle(color: Colors.white70),
          ),
          leading: CircleAvatar(
            backgroundColor: Colors.cyan,
            child: Text(
              totalVisitas.toString(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HistorialAtraccionesScreen(
                  parqueId: parqueId,
                  parqueNombre: parqueNombre,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
