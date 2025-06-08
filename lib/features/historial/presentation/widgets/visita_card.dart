import 'package:flutter/material.dart';
import '../../domain/entities/visita_entity.dart';
import '../../constantes/historial_constantes.dart';

class VisitaCard extends StatelessWidget {
  final VisitaEntity visita;

  const VisitaCard({
    Key? key,
    required this.visita,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dia = visita.fecha.day.toString().padLeft(2, '0');
    final mes = visita.fecha.month.toString().padLeft(2, '0');
    final anio = visita.fecha.year.toString();
    final fechaFormateada = '$dia/$mes/$anio';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: HistorialConstantes.colorSuperficie,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          visita.atraccionNombre ?? visita.parqueNombre,
          style: HistorialConstantes.estiloTitulo,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (visita.atraccionNombre != null)
              Text(
                visita.parqueNombre,
                style: HistorialConstantes.estiloSubtitulo,
              ),
            const SizedBox(height: 4),
            Text(
              fechaFormateada,
              style: HistorialConstantes.estiloFecha,
            ),
          ],
        ),
        leading: CircleAvatar(
          backgroundColor: HistorialConstantes.colorAccento,
          child: Icon(
            visita.atraccionNombre != null
                ? Icons.attractions
                : Icons.park,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}