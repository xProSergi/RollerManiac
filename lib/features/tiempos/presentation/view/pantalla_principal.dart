import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../../historial/data/datasources/historial_remote_datasource.dart';

import '../viewmodel/tiempos_viewmodel.dart';
import 'parques_list_screen.dart';

import '../../../historial/presentation/pages/historial_screen.dart';
import '../../../perfil/presentation/view/perfil_screen.dart';
import '../../../social/presentation/view/social_screen.dart';
import '../../../historial/presentation/viewmodel/historial_view_model.dart';
import '../../../historial/data/repositories/historial_repository_impl.dart';

import '../../../historial/domain/usecases/obtener_visitas_usecase.dart';
import '../../../historial/domain/usecases/obtener_visitas_por_parque_usecase.dart';
import '../../../../compartido/widgets/nav_bar.dart';
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

    final historialDataSource = HistorialRemoteDataSourceImpl();
    final historialRepository = HistorialRepositoryImpl(remoteDataSource: historialDataSource);
    final obtenerVisitasUseCase = ObtenerVisitasUseCase(historialRepository);
    final obtenerVisitasPorParqueUseCase = ObtenerVisitasPorParqueUseCase(historialRepository);

    _pages = [
      const ParquesListScreen(),
      ChangeNotifierProvider(
        create: (_) => HistorialViewModel(
          obtenerVisitasUseCase: obtenerVisitasUseCase,
          obtenerVisitasPorParqueUseCase: obtenerVisitasPorParqueUseCase,
        ),
        child: HistorialScreen(
          actualizarVisitas: () {
            Provider.of<TiemposViewModel>(context, listen: false).cargarParques();
          },
        ),
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