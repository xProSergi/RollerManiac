import 'dart:math';

String obtenerContinente(String pais) {
  const mapa = {
    'Spain': 'Europa',
    'France': 'Europa',
    'Germany': 'Europa',
    'Italy': 'Europa',
    'United Kingdom': 'Europa',
    'Portugal': 'Europa',
    'Netherlands': 'Europa',
    'Belgium': 'Europa',
    'Switzerland': 'Europa',
    'Austria': 'Europa',
    'England': 'Europa',
    'Denmark': 'Europa',
    'Poland': 'Europa',
    'Sweden': 'Europa',
    'United States': 'América',
    'Canada': 'América',
    'Mexico': 'América',
    'Brazil': 'América',
    'Argentina': 'América',
    'Chile': 'América',
    'Japan': 'Asia',
    'China': 'Asia',
    'Hong Kong': 'Asia',
    'South Korea': 'Asia',
    'India': 'Asia',
    'Australia': 'Oceanía',
    'New Zealand': 'Oceanía',
    'South Africa': 'África',
    'Egypt': 'África',
    // Añade más países según lo necesites
  };
  return mapa[pais] ?? 'Otro';
}

double calcularDistancia(double lat1, double lon1, double lat2, double lon2) {
  const R = 6371;
  final dLat = _gradosARadianes(lat2 - lat1);
  final dLon = _gradosARadianes(lon2 - lon1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_gradosARadianes(lat1)) * cos(_gradosARadianes(lat2)) *
          sin(dLon / 2) * sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return R * c;
}

double _gradosARadianes(double grados) {
  return grados * pi / 180;
}
