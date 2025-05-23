import '../entities/solicitud_amistad.dart';
import '../repositories/social_repository.dart';

class ObtenerSolicitudesRecibidasUseCase {
  final SocialRepository repository;

  ObtenerSolicitudesRecibidasUseCase(this.repository);

  Future<List<SolicitudAmistad>> call() {
    return repository.obtenerSolicitudesRecibidas();
  }
}
