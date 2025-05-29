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
      // Pasamos la función actualizarVisitas al HistorialScreen
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
          gradient: TiemposConstantes.gradienteFondo,
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                title: Text(
                  TiemposConstantes.tituloApp,
                  style: TiemposConstantes.estiloTituloAppBar,
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

  Future<void> _registrarVisita(BuildContext context, String parqueId, String parqueNombre) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(user == null
              ? TiemposConstantes.errorSesion
              : TiemposConstantes.errorVerificacion),
          backgroundColor: TiemposConstantes.error,
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
              const CircularProgressIndicator(color: TiemposConstantes.textoPrincipal),
              const SizedBox(width: 20),
              Expanded(child: Text('${TiemposConstantes.registrarVisita}...')),
            ],
          ),
          duration: const Duration(minutes: 1),
          backgroundColor: TiemposConstantes.tarjeta,
        ),
      );

    try {
      await FirebaseService.registrarVisita(parqueId, parqueNombre);
      snackBar
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('${TiemposConstantes.visitando} $parqueNombre'),
            backgroundColor: TiemposConstantes.exito,
          ),
        );
    } catch (e) {
      snackBar
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('${TiemposConstantes.errorCargar}: ${e.toString()}'),
            backgroundColor: TiemposConstantes.error,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<TiemposViewModel>(context);

    return RefreshIndicator(
      color: TiemposConstantes.textoPrincipal,
      onRefresh: viewModel.cargarParques,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TiemposConstantes.paddingHorizontal,
        ),
        child: viewModel.cargando
            ? const Center(child: CircularProgressIndicator(color: TiemposConstantes.textoPrincipal))
            : viewModel.error != null
            ? Center(
          child: Text(
            '${TiemposConstantes.errorCargar}: ${viewModel.error}',
            style: const TextStyle(color: TiemposConstantes.error),
          ),
        )
            : ListView.separated(
          itemCount: viewModel.parques.length,
          separatorBuilder: (_, __) => const SizedBox(height: TiemposConstantes.separacionElementos),
          itemBuilder: (context, index) {
            final parque = viewModel.parques[index];
            return ParqueCard(
              parque: parque,
              onTap: () async {
                final atracciones = await viewModel.cargarAtracciones(parque.id);
                final parqueConAtracciones = Parque(
                  id: parque.id,
                  nombre: parque.nombre,
                  pais: parque.pais,
                  ciudad: parque.ciudad,
                  atracciones: atracciones,
                  clima: parque.clima,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetallesParqueScreen(parque: parqueConAtracciones),
                  ),
                );
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
        color: TiemposConstantes.tarjeta,
        elevation: TiemposConstantes.elevacionTarjeta,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TiemposConstantes.radioBordes),
        ),
        child: Padding(
          padding: const EdgeInsets.all(TiemposConstantes.separacionInterna),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    TiemposConstantes.parque,
                    color: TiemposConstantes.textoPrincipal,
                    size: 28,
                  ),
                  const SizedBox(width: TiemposConstantes.separacionInterna),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          parque.nombre,
                          style: TiemposConstantes.estiloTitulo,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          (parque.nombre == 'Parque Warner Madrid')
                              ? TiemposConstantes.warnerMadrid
                              : (parque.nombre == 'PortAventura Park' || parque.nombre == 'Ferrari Land')
                              ? TiemposConstantes.portAventura
                              : '${parque.ciudad}, ${parque.pais}',
                          style: TiemposConstantes.estiloSubtitulo,
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
                                  TiemposConstantes.clima,
                                  size: 24,
                                  color: Colors.yellow,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${parque.clima!.temperatura.toStringAsFixed(1)}°C',
                                style: TiemposConstantes.estiloSubtitulo,
                              ),
                            ],
                          ),
                          Text(
                            parque.clima!.descripcion,
                            style: TiemposConstantes.estiloSubtitulo,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TiemposConstantes.separacionInterna),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: onRegistrarVisita,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TiemposConstantes.botonPrimario,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    TiemposConstantes.registrarVisita,
                    style: TiemposConstantes.estiloBotonPrimario,
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
