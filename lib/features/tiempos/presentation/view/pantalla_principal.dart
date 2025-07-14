import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
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
import '../../../historial/data/datasources/historial_remote_datasource.dart';
import '../../../historial/domain/usecases/obtener_visitas_usecase.dart';
import '../../../historial/domain/usecases/obtener_visitas_por_parque_usecase.dart';
import '../../../../compartido/widgets/nav_bar.dart';
import '../../../../services/firebase_service.dart';
import '../../constantes/tiempos_constantes.dart';
import '../../utils/parque_utils.dart';
import 'package:geolocator/geolocator.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter/rendering.dart';

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

  // Usamos ValueNotifier para evitar rebuilds globales
  final ValueNotifier<bool> _showScrollToTop = ValueNotifier(false);
  final ValueNotifier<bool> _showSections = ValueNotifier(true);

  // Variables para optimizar el scroll
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
    _showScrollToTop.dispose();
    _showSections.dispose();
    super.dispose();
  }

  void _onScroll() {
    final now = DateTime.now();

    // Throttling: solo ejecutar cada 50ms
    if (now.difference(_lastScrollTime).inMilliseconds < 50) {
      return;
    }
    _lastScrollTime = now;

    final offset = _scrollController.offset;
    final shouldShowSections = offset < 100;

    // Solo notificamos si cambia el valor
    if (_showScrollToTop.value != (offset > 200)) {
      _showScrollToTop.value = offset > 200;
    }
    if (_showSections.value != shouldShowSections) {
      _showSections.value = shouldShowSections;
    }

    // Cargar más parques si es necesario
    if (!_isLoadingMore && _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final viewModel = Provider.of<TiemposViewModel>(context, listen: false);
      if (viewModel.hayMasParques && !viewModel.cargandoMas) {
        _isLoadingMore = true;
        viewModel.cargarMasParques().then((_) {
          _isLoadingMore = false;
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
            // Campo de búsqueda
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
            // Secciones que se ocultan al hacer scroll
            ValueListenableBuilder<bool>(
              valueListenable: _showSections,
              builder: (context, show, _) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: show ? null : 0,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: show ? 1.0 : 0.0,
                    child: _SeccionesWidget(
                      continenteSeleccionado: _continenteSeleccionado,
                      onContinenteChanged: (cont) {
                        setState(() => _continenteSeleccionado = cont);
                        viewModel.cambiarContinente(cont);
                      },
                      viewModel: viewModel,
                    ),
                  ),
                );
              },
            ),
            // Lista de parques
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
        // Sección de continentes compacta
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
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: continenteSeleccionado == cont
                              ? TiemposColores.chipSeleccionTexto
                              : TiemposColores.textoSecundario,
                        ),
                      ),
                      selected: continenteSeleccionado == cont,
                      onSelected: (_) => onContinenteChanged(cont),
                      selectedColor: TiemposColores.chipSeleccion,
                      backgroundColor: Colors.white10,
                      labelStyle: TextStyle(
                        color: continenteSeleccionado == cont
                            ? TiemposColores.chipSeleccionTexto
                            : TiemposColores.textoSecundario,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      elevation: continenteSeleccionado == cont ? 4 : 0,
                      shadowColor: TiemposColores.chipSeleccion.withOpacity(0.2),
                    ),
                  )).toList(),
                ),
              ),
            ],
          ),
        ),
        // Sección de orden compacta
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
  final ValueNotifier<bool> showScrollToTop;
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
            style: const TextStyle(color: TiemposColores.error),
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
            style: TextStyle(color: TiemposColores.textoSecundario),
          ),
        )
            : ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: parques.length + (viewModel.hayMasParques ? 1 : 0),
          // Optimizaciones de rendimiento
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: false,
          itemBuilder: (context, index) {
            // Si es el último item y hay más parques, mostrar indicador de carga
            if (index == parques.length && viewModel.hayMasParques) {
              return Container(
                padding: const EdgeInsets.all(20),
                child: const Center(
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
            // Obtener el parque con clima actualizado
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

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: VisibilityDetector(
                key: Key('parque_${parque.id}'),
                onVisibilityChanged: (info) {
                  // Solo cargar clima si es favorito y está visible
                  if (info.visibleFraction > 0.1 && viewModel.esFavorito(parque.id)) {
                    // Solo cargar clima si es necesario (favorito y sin clima)
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
                  parque: parqueConClima, // Usar el parque con clima actualizado
                  esFavorito: viewModel.esFavorito(parque.id),
                  onToggleFavorito: () => viewModel.toggleFavorito(parque.id),
                  onTap: () async {
                    if (isNavigating) return;
                    onNavigatingChanged(true);
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
                        clima: parqueConClima.clima, // Usar el clima actualizado
                      );
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetallesParqueScreen(parque: parqueConAtracciones),
                        ),
                      );
                    } finally {
                      onNavigatingChanged(false);
                    }
                  },
                  onRegistrarVisita: () => onRegistrarVisita(context, parque.id.toString(), parque.nombre),
                  distanciaKm: distanciaKm,
                ),
              ),
            );
          },
        ),
        // Botón de scroll to top
        ValueListenableBuilder<bool>(
          valueListenable: showScrollToTop,
          builder: (context, show, _) {
            return show
                ? Positioned(
              bottom: 100,
              left: 20,
              child: FloatingActionButton(
                onPressed: onScrollToTop,
                backgroundColor: TiemposColores.botonPrimario,
                child: const Icon(
                  Icons.keyboard_arrow_up,
                  color: Colors.white,
                  size: 28,
                ),
                mini: true,
              ),
            )
                : const SizedBox.shrink();
          },
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
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        boxShadow: selected
            ? [
          BoxShadow(
            color: TiemposColores.chipSeleccion.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ]
            : null,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: selected ? TiemposColores.chipSeleccion : Colors.white10,
          foregroundColor: selected ? TiemposColores.chipSeleccionTexto : TiemposColores.textoSecundario,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          elevation: selected ? 2 : 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            color: selected ? TiemposColores.chipSeleccionTexto : TiemposColores.textoSecundario,
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
    final viewModel = Provider.of<TiemposViewModel>(context, listen: false);
    final clima = parque.clima;
    final bool mostrarBotonActualizar = clima != null && (clima.esAntiguo || clima.descripcion == 'Error al cargar');
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: TiemposColores.tarjeta,
        elevation: 6,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      TiemposIconos.parque,
                      color: TiemposColores.textoPrincipal,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                parque.nombre,
                                style: TiemposEstilos.estiloTitulo.copyWith(fontSize: 18),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (distanciaKm != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 6.0),
                                child: _DistanciaWidget(distanciaKm: distanciaKm!),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          parque.ciudad.isNotEmpty ? '${parque.ciudad}, ${parque.pais}' : parque.pais,
                          style: TiemposEstilos.estiloSubtitulo.copyWith(fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (parque.clima != null) ...[
                          const SizedBox(height: 2),
                          _ClimaWidget(clima: parque.clima!),
                        ] else if (esFavorito) ...[
                          const SizedBox(height: 2),
                          const _ClimaLoadingWidget(),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      esFavorito ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: esFavorito ? Colors.redAccent : Colors.grey,
                      size: 26,
                    ),
                    onPressed: onToggleFavorito,
                    tooltip: esFavorito ? 'Quitar de favoritos' : 'Añadir a favoritos',
                  ),
                ],
              ),
              if (mostrarBotonActualizar)
                Padding(
                  padding: const EdgeInsets.only(top: 6.0, bottom: 2.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: TiemposColores.info,
                        side: const BorderSide(color: TiemposColores.info, width: 1),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Actualizar clima'),
                      onPressed: () async {
                        await viewModel.forzarActualizarClima(parque.id);
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: onRegistrarVisita,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TiemposColores.botonPrimario,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.add_location_alt_rounded, size: 18),
                  label: Text(
                    TiemposTextos.registrarVisita,
                    style: TiemposEstilos.estiloBotonPrimario.copyWith(fontSize: 13),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.network(
            'https:${clima.codigoIcono}',
            width: 22,
            height: 22,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(
              TiemposIconos.clima,
              size: 20,
              color: Colors.yellow,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '${clima.temperatura.toStringAsFixed(1)}°C',
          style: TiemposEstilos.estiloSubtitulo.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        if (clima.esAntiguo) ...[
          const SizedBox(width: 4),
          const Icon(
            Icons.schedule,
            size: 14,
            color: Colors.orange,
          ),
          const SizedBox(width: 2),
          Text(
            'Actualizando',
            style: TiemposEstilos.estiloSubtitulo.copyWith(
              color: Colors.orange,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            clima.descripcion,
            style: TiemposEstilos.estiloSubtitulo.copyWith(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// Widget optimizado para mostrar carga de clima
class _ClimaLoadingWidget extends StatelessWidget {
  const _ClimaLoadingWidget();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'Cargando clima...',
          style: TiemposEstilos.estiloSubtitulo.copyWith(
            color: Colors.blue,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Widget optimizado para mostrar distancia
class _DistanciaWidget extends StatelessWidget {
  final double distanciaKm;

  const _DistanciaWidget({required this.distanciaKm});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.place, color: Colors.cyanAccent, size: 18),
        const SizedBox(width: 2),
        Text(
          '${distanciaKm.toStringAsFixed(1)} km',
          style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}