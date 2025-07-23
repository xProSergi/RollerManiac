import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../services/firebase_service.dart';
import '../../constantes/tiempos_constantes.dart';
import '../../domain/entities/parque.dart';
import '../viewmodel/tiempos_viewmodel.dart';
import 'secciones_widget.dart';
import 'lista_parques_widget.dart';

class ParquesListScreen extends StatefulWidget {
  const ParquesListScreen({Key? key}) : super(key: key);

  @override
  State<ParquesListScreen> createState() => _ParquesListScreenState();
}

class _ParquesListScreenState extends State<ParquesListScreen> with AutomaticKeepAliveClientMixin {
  bool _isNavigating = false;
  String _busqueda = '';
  String _continenteSeleccionado = 'Europa'; // Valor inicial para el continente
  final ScrollController _scrollController = ScrollController();

  final ValueNotifier<bool> _showScrollToTop = ValueNotifier(false);
  final ValueNotifier<bool> _showSections = ValueNotifier(true);

  DateTime _lastScrollTime = DateTime.now();
  bool _isLoadingMore = false; // Bandera para controlar la carga de más parques

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _inicializarDatos();
    });
  }

  Future<void> _inicializarDatos() async {
    final viewModel = Provider.of<TiemposViewModel>(context, listen: false);

    // Cargar favoritos primero
    await viewModel.cargarFavoritos();

    // Intentar cargar parques
    await viewModel.cargarParques();

    // Si no hay parques después de cargar, forzar recarga
    if (viewModel.parques.isEmpty && mounted) {
      await _recargarParquesConReintentos(viewModel);
    }
  }

  Future<void> _recargarParquesConReintentos(TiemposViewModel viewModel) async {
    int intentos = 0;
    const maxIntentos = 3;

    while (intentos < maxIntentos && viewModel.parques.isEmpty && mounted) {
      intentos++;
      await Future.delayed(Duration(seconds: 1 * intentos));

      // Cambiar a continente por defecto con más probabilidad de tener datos
      final continentePorDefecto = 'América';
      if (_continenteSeleccionado != continentePorDefecto) {
        setState(() => _continenteSeleccionado = continentePorDefecto);
      }

      await viewModel.cambiarContinente(continentePorDefecto);

      if (viewModel.parques.isNotEmpty) break;
    }

    if (viewModel.parques.isEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudieron cargar los parques. Intente más tarde.'))
      );
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _showScrollToTop.dispose();
    _showSections.dispose();
    super.dispose();
  }

  // En _ParquesListScreenState
  void _onScroll() {
    final viewModel = Provider.of<TiemposViewModel>(context, listen: false);

    // Controlar la visibilidad de las secciones
    final offset = _scrollController.offset;
    _showScrollToTop.value = offset > 200;
    _showSections.value = offset < 100;

    // Detectar cuando estamos cerca del final
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    const threshold = 200; // Margen antes de llegar al final

    if (maxScroll - currentScroll <= threshold &&
        !viewModel.cargandoMas &&
        viewModel.hayMasParques) {
      _cargarMasParquesConSeguridad(viewModel);
    }
  }

  Future<void> _cargarMasParquesConSeguridad(TiemposViewModel viewModel) async {
    try {
      await viewModel.cargarMasParques();

      // Si no se cargaron nuevos parques pero hayMasParques sigue siendo true
      if (viewModel.hayMasParques && viewModel.parques.isEmpty) {
        await Future.delayed(const Duration(seconds: 1));
        await viewModel.cargarMasParques(); // Intentar una vez más
      }
    } catch (e) {
      debugPrint('Error en carga paginada: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al cargar más parques')));
      }
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
              height: show ? null : 0, // Ajusta la altura dinámicamente
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: show ? 1.0 : 0.0,
                child: Consumer<TiemposViewModel>( // Consumer para SeccionesWidget
                  builder: (context, viewModel, _) {
                    return SeccionesWidget(
                      continenteSeleccionado: _continenteSeleccionado,
                      onContinenteChanged: (cont) {
                        setState(() => _continenteSeleccionado = cont);
                        viewModel.cambiarContinente(cont);
                      },
                      viewModel: viewModel,
                    );
                  },
                ),
              ),
            );
          },
        ),
        Expanded(
          child: Selector<TiemposViewModel, Tuple3<List<Parque>, bool, String>>(
            selector: (_, viewModel) => Tuple3(
              viewModel.filtrarPorBusqueda(_busqueda),
              viewModel.cargando,
              viewModel.error ?? '', // Manejar el caso de error nulo
            ),
            builder: (context, data, child) {
              final parques = data.item1;
              final cargando = data.item2;
              final error = data.item3;

              return ListaParquesWidget(
                viewModel: Provider.of<TiemposViewModel>(context, listen: false), // Pasar el ViewModel para métodos que no causan rebuilds aquí
                parques: parques,
                scrollController: _scrollController,
                showScrollToTop: _showScrollToTop,
                onScrollToTop: _scrollToTop,
                onRegistrarVisita: _registrarVisita,
                isNavigating: _isNavigating,
                onNavigatingChanged: (value) => setState(() => _isNavigating = value),
                cargando: cargando, // Pasar el estado de carga
                error: error.isNotEmpty ? error : null, // Pasar el mensaje de error
              );
            },
          ),
        ),
      ],
    );
  }

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
      // Retraso para que el usuario vea el mensaje de "registrando"
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
      // Retraso para que el usuario vea el mensaje de "error"
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

// Clase auxiliar para devolver múltiples valores del selector
class Tuple3<T1, T2, T3> {
  final T1 item1;
  final T2 item2;
  final T3 item3;

  Tuple3(this.item1, this.item2, this.item3);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Tuple3 &&
              runtimeType == other.runtimeType &&
              item1 == other.item1 &&
              item2 == other.item2 &&
              item3 == other.item3;

  @override
  int get hashCode => item1.hashCode ^ item2.hashCode ^ item3.hashCode;
}