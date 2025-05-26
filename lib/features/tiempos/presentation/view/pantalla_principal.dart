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
  String? userId;

  void _actualizarVisitas() {
    setState(() {});
  }

  void _cargarVisitasDesdePrincipal() {}

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;
    userId = user?.uid;

    _pages = [
      const ParquesListScreen(),
      HistorialScreen(
        actualizarVisitas: _actualizarVisitas,
        cargarVisitasCallback: _cargarVisitasDesdePrincipal,
      ),
      const SocialScreen(),
      PerfilScreen(),
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
    } else if (!user.emailVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(TiemposTextos.errorVerificacion),
          backgroundColor: TiemposColores.info,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TiemposColores.fondoOscuro,
      appBar: AppBar(
        backgroundColor: TiemposColores.tarjetaOscura,
        elevation: 0,
        centerTitle: true,
        title: Text(
          TiemposTextos.tituloApp,
          style: TiemposEstilos.tituloAppBarOscuro,
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

class ParquesListScreen extends StatelessWidget {
  const ParquesListScreen({Key? key}) : super(key: key);

  Future<void> _registrarVisita(BuildContext context, String parqueId, String parqueNombre) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || !user.emailVerified) {
      final mensaje = user == null
          ? TiemposTextos.errorSesion
          : TiemposTextos.errorVerificacion;

      scaffoldMessenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(mensaje),
            backgroundColor: TiemposColores.error,
          ),
        );
      return;
    }

    scaffoldMessenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              CircularProgressIndicator(color: TiemposColores.textoClaro),
              SizedBox(width: 20),
              Expanded(child: Text('Registrando visita...')),
            ],
          ),
          duration: Duration(minutes: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );

    try {
      await FirebaseService.registrarVisita(parqueId, parqueNombre);

      scaffoldMessenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(' ${TiemposTextos.visitando} $parqueNombre'),
            backgroundColor: TiemposColores.exito,
          ),
        );
    } on FirebaseException catch (e) {
      scaffoldMessenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(' ${TiemposTextos.errorCargar}: ${e.message ?? 'Error desconocido'}'),
            backgroundColor: TiemposColores.error,
          ),
        );
    } catch (e) {
      scaffoldMessenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('⚠️ ${TiemposTextos.errorCargar}: ${e.toString()}'),
            backgroundColor: TiemposColores.error,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<TiemposViewModel>(context);

    return RefreshIndicator(
      color: TiemposColores.textoClaro,
      onRefresh: viewModel.cargarParques,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TiemposTamanos.paddingHorizontal,
          vertical: TiemposTamanos.paddingVertical,
        ),
        child: viewModel.cargando
            ? const Center(
            child: CircularProgressIndicator(color: TiemposColores.textoClaro))
            : viewModel.error != null
            ? Center(
          child: Text(
            '${TiemposTextos.errorCargar}: ${viewModel.error}',
            style: const TextStyle(color: TiemposColores.error),
          ),
        )
            : ListView.separated(
          itemCount: viewModel.parques.length,
          separatorBuilder: (_, __) => const SizedBox(height: TiemposTamanos.separacionElementos),
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
      child: Container(
        decoration: BoxDecoration(
          color: TiemposColores.tarjetaOscura,
          borderRadius: BorderRadius.circular(TiemposTamanos.radioBordes),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  TiemposIconos.parque,
                  color: TiemposColores.textoClaro,
                  size: 28,
                ),
                const SizedBox(width: TiemposTamanos.separacionInterna),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        parque.nombre,
                        style: TiemposEstilos.tituloParqueOscuro,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        (parque.nombre == 'Parque Warner Madrid')
                            ? TiemposTextos.warnerMadrid
                            : (parque.nombre == 'PortAventura Park' || parque.nombre == 'Ferrari Land')
                            ? TiemposTextos.portAventura
                            : '${parque.ciudad}, ${parque.pais}',
                        style: TiemposEstilos.subtituloOscuro,
                      ),
                      const SizedBox(height: 4),
                      if (parque.clima != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Image.network(
                                  'https:${parque.clima!.codigoIcono}',
                                  width: 24,
                                  height: 24,
                                  errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    TiemposIconos.clima,
                                    size: 24,
                                    color: Colors.yellow,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${parque.clima!.temperatura.toStringAsFixed(1)}°C',
                                  style: TiemposEstilos.subtituloOscuro,
                                ),
                              ],
                            ),
                            Text(
                              parque.clima!.descripcion,
                              style: TiemposEstilos.subtituloOscuro,
                            ),
                          ],
                        ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: Text(
                  TiemposTextos.registrarVisita,
                  style: TiemposEstilos.botonPrimario,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}