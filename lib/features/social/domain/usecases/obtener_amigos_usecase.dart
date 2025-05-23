import '../entities/amigo.dart';
import '../repositories/social_repository.dart';

class ObtenerAmigosUseCase {
  final SocialRepository repository;

  ObtenerAmigosUseCase(this.repository);

  Future<List<Amigo>> call() => repository.obtenerAmigos();
}
