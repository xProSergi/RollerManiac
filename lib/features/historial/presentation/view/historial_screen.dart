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
          content: Text(
            '${HistorialConstantes.errorCargandoVisitas} $e',
            style: const TextStyle(color: HistorialConstantes.colorTexto),
          ),
          backgroundColor: HistorialConstantes.colorError,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    final Map<String, List<Map<String, dynamic>>> visitasPorParque = {};
    for (var visita in visitas) {
      final nombre = visita['parqueNombre'] as String;
      if (!visitasPorParque.containsKey(nombre)) {
        visitasPorParque[nombre] = [];
      }
      visitasPorParque[nombre]!.add(visita);
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: HistorialConstantes.colorFondo,


      body: Container(
        decoration: const BoxDecoration(
          gradient: HistorialConstantes.gradienteFondo,
        ),
        child: isLoading
            ? const Center(
          child: CircularProgressIndicator(
            color: HistorialConstantes.colorAzulVivo,
          ),
        )
            : visitas.isEmpty
            ? const Center(
          child: Text(
            HistorialConstantes.noHayVisitas,
            style: HistorialConstantes.estiloVacio,
          ),
        )
            : _buildHistorialContent(visitasPorParque),
      ),
    );
  }

  Widget _buildHistorialContent(Map<String, List<Map<String, dynamic>>> visitasPorParque) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
      itemCount: visitasPorParque.length,
      itemBuilder: (context, index) {
        final parqueNombre = visitasPorParque.keys.elementAt(index);
        final parqueVisitas = visitasPorParque[parqueNombre]!;
        final parqueId = parqueVisitas.first['parqueId'].toString();

        final ultimaVisita = parqueVisitas.first['fecha'];

        final dia= ultimaVisita.toDate().day.toString().padLeft(2,'0');
        final mes= ultimaVisita.toDate().month.toString().padLeft(2,'0');
        final anio= ultimaVisita.toDate().year.toString().padLeft(2,'0');


        final fechaFormateada = '$dia/$mes/$anio';

        final totalVisitas = parqueVisitas.length;

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
              '${HistorialConstantes.visitas}: $totalVisitas - ${HistorialConstantes.ultima}: $fechaFormateada',
              style: HistorialConstantes.estiloSubtitulo,
            ),
            leading: CircleAvatar(
              backgroundColor: HistorialConstantes.colorAvatar,
              child: Text(
                totalVisitas.toString(),
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
          ),
        );
      },
    );
  }
}
