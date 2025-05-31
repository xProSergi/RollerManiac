import 'package:flutter/material.dart';
import '../../domain/entities/amigo.dart';

class RankingList extends StatelessWidget {
  final List<Amigo> ranking;
  const RankingList({Key? key, required this.ranking}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: ranking.length,
      itemBuilder: (context, index) {
        final amigo = ranking[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blueGrey[700],
            child: Text(
              '${index + 1}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(
            amigo.displayName.isNotEmpty ? amigo.displayName : amigo.username,
            style: const TextStyle(color: Colors.white),
          ),
          trailing: Text(
            '${amigo.cantidadParques} visitas a parques',
            style: const TextStyle(color: Colors.white70),
          ),
        );
      },
    );
  }
}