import 'package:flutter/material.dart';

class SeccionPlegable extends StatelessWidget {
  final String titulo;
  final bool estaExpandida;
  final VoidCallback onTap;
  final Color cardColor;
  final TextStyle estiloTituloSeccion;
  final Color colorTextoClaro;
  final Widget? widgetFinal;

  const SeccionPlegable({
    Key? key,
    required this.titulo,
    required this.estaExpandida,
    required this.onTap,
    required this.cardColor,
    required this.estiloTituloSeccion,
    required this.colorTextoClaro,
    this.widgetFinal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(titulo, style: estiloTituloSeccion),
            Row(
              children: [
                if (widgetFinal != null) widgetFinal!,
                const SizedBox(width: 8),
                Icon(
                  estaExpandida ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: colorTextoClaro,
                  size: 28,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}