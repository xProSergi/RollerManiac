class Clima {
  final double temperatura;
  final String descripcion;
  final String codigoIcono;
  final String ciudad;
  final String ultimaActualizacion;

  Clima({
    required this.temperatura,
    required this.descripcion,
    required this.codigoIcono,
    required this.ciudad,
    required this.ultimaActualizacion,
  });

  factory Clima.fromJsonWeatherAPI(Map<String, dynamic> json) {
    final current = json['current'];
    final location = json['location'];

    return Clima(
      temperatura: current['temp_c'].toDouble(),
      descripcion: current['condition']['text'],
      codigoIcono: current['condition']['icon'],
      ciudad: location['name'],
      ultimaActualizacion: current['last_updated'],
    );
  }
}