import '../entities/parque.dart';
import '../entities/atraccion.dart';

abstract class ParquesRepository {
  Future<List<Parque>> obtenerParques();
  Future<List<Atraccion>> obtenerAtraccionesDeParque(String parqueId);
}
