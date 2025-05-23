import '../entities/amigo.dart';
import '../repositories/social_repository.dart';

class ObtenerRankingUseCase {
  final SocialRepository repository;

  ObtenerRankingUseCase(this.repository);

  Future<List<Amigo>> call() => repository.obtenerRanking();
}
