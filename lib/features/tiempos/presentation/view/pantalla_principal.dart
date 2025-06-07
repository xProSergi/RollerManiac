import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../viewmodel/tiempos_viewmodel.dart';
import 'detalles_parque_screen.dart';
import '../../domain/entities/parque.dart';
import '../../../historial/presentation/view/historial_screen.dart';
import '../../../perfil/presentation/view/perfil_screen.dart';
import '../../../social/presentation/view/social_screen.dart';
import '../../../../compartido/widgets/nav_bar.dart';
import '../../../../services/firebase_service.dart';
import '../../constantes/tiempos_constantes.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({Key? key}) : super(key: key);

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const ParquesListScreen(),
      HistorialScreen(
        actualizarVisitas: () {
          Provider.of<TiemposViewModel>(context, listen: false).cargarParques();
        },
      ),
      const SocialScreen(),
      const PerfilScreen(),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verifyAuth(context);
      Provider.of<TiemposViewModel>(context, listen: false).cargarParques();
    });
  }

  Future<void> _verifyAuth(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {

      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: TiemposColores.gradienteFondo,
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                title: Text(
                  TiemposTextos.tituloApp,
                  style: TiemposEstilos.estiloTituloAppBar,
                ),
              ),
              Expanded(
                child: _pages[_selectedIndex],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}

class ParquesListScreen extends StatelessWidget {
  const ParquesListScreen({Key? key}) : super(key: key);
  static bool _isNavigating = false;

  Future<void> _registrarVisita(BuildContext context, String parqueId, String parqueNombre) async {
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
            Expanded(child: Text('${TiemposTextos.registrarVisita}...')),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: TiemposColores.tarjeta,
      ),
    );

    try {
      await FirebaseService.registrarVisita(parqueId, parqueNombre);


      await Future.delayed(const Duration(seconds: 2));

      if (!context.mounted) return;

      scaffoldMessenger.hideCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('${TiemposTextos.visitando} $parqueNombre'),
          backgroundColor: TiemposColores.exito,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {

      await Future.delayed(const Duration(seconds: 2));

      if (!context.mounted) return;

      scaffoldMessenger.hideCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('${TiemposTextos.errorCargar}: ${e.toString()}'),
          backgroundColor: TiemposColores.error,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<TiemposViewModel>(context);

    return RefreshIndicator(
      color: TiemposColores.textoPrincipal,
      onRefresh: viewModel.cargarParques,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TiemposTamanos.paddingHorizontal,
        ),
        child: viewModel.cargando
            ? const Center(child: CircularProgressIndicator(color: TiemposColores.textoPrincipal))
            : viewModel.error != null
            ? Center(
          child: Text(
            '${TiemposTextos.errorCargar}: ${viewModel.error}',
            style: const TextStyle(color: TiemposColores.error),
          ),
        )
            : ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            TiemposTamanos.paddingHorizontal,
            0,
            TiemposTamanos.paddingHorizontal,
            80,
          ),
          itemCount: viewModel.parques.length,
          separatorBuilder: (_, __) => const SizedBox(height: TiemposTamanos.separacionElementos),
          itemBuilder: (context, index) {
            final parque = viewModel.parques[index];
            return ParqueCard(
              parque: parque,
              onTap: () async {
                if (_isNavigating) return;

                _isNavigating = true;

                try {
                  final atracciones = await viewModel.cargarAtracciones(parque.id);
                  final parqueConAtracciones = Parque(
                    id: parque.id,
                    nombre: parque.nombre,
                    pais: parque.pais,
                    ciudad: parque.ciudad,
                    atracciones: atracciones,
                    clima: parque.clima,
                  );

                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetallesParqueScreen(parque: parqueConAtracciones),
                    ),
                  );
                } finally {
                  _isNavigating = false;
                }
              },
              onRegistrarVisita: () => _registrarVisita(context, parque.id.toString(), parque.nombre),
            );
          },
        ),
      ),
    );
  }
}

class ParqueCard extends StatelessWidget {
  final Parque parque;
  final VoidCallback onRegistrarVisita;
  final VoidCallback onTap;

  const ParqueCard({
    Key? key,
    required this.parque,
    required this.onRegistrarVisita,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: TiemposColores.tarjeta,
        elevation: TiemposTamanos.elevacionTarjeta,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TiemposTamanos.radioBordes),
        ),
        child: Padding(
          padding: const EdgeInsets.all(TiemposTamanos.separacionInterna),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    TiemposIconos.parque,
                    color: TiemposColores.textoPrincipal,
                    size: 28,
                  ),
                  const SizedBox(width: TiemposTamanos.separacionInterna),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          parque.nombre,
                          style: TiemposEstilos.estiloTitulo,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          (parque.nombre == 'Parque Warner Madrid')
                              ? TiemposTextos.warnerMadrid
                              : (parque.nombre == 'PortAventura Park' || parque.nombre == 'Ferrari Land')
                              ? TiemposTextos.portAventura
                              : '${parque.ciudad}, ${parque.pais}',
                          style: TiemposEstilos.estiloSubtitulo,
                        ),
                        if (parque.clima != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Image.network(
                                'https:${parque.clima!.codigoIcono}',
                                width: 24,
                                height: 24,
                                errorBuilder: (context, error, stackTrace) => const Icon(
                                  TiemposIconos.clima,
                                  size: 24,
                                  color: Colors.yellow,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${parque.clima!.temperatura.toStringAsFixed(1)}°C',
                                style: TiemposEstilos.estiloSubtitulo,
                              ),
                            ],
                          ),
                          Text(
                            parque.clima!.descripcion,
                            style: TiemposEstilos.estiloSubtitulo,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TiemposTamanos.separacionInterna),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: onRegistrarVisita,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TiemposColores.botonPrimario,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    TiemposTextos.registrarVisita,
                    style: TiemposEstilos.estiloBotonPrimario,
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