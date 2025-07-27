import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roller_maniac/features/tiempos/presentation/view/pantalla_principal.dart';

import '../../constantes/tiempos_constantes.dart';
import '../viewmodel/tiempos_viewmodel.dart';
import 'secciones_widget.dart';
import 'lista_parques_widget.dart';
import '../../../historial/presentation/viewmodel/reporte_diario_viewmodel.dart';

class ParquesListScreen extends StatefulWidget {
  const ParquesListScreen({Key? key}) : super(key: key);

  @override
  State<ParquesListScreen> createState() => _ParquesListScreenState();
}

class _ParquesListScreenState extends State<ParquesListScreen>
    with AutomaticKeepAliveClientMixin {
  bool _isNavigating = false;
  String _busqueda = '';
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _showScrollToTop = ValueNotifier(false);
  final ValueNotifier<bool> _showSections = ValueNotifier(true);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _showScrollToTop.dispose();
    _showSections.dispose();
    super.dispose();
  }

  void _onScroll() {
    final viewModel = Provider.of<TiemposViewModel>(context, listen: false);
    final offset = _scrollController.offset;

    _showScrollToTop.value = offset > 200;
    _showSections.value = offset < 100;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    const threshold = 200.0;

    if (maxScroll - currentScroll <= threshold) {
      viewModel.cargarMasParques();
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final viewModel = context.watch<TiemposViewModel>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Buscar parque...',
              prefixIcon: Icon(Icons.search),
              filled: true,
              fillColor: Colors.white10,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) => setState(() => _busqueda = value),
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: _showSections,
          builder: (context, show, _) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: show ? null : 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: show ? 1.0 : 0.0,
                child: SeccionesWidget(
                  continenteSeleccionado: viewModel.continenteActual,
                  onContinenteChanged: viewModel.cambiarContinente,
                  viewModel: viewModel,
                ),
              ),
            );
          },
        ),
        Expanded(
          child: ListaParquesWidget(
            viewModel: viewModel,
            parques: viewModel.filtrarPorBusqueda(_busqueda),
            scrollController: _scrollController,
            showScrollToTop: _showScrollToTop,
            onScrollToTop: _scrollToTop,
            onRegistrarVisita: _registrarVisita,
            isNavigating: _isNavigating,
            onNavigatingChanged: (value) => setState(() => _isNavigating = value),
            cargando: viewModel.cargando,
            error: viewModel.error,
          ),
        ),
      ],
    );
  }

  Future<void> _registrarVisita(
      BuildContext context, String parqueId, String parqueNombre) async {
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
      final reporteDiarioViewModel = context.read<ReporteDiarioViewModel>();
      await reporteDiarioViewModel.cargarReporteActual(user.uid, DateTime.now());

      if (!reporteDiarioViewModel.tieneReporteActivo) {
        await reporteDiarioViewModel.iniciarNuevoDia(
          parqueId: parqueId,
          parqueNombre: parqueNombre,
        );
      }

      VisitaRegistradaNotification(parqueId, parqueNombre).dispatch(context);

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
}