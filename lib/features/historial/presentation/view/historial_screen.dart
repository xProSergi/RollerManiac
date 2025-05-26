import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../services/firebase_service.dart';
import 'historial_atracciones_screen.dart';
import '../../constantes/historial_constantes.dart';

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
          content: Text('${HistorialConstantes.errorCargandoVisitas} $e'),
          backgroundColor: HistorialConstantes.colorError,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HistorialConstantes.colorFondo,
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: HistorialConstantes.colorAccento,
        ),
      )
          : visitas.isEmpty
          ? const Center(
        child: Text(
          HistorialConstantes.noHayVisitas,
          style: HistorialConstantes.estiloVacio,
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
        final fechaFormateada = '${ultimaVisita.toDate().day}/${ultimaVisita.toDate().month}/${ultimaVisita.toDate().year}';

        return ListTile(
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
              style: const TextStyle(color: HistorialConstantes.colorTexto),
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: HistorialConstantes.colorTextoSecundario,
          ),
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
