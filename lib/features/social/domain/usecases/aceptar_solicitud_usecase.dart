import '../repositories/social_repository.dart';

class AceptarSolicitudUseCase {
  final SocialRepository repository;

  AceptarSolicitudUseCase(this.repository);

  Future<void> call({
    required String currentUserId,
    required String amigoId,
    required String amigoUserName,
    required String amigoEmail,
    required String amigoDisplayName,
  }) {
    return repository.aceptarSolicitud(
      currentUserId: currentUserId,
      amigoId: amigoId,
      amigoUserName: amigoUserName,
      amigoEmail: amigoEmail,
      amigoDisplayName: amigoDisplayName,
    );
  }
}
