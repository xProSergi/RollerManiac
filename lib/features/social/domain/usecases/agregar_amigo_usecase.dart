import '../repositories/social_repository.dart';

class AgregarAmigoUseCase {
  final SocialRepository repository;

  AgregarAmigoUseCase(this.repository);

  Future<void> call(String username) {
    return repository.agregarAmigo(username.toLowerCase());
  }
}
