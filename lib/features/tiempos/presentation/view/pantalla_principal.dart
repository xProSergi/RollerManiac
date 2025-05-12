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

  void _actualizarVisitas() {
    setState(() {});
  }

  void _cargarVisitasDesdePrincipal() {}

  @override
  void initState() {
    super.initState();
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
            return GestureDetector(
              onTap: () async {
                final atracciones =
                await viewModel.cargarAtracciones(int.parse(parque.id));
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
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 18),
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
                                '${parque.ciudad}, ${parque.pais}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () => _registrarVisita(
                              context, parque.id, parque.nombre),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF38BDF8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Visita',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}