import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../domain/entities/clima.dart';
import '../../domain/entities/parque.dart';
import '../viewmodel/tiempos_viewmodel.dart';
import '../../constantes/tiempos_constantes.dart';
import '../../utils/parque_utils.dart';
import 'detalles_parque_screen.dart';

class ListaParquesWidget extends StatelessWidget {
  final TiemposViewModel viewModel;
  final List<Parque> parques;
  final ScrollController scrollController;
  final ValueNotifier<bool> showScrollToTop;
  final VoidCallback onScrollToTop;
  final Future<void> Function(BuildContext, String, String) onRegistrarVisita;
  final bool isNavigating;
  final Function(bool) onNavigatingChanged;
  final bool cargando; // Añadido para mostrar el estado de carga
  final String? error; // Añadido para mostrar mensajes de error

  const ListaParquesWidget({
    Key? key,
    required this.viewModel,
    required this.parques,
    required this.scrollController,
    required this.showScrollToTop,
    required this.onScrollToTop,
    required this.onRegistrarVisita,
    required this.isNavigating,
    required this.onNavigatingChanged,
    required this.cargando, // Requerido
    this.error, // Opcional
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        cargando
            ? const Center(child: CircularProgressIndicator(color: TiemposColores.textoPrincipal))
            : error != null
            ? Center(
          child: Text(
            '${TiemposTextos.errorCargar}: $error',
            style: const TextStyle(color: TiemposColores.error),
          ),
        )
            : parques.isEmpty
            ? Center(
          child: Text(
            cargando // Usar la bandera de carga pasada
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
          itemCount: parques.length,
          addAutomaticKeepAlives: false, // Mejor rendimiento para listas muy largas
          addRepaintBoundaries: false, // Mejor rendimiento para listas muy largas
          itemBuilder: (context, index) {
            final parque = parques[index];
            // Asegurarse de obtener el parque con clima del ViewModel si existe
            final parqueConClima = viewModel.getParqueConClima(parque.id) ?? parque;
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
                  // Cargar el clima solo si el parque es favorito, es visible y necesita ser actualizado
                  if (info.visibleFraction > 0.1 && viewModel.esFavorito(parque.id)) {
                    if (viewModel.necesitaCargarClima(parque.id)) { // Usar ID en lugar de nombre si el VM lo soporta
                      viewModel.cargarClimaParaParque(
                        parque.id, // Pasar el ID del parque
                        parque.nombre,
                        parque.latitud,
                        parque.longitud,
                        parque.pais,
                      );
                    }
                  }
                },
                child: ParqueCard(
                  parque: parqueConClima, // Usar parqueConClima para el widget
                  esFavorito: viewModel.esFavorito(parque.id),
                  onToggleFavorito: () => viewModel.toggleFavorito(parque.id),
                  onTap: () async {
                    if (isNavigating) return;
                    onNavigatingChanged(true);
                    try {
                      final atracciones = await viewModel.cargarAtracciones(parque.id);
                      final parqueParaDetalles = Parque(
                        id: parque.id,
                        nombre: parque.nombre,
                        pais: parque.pais,
                        ciudad: parque.ciudad,
                        latitud: parque.latitud,
                        longitud: parque.longitud,
                        continente: parque.continente,
                        atracciones: atracciones,
                        clima: parqueConClima.clima, // Asegurarse de pasar el clima actual
                      );
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetallesParqueScreen(parque: parqueParaDetalles),
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
        if (viewModel.cargandoMas)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      viewModel.hayMasParques
                          ? 'Cargando más parques...'
                          : 'No hay más parques',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
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
    // Escuchar cambios en el ViewModel solo para la lógica de forzar actualización de clima
    // y no para la reconstrucción de toda la tarjeta.
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
                        // Usa Selector aquí para que solo el clima widget se reconstruya cuando el clima cambie
                        Selector<TiemposViewModel, Clima?>(
                          selector: (_, vm) => vm.getParqueConClima(parque.id)?.clima,
                          builder: (context, climaActualizado, __) {
                            if (climaActualizado != null) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 2),
                                  _ClimaWidget(clima: climaActualizado),
                                ],
                              );
                            } else if (esFavorito) {
                              return const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 2),
                                  _ClimaLoadingWidget(),
                                ],
                              );
                            }
                            return const SizedBox.shrink(); // No mostrar nada si no hay clima y no es favorito
                          },
                        ),
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
              // El botón de actualizar clima solo se mostrará si el clima está obsoleto o con error
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

class ListaParquesConScroll extends StatefulWidget {
  final TiemposViewModel viewModel;
  final ValueNotifier<bool> showScrollToTop;
  final VoidCallback onScrollToTop;
  final Future<void> Function(BuildContext, String, String) onRegistrarVisita;
  final bool isNavigating;
  final Function(bool) onNavigatingChanged;

  const ListaParquesConScroll({
    Key? key,
    required this.viewModel,
    required this.showScrollToTop,
    required this.onScrollToTop,
    required this.onRegistrarVisita,
    required this.isNavigating,
    required this.onNavigatingChanged,
  }) : super(key: key);

  @override
  State<ListaParquesConScroll> createState() => _ListaParquesConScrollState();
}

class _ListaParquesConScrollState extends State<ListaParquesConScroll> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
          widget.viewModel.cargarMasParques();
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return; // 🔒 Seguridad: evita usar el controller si el widget ya no existe

          if (_scrollController.offset > 300 &&
              widget.showScrollToTop.value == false) {
            widget.showScrollToTop.value = true;
          } else if (_scrollController.offset <= 300 &&
              widget.showScrollToTop.value == true) {
            widget.showScrollToTop.value = false;
          }
        });
      });

  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListaParquesWidget(
      viewModel: widget.viewModel,
      parques: widget.viewModel.parques,
      scrollController: _scrollController,
      showScrollToTop: widget.showScrollToTop,
      onScrollToTop: widget.onScrollToTop,
      onRegistrarVisita: widget.onRegistrarVisita,
      isNavigating: widget.isNavigating,
      onNavigatingChanged: widget.onNavigatingChanged,
      cargando: widget.viewModel.cargando,
      error: widget.viewModel.error,
    );
  }
}