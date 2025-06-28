import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Importación añadida

import '../../../historial/data/datasources/historial_remote_datasource.dart';
import '../../domain/entities/clima.dart';
import '../viewmodel/tiempos_viewmodel.dart';
import 'detalles_parque_screen.dart';
import '../../domain/entities/parque.dart';
import '../../../historial/presentation/pages/historial_screen.dart';
import '../../../perfil/presentation/view/perfil_screen.dart';
import '../../../social/presentation/view/social_screen.dart';
import '../../../historial/presentation/viewmodel/historial_view_model.dart';
import '../../../historial/data/repositories/historial_repository_impl.dart';
// import '../../../historial/data/datasources/historial_remote_datasource.dart'; // Duplicado, se puede borrar
import '../../../historial/domain/usecases/obtener_visitas_usecase.dart';
import '../../../historial/domain/usecases/obtener_visitas_por_parque_usecase.dart';
import '../../../../compartido/widgets/nav_bar.dart';
import '../../../../services/firebase_service.dart';
import '../../constantes/tiempos_constantes.dart';
import '../../utils/parque_utils.dart';
import 'package:geolocator/geolocator.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter/rendering.dart'; // Para RepaintBoundary

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
            // Asegúrate de que el contexto esté montado antes de usarlo
            if (mounted) {
              Provider.of<TiemposViewModel>(context, listen: false).cargarParques();
            }
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
    if (user == null && mounted) { // Verificar mounted antes de navegar
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
                title: const Text( // Añadido const
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

class ParquesListScreen extends StatefulWidget {
  const ParquesListScreen({Key? key}) : super(key: key);

  @override
  State<ParquesListScreen> createState() => _ParquesListScreenState();
}

class _ParquesListScreenState extends State<ParquesListScreen> with AutomaticKeepAliveClientMixin {
  bool _isNavigating = false;
  String _busqueda = '';
  String _continenteSeleccionado = 'Europa';
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;
  bool _showSections = true;

  DateTime _lastScrollTime = DateTime.now();
  bool _isLoadingMore = false;

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
    super.dispose();
  }

  void _onScroll() {
    final now = DateTime.now();

    if (now.difference(_lastScrollTime).inMilliseconds < 50) {
      return;
    }
    _lastScrollTime = now;

    final offset = _scrollController.offset;
    final shouldShowSections = offset < 100;

    // Solo actualiza el estado si hay un cambio para evitar reconstrucciones innecesarias
    if (_showScrollToTop != (offset > 200) || _showSections != shouldShowSections) {
      setState(() {
        _showScrollToTop = offset > 200;
        _showSections = shouldShowSections;
      });
    }


    if (!_isLoadingMore && _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final viewModel = Provider.of<TiemposViewModel>(context, listen: false);
      if (viewModel.hayMasParques && !viewModel.cargandoMas) {
        _isLoadingMore = true;
        viewModel.cargarMasParques().then((_) {
          if (mounted) { // Asegurarse de que el widget sigue montado
            _isLoadingMore = false;
          }
        });
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

    return Consumer<TiemposViewModel>(
      builder: (context, viewModel, child) {
        final parques = viewModel.filtrarPorBusqueda(_busqueda);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                decoration: const InputDecoration( // Añadido const
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
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: _showSections ? null : 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _showSections ? 1.0 : 0.0,
                child: _SeccionesWidget(
                  continenteSeleccionado: _continenteSeleccionado,
                  onContinenteChanged: (cont) {
                    setState(() => _continenteSeleccionado = cont);
                    viewModel.cambiarContinente(cont);
                  },
                  viewModel: viewModel,
                ),
              ),
            ),
            Expanded(
              child: _ListaParquesWidget(
                viewModel: viewModel,
                parques: parques,
                scrollController: _scrollController,
                showScrollToTop: _showScrollToTop,
                onScrollToTop: _scrollToTop,
                onRegistrarVisita: _registrarVisita,
                isNavigating: _isNavigating,
                onNavigatingChanged: (value) => setState(() => _isNavigating = value),
              ),
            ),
          ],
        );
      },
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

class _SeccionesWidget extends StatelessWidget {
  final String continenteSeleccionado;
  final Function(String) onContinenteChanged;
  final TiemposViewModel viewModel;

  const _SeccionesWidget({
    Key? key,
    required this.continenteSeleccionado,
    required this.onContinenteChanged,
    required this.viewModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: [
              Text(
                'Continentes',
                style: TiemposEstilos.estiloTituloAppBar.copyWith(
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    'Europa', 'Asia', 'América'
                  ].map((cont) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(
                        cont,
                        style: const TextStyle( // Añadido const
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      selected: continenteSeleccionado == cont,
                      onSelected: (_) => onContinenteChanged(cont),
                      selectedColor: TiemposColores.botonPrimario,
                      backgroundColor: Colors.white10,
                      labelStyle: TextStyle(
                        color: continenteSeleccionado == cont
                            ? Colors.white
                            : TiemposColores.textoSecundario,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: const RoundedRectangleBorder( // Añadido const
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  )).toList(),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 12.0),
          child: Column(
            children: [
              Text(
                'Ordenar por',
                style: TiemposEstilos.estiloTituloAppBar.copyWith(
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _OrdenButton(
                    label: 'Alfabético',
                    selected: viewModel.ordenActual == 'Alfabético',
                    onTap: () => viewModel.cambiarOrden('Alfabético'),
                  ),
                  const SizedBox(width: 8),
                  _OrdenButton(
                    label: 'Cercanía',
                    selected: viewModel.ordenActual == 'Cercanía',
                    onTap: () async {
                      await viewModel.cambiarOrden('Cercanía');
                    },
                  ),
                  const SizedBox(width: 8),
                  _OrdenButton(
                    label: 'Favoritos',
                    selected: viewModel.ordenActual == 'Favoritos',
                    onTap: () => viewModel.cambiarOrden('Favoritos'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ListaParquesWidget extends StatelessWidget {
  final TiemposViewModel viewModel;
  final List<Parque> parques;
  final ScrollController scrollController;
  final bool showScrollToTop;
  final VoidCallback onScrollToTop;
  final Future<void> Function(BuildContext, String, String) onRegistrarVisita;
  final bool isNavigating;
  final Function(bool) onNavigatingChanged;

  const _ListaParquesWidget({
    Key? key,
    required this.viewModel,
    required this.parques,
    required this.scrollController,
    required this.showScrollToTop,
    required this.onScrollToTop,
    required this.onRegistrarVisita,
    required this.isNavigating,
    required this.onNavigatingChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        viewModel.cargando
            ? const Center(child: CircularProgressIndicator(color: TiemposColores.textoPrincipal))
            : viewModel.error != null
            ? Center(
          child: Text(
            '${TiemposTextos.errorCargar}: ${viewModel.error}',
            style: const TextStyle(color: TiemposColores.error), // Añadido const
          ),
        )
            : parques.isEmpty
            ? Center(
          child: Text(
            viewModel.cargando
                ? 'Cargando parques...'
                : viewModel.ordenActual == 'Favoritos'
                ? 'No tienes parques favoritos.\nPulsa el corazón en un parque para añadirlo.'
                : 'No hay parques para mostrar.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: TiemposColores.textoSecundario), // Añadido const
          ),
        )
            : ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: parques.length + (viewModel.hayMasParques ? 1 : 0),
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: false, // Mantener en false aquí, usaremos RepaintBoundary en el item
          itemBuilder: (context, index) {
            if (index == parques.length && viewModel.hayMasParques) {
              return Container(
                padding: const EdgeInsets.all(20),
                child: const Center( // Añadido const
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: TiemposColores.textoPrincipal),
                      SizedBox(height: 8),
                      Text(
                        'Cargando más parques...',
                        style: TextStyle(color: TiemposColores.textoSecundario),
                      ),
                    ],
                  ),
                ),
              );
            }

            final parque = parques[index];
            final parqueConClima = viewModel.getParqueConClima(parque.id);
            double? distanciaKm;
            if (viewModel.ordenActual == 'Cercanía' && viewModel.posicionUsuario != null) {
              distanciaKm = calcularDistancia(
                viewModel.posicionUsuario!.latitude,
                viewModel.posicionUsuario!.longitude,
                parque.latitud,
                parque.longitud,
              );
            }

            return RepaintBoundary( // <--- ¡Importante para el rendimiento del scroll!
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: VisibilityDetector(
                  key: Key('parque_${parque.id}'),
                  onVisibilityChanged: (info) {
                    if (info.visibleFraction > 0.1 && viewModel.esFavorito(parque.id)) {
                      if (viewModel.necesitaCargarClima(parque.nombre)) {
                        viewModel.cargarClimaParaParque(
                          parque.nombre,
                          parque.latitud,
                          parque.longitud,
                          parque.pais,
                        );
                      }
                    }
                  },
                  child: ParqueCard(
                    parque: parqueConClima,
                    esFavorito: viewModel.esFavorito(parque.id),
                    onToggleFavorito: () => viewModel.toggleFavorito(parque.id),
                    onTap: () async {
                      if (isNavigating) return; // Still important to prevent double taps/navigations
                      onNavigatingChanged(true); // Signal that navigation is starting
                      try {
                        final atracciones = await viewModel.cargarAtracciones(parque.id);
                        final parqueConAtracciones = Parque(
                          id: parque.id,
                          nombre: parque.nombre,
                          pais: parque.pais,
                          ciudad: parque.ciudad,
                          latitud: parque.latitud,
                          longitud: parque.longitud,
                          continente: parque.continente,
                          atracciones: atracciones,
                          clima: parqueConClima.clima,
                        );
                        // No 'mounted' check needed here for Navigator.push,
                        // as context is expected to be valid for this operation.
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetallesParqueScreen(parque: parqueConAtracciones),
                          ),
                        );
                      } finally {
                        // No 'mounted' check needed here. onNavigatingChanged updates parent state,
                        // which is a StatefulWidget and handles its own mounted status.
                        onNavigatingChanged(false); // Signal that navigation has finished
                      }
                    },
                    onRegistrarVisita: () => onRegistrarVisita(context, parque.id.toString(), parque.nombre),
                    distanciaKm: distanciaKm,
                  ),
                ),
              ),
            );
          },
        ),
        if (showScrollToTop)
          Positioned(
            bottom: 100,
            left: 20,
            child: FloatingActionButton(
              onPressed: onScrollToTop,
              backgroundColor: TiemposColores.botonPrimario,
              child: const Icon( // Añadido const
                Icons.keyboard_arrow_up,
                color: Colors.white,
                size: 28,
              ),
              mini: true,
            ),
          ),
      ],
    );
  }
}

class _OrdenButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _OrdenButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(16)), // Añadido const
        boxShadow: selected ? [
          BoxShadow(
            color: TiemposColores.botonPrimario.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3), // Añadido const
          ),
        ] : null,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: selected ? TiemposColores.botonPrimario : Colors.white10,
          foregroundColor: selected ? Colors.white : TiemposColores.textoSecundario,
          shape: const RoundedRectangleBorder( // Añadido const
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Añadido const
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: const TextStyle( // Añadido const
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

class ParqueCard extends StatelessWidget {
  final Parque parque;
  final bool esFavorito;
  final VoidCallback onToggleFavorito;
  final VoidCallback onRegistrarVisita;
  final VoidCallback onTap;
  final double? distanciaKm;

  const ParqueCard({
    Key? key,
    required this.parque,
    required this.esFavorito,
    required this.onToggleFavorito,
    required this.onRegistrarVisita,
    required this.onTap,
    this.distanciaKm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: TiemposColores.tarjeta,
        elevation: 6,
        margin: const EdgeInsets.symmetric(horizontal: 8), // Añadido const
        shape: const RoundedRectangleBorder( // Añadido const
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18), // Añadido const
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon( // Añadido const
                    TiemposIconos.parque,
                    color: TiemposColores.textoPrincipal,
                    size: 32,
                  ),
                  const SizedBox(width: 12), // Añadido const
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          parque.nombre,
                          style: TiemposEstilos.estiloTitulo.copyWith(fontSize: 20),
                        ),
                        const SizedBox(height: 4), // Añadido const
                        Text(
                          parque.ciudad.isNotEmpty ? '${parque.ciudad}, ${parque.pais}' : parque.pais,
                          style: TiemposEstilos.estiloSubtitulo,
                        ),
                        if (parque.clima != null) ...[
                          const SizedBox(height: 4), // Añadido const
                          _ClimaWidget(clima: parque.clima!),
                        ] else if (esFavorito) ...[
                          const SizedBox(height: 4), // Añadido const
                          const _ClimaLoadingWidget(), // Añadido const
                        ],
                      ],
                    ),
                  ),
                  if (distanciaKm != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0), // Añadido const
                      child: _DistanciaWidget(distanciaKm: distanciaKm!),
                    ),
                  IconButton(
                    icon: Icon(
                      esFavorito ? Icons.favorite : Icons.favorite_border,
                      color: esFavorito ? Colors.red : Colors.grey,
                    ),
                    onPressed: onToggleFavorito,
                    tooltip: esFavorito ? 'Quitar de favoritos' : 'Añadir a favoritos',
                  ),
                ],
              ),
              const SizedBox(height: 12), // Añadido const
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: onRegistrarVisita,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TiemposColores.botonPrimario,
                    shape: const RoundedRectangleBorder( // Añadido const
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                  icon: const Icon(Icons.add_location_alt_rounded, size: 20), // Añadido const
                  label: Text(
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

// Widget optimizado para mostrar el clima
class _ClimaWidget extends StatelessWidget {
  final Clima clima;

  const _ClimaWidget({required this.clima});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CachedNetworkImage( // <--- Usando CachedNetworkImage para optimizar la carga de imágenes
              imageUrl: 'https:${clima.codigoIcono}',
              width: 24,
              height: 24,
              placeholder: (context, url) => const SizedBox( // Añadido const
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.blue,
                ),
              ),
              errorWidget: (context, url, error) => const Icon( // Añadido const
                TiemposIconos.clima,
                size: 24,
                color: Colors.yellow,
              ),
            ),
            const SizedBox(width: 8), // Añadido const
            Text(
              '${clima.temperatura.toStringAsFixed(1)}°C',
              style: TiemposEstilos.estiloSubtitulo,
            ),
            if (clima.esAntiguo) ...[
              const SizedBox(width: 4), // Añadido const
              const Icon( // Añadido const
                Icons.schedule,
                size: 16,
                color: Colors.orange,
              ),
              const SizedBox(width: 4), // Añadido const
              Text(
                'Actualizando...',
                style: TiemposEstilos.estiloSubtitulo.copyWith(
                  color: Colors.orange,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
        Text(
          clima.descripcion,
          style: TiemposEstilos.estiloSubtitulo,
        ),
      ],
    );
  }
}

// Widget optimizado para mostrar carga de clima
class _ClimaLoadingWidget extends StatelessWidget {
  const _ClimaLoadingWidget(); // Añadido const

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox( // Añadido const
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 8), // Añadido const
        Text(
          'Cargando clima...',
          style: TiemposEstilos.estiloSubtitulo.copyWith(
            color: Colors.blue,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// Widget optimizado para mostrar distancia
class _DistanciaWidget extends StatelessWidget {
  final double distanciaKm;

  const _DistanciaWidget({required this.distanciaKm}); // Añadido const

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.place, color: Colors.cyanAccent, size: 18), // Añadido const
        const SizedBox(width: 2), // Añadido const
        Text(
          '${distanciaKm.toStringAsFixed(1)} km',
          style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold), // Añadido const
        ),
      ],
    );
  }
}