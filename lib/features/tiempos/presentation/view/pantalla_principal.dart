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
          content: Text('Por favor verifica tu email'),
          backgroundColor: Colors.orange,
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
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'RollerManiac',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 1.1,
          ),
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
          ? 'Debes iniciar sesión para registrar visitas'
          : 'Por favor verifica tu email para continuar';

      scaffoldMessenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(mensaje),
            backgroundColor: Colors.red,
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
              CircularProgressIndicator(color: Colors.white),
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
            content: Text('✅ Visita registrada en $parqueNombre'),
            backgroundColor: Colors.green,
          ),
        );
    } on FirebaseException catch (e) {
      scaffoldMessenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('🔥 Error: ${e.message ?? 'Error desconocido'}'),
            backgroundColor: Colors.red,
          ),
        );
    } catch (e) {
      scaffoldMessenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('⚠️ Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<TiemposViewModel>(context);

    return RefreshIndicator(
      color: Colors.white,
      onRefresh: viewModel.cargarParques,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: viewModel.cargando
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : viewModel.error != null
            ? Center(
          child: Text(
            'Error: ${viewModel.error}',
            style: const TextStyle(color: Colors.redAccent),
          ),
        )
            : ListView.separated(
          itemCount: viewModel.parques.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final parque = viewModel.parques[index];
            return ParqueCard(
              parque: parque,
              onTap: () async {
                final atracciones =
                await viewModel.cargarAtracciones(parque.id);
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
                    builder: (_) =>
                        DetallesParqueScreen(parque: parqueConAtracciones),
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
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.apartment_rounded,
                    color: Colors.white, size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        parque.nombre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        (parque.nombre == 'Parque Warner Madrid')
                            ? 'San Martín de la Vega, Madrid, Spain'
                            : (parque.nombre == 'PortAventura Park' || parque.nombre == 'Ferrari Land')
                            ? 'Salou, Tarragona, Spain'
                            : '${parque.ciudad}, ${parque.pais}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
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
                                  const Icon(Icons.wb_sunny, size: 24, color: Colors.yellow),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${parque.clima!.temperatura.toStringAsFixed(1)}°C',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              parque.clima!.descripcion,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: onRegistrarVisita,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text(
                  'Registrar visita',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
