import 'package:flutter/material.dart';
import '../../domain/entities/amigo.dart';

class AmigosList extends StatelessWidget {
  final List<Amigo> amigos;
  const AmigosList({Key? key, required this.amigos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: amigos.length,
      itemBuilder: (context, index) {
        final amigo = amigos[index];
        return ListTile(
          leading: const Icon(Icons.person, color: Colors.white70),
          title: Text(
            amigo.displayName.isNotEmpty ? amigo.displayName : amigo.username,
            style: const TextStyle(color: Colors.white),
          ),

        );
      },
    );
  }
}