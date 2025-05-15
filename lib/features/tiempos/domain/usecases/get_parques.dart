
import '../repositories/parques_repository.dart';
import '../entities/parque.dart';

class GetParques {
  final ParquesRepository repository;

  GetParques(this.repository);

  Future<List<Parque>> call() {
    return repository.obtenerParques();
  }
}
