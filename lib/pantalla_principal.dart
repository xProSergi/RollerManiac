import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/tiempos/presentation/viewmodel/tiempos_viewmodel.dart';
import 'features/tiempos/presentation/view/detalles_parque_screen.dart';
import 'features/tiempos/domain/entities/parque.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({Key? key}) : super(key: key);

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TiemposViewModel>(context, listen: false).cargarParques();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<TiemposViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          ' RollerManiac ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: RefreshIndicator(
        onRefresh: viewModel.cargarParques,
        child: viewModel.cargando
            ? const Center(child: CircularProgressIndicator())
            : viewModel.error != null
            ? Center(
          child: Text(
            'Error: ${viewModel.error}',
            style: const TextStyle(color: Colors.red),
          ),
        )
            : ListView.builder(
          itemCount: viewModel.parques.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final parque = viewModel.parques[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                leading: Icon(
                  Icons.park,
                  color: Colors.green[700],
                  size: 32,
                ),
                title: Text(
                  parque.nombre,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  '${parque.ciudad}, ${parque.pais}',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final atracciones = await viewModel.cargarAtracciones(
                    int.parse(parque.id),
                  );
                  final parqueConAtracciones = Parque(
                    id: parque.id,
                    nombre: parque.nombre,
                    pais: parque.pais,
                    ciudad: parque.ciudad,
                    imagenUrl: '',
                    atracciones: atracciones,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          DetallesParqueScreen(parque: parqueConAtracciones),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
