import 'package:flutter/material.dart';

class AgregarAmigo extends StatefulWidget {
  final TextEditingController controller;
  final Color accentColor;
  final Color cardColor;
  final Color textColor;
  final Color lightTextColor;
  final Function(String username) onAgregarAmigo;

  const AgregarAmigo({
    Key? key,
    required this.controller,
    required this.accentColor,
    required this.cardColor,
    required this.textColor,
    required this.lightTextColor,
    required this.onAgregarAmigo,
  }) : super(key: key);

  @override
  State<AgregarAmigo> createState() => _AgregarAmigoState();
}

class _AgregarAmigoState extends State<AgregarAmigo> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      style: TextStyle(color: widget.textColor),
      decoration: InputDecoration(
        filled: true,
        fillColor: widget.cardColor,
        labelText: 'Agregar amigo (username)',
        labelStyle: TextStyle(color: widget.lightTextColor),
        hintText: 'Introduce el nombre de usuario',
        hintStyle: TextStyle(color: widget.lightTextColor.withOpacity(0.7), fontStyle: FontStyle.italic),
        suffixIcon: _isLoading
            ? Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(widget.accentColor),
          ),
        )
            : IconButton(
          icon: Icon(Icons.person_add, color: widget.accentColor),
          onPressed: () async {
            final username = widget.controller.text.trim().toLowerCase();
            if (username.isNotEmpty) {
              setState(() {
                _isLoading = true;
              });
              try {
                await widget.onAgregarAmigo(username);
              } finally {
                setState(() {
                  _isLoading = false;
                });
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Por favor, introduce un nombre de usuario válido.'),
                  backgroundColor: Colors.orangeAccent,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white24),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: widget.accentColor, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}