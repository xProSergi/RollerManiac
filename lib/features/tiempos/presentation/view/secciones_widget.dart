import 'package:flutter/material.dart';
import '../../constantes/tiempos_constantes.dart';
import '../viewmodel/tiempos_viewmodel.dart';

class SeccionesWidget extends StatelessWidget {
  final String continenteSeleccionado;
  final Function(String) onContinenteChanged;
  final TiemposViewModel viewModel;

  const SeccionesWidget({
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