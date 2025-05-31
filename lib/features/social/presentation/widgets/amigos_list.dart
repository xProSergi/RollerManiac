import 'package:flutter/material.dart';
import '../../domain/entities/amigo.dart';

class AmigosList extends StatelessWidget {
  final List<Amigo> amigos;
  final Function(String amigoId) onEliminar; // NEW: Callback for removing a friend

  const AmigosList({Key? key, required this.amigos, required this.onEliminar}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: amigos.length,
      itemBuilder: (context, index) {
        final amigo = amigos[index];
        return Card( // Wrap ListTile in a Card for consistent styling if needed
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          color: Colors.blueGrey[800],
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            leading: const Icon(Icons.person, color: Colors.white70),
            title: Text(
              amigo.displayName.isNotEmpty ? amigo.displayName : amigo.username,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            trailing: IconButton( // "X" button for removing friend
              icon: const Icon(Icons.close, color: Colors.redAccent),
              onPressed: () => onEliminar(amigo.id),
              tooltip: 'Eliminar amigo',
            ),
          ),
        );
      },
    );
  }
}