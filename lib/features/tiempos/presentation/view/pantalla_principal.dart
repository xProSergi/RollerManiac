import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../../../compartido/widgets/nav_bar.dart';
import '../../../historial/presentation/viewmodel/reporte_diario_viewmodel.dart';
import '../viewmodel/tiempos_viewmodel.dart';
import 'parques_list_screen.dart';
import '../../../historial/presentation/pages/historial_screen.dart';
import '../../../perfil/presentation/view/perfil_screen.dart';
import '../../../social/presentation/view/social_screen.dart';
import '../../constantes/tiempos_constantes.dart';
import '../../../historial/presentation/pages/resumen_dia_screen.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({Key? key}) : super(key: key);

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  int _selectedIndex = 0;
  bool _showFinishButton = false;
  String? _currentParkId;
  String? _currentParkName;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ParquesListScreen(onVisitaRegistrada: onVisitaRegistrada),
      const HistorialScreen(),
      const SocialScreen(),
      const PerfilScreen(),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verifyAuth(context);
      Provider.of<TiemposViewModel>(context, listen: false).inicializar();
    });
  }

  Future<void> _verifyAuth(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  void onVisitaRegistrada(String parkId, String parkName) {
    setState(() {
      _showFinishButton = true;
      _currentParkId = parkId;
      _currentParkName = parkName;
    });
  }

  Future<void> _finalizarVisita(BuildContext context) async {
    try {
      final reporteDiarioViewModel = context.read<ReporteDiarioViewModel>();
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) throw Exception('Usuario no autenticado');

      final exito = await reporteDiarioViewModel.finalizarDia();

      if (exito && mounted) {
        // Espera a que el reporteActual tenga el id actualizado
        String? reporteId;
        int retries = 0;
        while (retries < 10) {
          reporteId = reporteDiarioViewModel.reporteActual?.id;
          if (reporteId != null) break;
          await Future.delayed(const Duration(milliseconds: 100));
          retries++;
        }

        if (reporteId != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResumenDiaScreen(
                reporteId: reporteId!,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo obtener el reporte finalizado.'),
              backgroundColor: Colors.red,
            ),
          );
        }

        setState(() {
          _showFinishButton = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo finalizar la visita.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al finalizar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
                child: IndexedStack(
                  index: _selectedIndex,
                  children: _pages,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
      floatingActionButton: _showFinishButton
          ? FloatingActionButton.extended(
        heroTag: 'finish_visit_fab',
        onPressed: () => _finalizarVisita(context),
        icon: const Icon(Icons.flag),
        label: const Text('Finalizar Visita'),
        backgroundColor: Colors.green,
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}