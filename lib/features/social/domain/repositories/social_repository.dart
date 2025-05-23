import '../entities/amigo.dart';
import '../entities/solicitud_amistad.dart';

abstract class SocialRepository {
  Future<List<SolicitudAmistad>> obtenerSolicitudesRecibidas();
  Future<void> agregarAmigo(String username);
  Future<List<Amigo>> obtenerAmigos();
  Future<void> aceptarSolicitud({
    required String currentUserId,
    required String amigoId,
    required String amigoUserName,
    required String amigoEmail,
    required String amigoDisplayName,
  });
  Future<List<Amigo>> obtenerRanking();
}

