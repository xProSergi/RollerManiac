class Clima {
  final double temperatura;
  final String descripcion;
  final String codigoIcono;
  final String ciudad;
  final String ultimaActualizacion;
  final bool esAntiguo;
  final bool hasError;

  Clima({
    required this.temperatura,
    required this.descripcion,
    required this.codigoIcono,
    required this.ciudad,
    required this.ultimaActualizacion,
    this.esAntiguo = false,
    this.hasError = false,
  });

  factory Clima.error() {
    return Clima(
      temperatura: 0,
      descripcion: 'Error al cargar',
      codigoIcono: '',
      ciudad: '',
      ultimaActualizacion: '',
      hasError: true,
    );
  }

  factory Clima.fromJsonWeatherAPI(Map<String, dynamic> json) {
    final current = json['current'];
    final location = json['location'];

    return Clima(
      temperatura: current['temp_c'].toDouble(),
      descripcion: current['condition']['text'],
      codigoIcono: current['condition']['icon'],
      ciudad: location['name'],
      ultimaActualizacion: current['last_updated'],
      esAntiguo: false,
      hasError: false,
    );
  }

  Clima copyWith({bool? esAntiguo, bool? hasError}) {
    return Clima(
      temperatura: temperatura,
      descripcion: descripcion,
      codigoIcono: codigoIcono,
      ciudad: ciudad,
      ultimaActualizacion: ultimaActualizacion,
      esAntiguo: esAntiguo ?? this.esAntiguo,
      hasError: hasError ?? this.hasError,
    );
  }
}