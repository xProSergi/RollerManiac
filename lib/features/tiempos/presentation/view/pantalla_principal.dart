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
import '../../constantes/tiempos_constantes.dart'; // Import specific constant classes

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
      // Consider using Navigator.pushReplacementNamed for better UX after login/auth check
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: TiemposColores.gradienteFondo, // Using TiemposColores
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                title: Text(
                  TiemposTextos.tituloApp, // Using TiemposTextos
                  style: TiemposEstilos.estiloTituloAppBar, // Using TiemposEstilos
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
  static bool _isNavigating = false; // Using static to prevent multiple navigations

  Future<void> _registrarVisita(BuildContext context, String parqueId, String parqueNombre) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(TiemposTextos.errorSesion), // Using TiemposTextos
          backgroundColor: TiemposColores.error, // Using TiemposColores
        ),
      );
      return;
    }

    final snackBar = scaffoldMessenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const CircularProgressIndicator(color: TiemposColores.textoPrincipal), // Using TiemposColores
              const SizedBox(width: 20),
              Expanded(child: Text('${TiemposTextos.registrarVisita}...')), // Using TiemposTextos
            ],
          ),
          duration: const Duration(minutes: 1),
          backgroundColor: TiemposColores.tarjeta, // Using TiemposColores
        ),
      );

    try {
      await FirebaseService.registrarVisita(parqueId, parqueNombre);
      snackBar
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('${TiemposTextos.visitando} $parqueNombre'), // Using TiemposTextos
            backgroundColor: TiemposColores.exito, // Using TiemposColores
          ),
        );
    } catch (e) {
      snackBar
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('${TiemposTextos.errorCargar}: ${e.toString()}'), // Using TiemposTextos
            backgroundColor: TiemposColores.error, // Using TiemposColores
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<TiemposViewModel>(context);

    return RefreshIndicator(
      color: TiemposColores.textoPrincipal, // Using TiemposColores
      onRefresh: viewModel.cargarParques,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TiemposTamanos.paddingHorizontal, // Using TiemposTamanos
        ),
        child: viewModel.cargando // Corrected from isLoading to cargando
            ? const Center(child: CircularProgressIndicator(color: TiemposColores.textoPrincipal)) // Using TiemposColores
            : viewModel.error != null
            ? Center(
          child: Text(
            '${TiemposTextos.errorCargar}: ${viewModel.error}', // Using TiemposTextos
            style: const TextStyle(color: TiemposColores.error), // Using TiemposColores
          ),
        )
            : ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            TiemposTamanos.paddingHorizontal, // Using TiemposTamanos
            0,
            TiemposTamanos.paddingHorizontal, // Using TiemposTamanos
            80,
          ),
          itemCount: viewModel.parques.length,
          separatorBuilder: (_, __) => const SizedBox(height: TiemposTamanos.separacionElementos), // Using TiemposTamanos
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
        color: TiemposColores.tarjeta, // Using TiemposColores
        elevation: TiemposTamanos.elevacionTarjeta, // Using TiemposTamanos
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TiemposTamanos.radioBordes), // Using TiemposTamanos
        ),
        child: Padding(
          padding: const EdgeInsets.all(TiemposTamanos.separacionInterna), // Using TiemposTamanos
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    TiemposIconos.parque, // Using TiemposIconos
                    color: TiemposColores.textoPrincipal, // Using TiemposColores
                    size: 28,
                  ),
                  const SizedBox(width: TiemposTamanos.separacionInterna), // Using TiemposTamanos
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          parque.nombre,
                          style: TiemposEstilos.estiloTitulo, // Using TiemposEstilos
                        ),
                        const SizedBox(height: 4),
                        Text(
                          (parque.nombre == 'Parque Warner Madrid')
                              ? TiemposTextos.warnerMadrid // Using TiemposTextos
                              : (parque.nombre == 'PortAventura Park' || parque.nombre == 'Ferrari Land')
                              ? TiemposTextos.portAventura // Using TiemposTextos
                              : '${parque.ciudad}, ${parque.pais}',
                          style: TiemposEstilos.estiloSubtitulo, // Using TiemposEstilos
                        ),
                        if (parque.clima != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              // Make sure 'codigoIcono' from your 'Clima' entity correctly provides a full URL
                              // If it's a relative path, you might need to prepend a base URL.
                              Image.network(
                                'https:${parque.clima!.codigoIcono}',
                                width: 24,
                                height: 24,
                                errorBuilder: (context, error, stackTrace) => const Icon(
                                  TiemposIconos.clima, // Using TiemposIconos
                                  size: 24,
                                  color: Colors.yellow,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${parque.clima!.temperatura.toStringAsFixed(1)}°C',
                                style: TiemposEstilos.estiloSubtitulo, // Using TiemposEstilos
                              ),
                            ],
                          ),
                          Text(
                            parque.clima!.descripcion,
                            style: TiemposEstilos.estiloSubtitulo, // Using TiemposEstilos
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TiemposTamanos.separacionInterna), // Using TiemposTamanos
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: onRegistrarVisita,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TiemposColores.botonPrimario, // Using TiemposColores
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    TiemposTextos.registrarVisita, // Using TiemposTextos
                    style: TiemposEstilos.estiloBotonPrimario, // Using TiemposEstilos
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