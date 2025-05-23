import '../../domain/entities/amigo.dart';
import '../../domain/entities/solicitud_amistad.dart';
import '../../domain/repositories/social_repository.dart';
import '../datasources/social_remote_datasource.dart';

class SocialRepositoryImpl implements SocialRepository {
  final SocialRemoteDataSource remote;

  SocialRepositoryImpl({required this.remote});

  @override
  Future<void> agregarAmigo(String username) => remote.agregarAmigo(username);

  @override
  Future<List<Amigo>> obtenerAmigos() => remote.obtenerAmigos();

  @override
  Future<List<SolicitudAmistad>> obtenerSolicitudesRecibidas() => remote.obtenerSolicitudes();

  @override
  Future<void> aceptarSolicitud({
    required String currentUserId,
    required String amigoId,
    required String amigoUserName,
    required String amigoEmail,
    required String amigoDisplayName,
  }) =>
      remote.aceptarSolicitud(
        currentUserId: currentUserId,
        amigoId: amigoId,
        amigoUserName: amigoUserName,
        amigoEmail: amigoEmail,
        amigoDisplayName: amigoDisplayName,
      );

  @override
  Future<List<Amigo>> obtenerRanking() => remote.obtenerRanking();
}
