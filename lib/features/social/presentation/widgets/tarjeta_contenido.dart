import 'package:flutter/material.dart';

class TarjetaContenido extends StatelessWidget {
  final Color cardColor;
  final Widget child;
  final EdgeInsetsGeometry margin;

  const TarjetaContenido({
    Key? key,
    required this.cardColor,
    required this.child,
    this.margin = const EdgeInsets.only(top: 10),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      // Removed the internal padding from TarjetaContenido's Container
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding( // Added Padding directly around the child
        padding: const EdgeInsets.all(16), // This padding defines the internal space
        child: child,
      ),
    );
  }
}