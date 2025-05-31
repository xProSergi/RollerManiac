import 'package:flutter/material.dart';

class TarjetaContenido extends StatelessWidget {
  final Color cardColor;
  final Widget child;
  final EdgeInsetsGeometry margin; // Make margin customizable

  const TarjetaContenido({
    Key? key,
    required this.cardColor,
    required this.child,
    this.margin = const EdgeInsets.only(top: 10), // Default margin
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: cardColor, // Use cardColor directly
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Consistent internal padding
        child: child,
      ),
    );
  }
}