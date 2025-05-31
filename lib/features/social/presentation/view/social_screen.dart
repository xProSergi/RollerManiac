import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../viewmodel/social_viewmodel.dart';
import '../widgets/amigos_list.dart';
import '../widgets/ranking_list.dart';
import '../widgets/solicitudes_list.dart';
import '../widgets/agregar_amigo.dart';
import '../widgets/seccion_plegable.dart';
import '../widgets/tarjeta_contenido.dart';
import '../../constantes/social_constantes.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({Key? key}) : super(key: key);

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  final TextEditingController usernameController = TextEditingController();
  bool solicitudesExpanded = false;
  bool amigosExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<SocialViewModel>(context, listen: false);
      viewModel.cargarSolicitudes();
      viewModel.cargarAmigos();
      viewModel.cargarRanking();
    });
  }

  @override
  void dispose() {
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: SocialColores.gradienteFondo,
        ),
        child: Consumer<SocialViewModel>(
          builder: (context, viewModel, _) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width,
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildAgregarAmigoCard(viewModel),

                    if (viewModel.errorMessage.isNotEmpty) _buildErrorMessage(viewModel),

                    const SizedBox(height: 20),
                    _buildSeccionSolicitudes(viewModel),
                    const SizedBox(height: 20),
                    _buildSeccionAmigos(viewModel),
                    const SizedBox(height: 20),
                    _buildSeccionRanking(viewModel),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAgregarAmigoCard(SocialViewModel viewModel) {
    return TarjetaContenido(
      cardColor: SocialColores.tarjeta.withOpacity(0.9),
      margin: EdgeInsets.zero,
      child: AgregarAmigo(
        controller: usernameController,
        accentColor: SocialColores.boton,
        cardColor: Colors.transparent,
        textColor: SocialColores.textoClaro,
        lightTextColor: SocialColores.textoSecundario,
        onAgregarAmigo: (username) async {
          try {
            await viewModel.agregarAmigoPorUsername(username); // This will now throw if already friends/pending
            usernameController.clear();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${SocialTextos.solicitudEnviada} $username!'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
            viewModel.errorMessage = '';
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${SocialTextos.errorEnvioSolicitud} ${e.toString().replaceFirst('Exception: ', '').trim()}'),
                backgroundColor: Colors.redAccent,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildErrorMessage(SocialViewModel viewModel) {
    return TarjetaContenido(
      cardColor: SocialColores.tarjeta.withOpacity(0.9),
      margin: const EdgeInsets.only(top: 12.0),
      child: Text(
        viewModel.errorMessage,
        style: SocialTextStyles.textoError.copyWith(
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 2,
              offset: const Offset(1, 1),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSeccionSolicitudes(SocialViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SeccionPlegable(
          titulo: SocialTextos.tituloSolicitudes,
          estaExpandida: solicitudesExpanded,
          onTap: () => setState(() => solicitudesExpanded = !solicitudesExpanded),
          cardColor: SocialColores.tarjeta.withOpacity(0.9),
          estiloTituloSeccion: SocialTextStyles.tituloSeccion,
          colorTextoClaro: SocialColores.textoSecundario,
          widgetFinal: viewModel.solicitudes.isNotEmpty
              ? CircleAvatar(
            radius: 12,
            backgroundColor: SocialColores.boton,
            child: Text(
              '${viewModel.solicitudes.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
              : null,
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: solicitudesExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: TarjetaContenido(
            cardColor: SocialColores.tarjeta.withOpacity(0.85),
            child: viewModel.solicitudes.isEmpty
                ? SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  SocialTextos.sinSolicitudes,
                  style: SocialTextStyles.emailUsuario,
                  textAlign: TextAlign.center,
                ),
              ),
            )
                : SizedBox(
              width: double.infinity,
              child: SolicitudesList(
                solicitudes: viewModel.solicitudes,
                onAceptar: (solicitudId) {
                  final solicitud = viewModel.solicitudes.firstWhere((s) => s.id == solicitudId);
                  final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
                  viewModel.aceptarSolicitud(
                    currentUserId: currentUserId,
                    amigoId: solicitud.id,
                    amigoUserName: solicitud.username,
                    amigoEmail: solicitud.email,
                    amigoDisplayName: solicitud.displayName,
                  );
                },
                onRechazar: (solicitudId) async {
                  // --- NEW: Show confirmation dialog for rejecting request ---
                  final bool? confirmReject = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        backgroundColor: SocialColores.tarjeta, // Use your app's card color
                        title: Text(
                          'Rechazar Solicitud',
                          style: SocialTextStyles.tituloSeccion.copyWith(color: SocialColores.textoClaro),
                        ),
                        content: Text(
                          '¿Estás seguro de que quieres rechazar esta solicitud de amistad?',
                          style: SocialTextStyles.emailUsuario.copyWith(color: SocialColores.textoSecundario),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text(
                              'Cancelar',
                              style: SocialTextStyles.textoBoton.copyWith(color: SocialColores.textoSecundario),
                            ),
                            onPressed: () {
                              Navigator.of(dialogContext).pop(false); // Dismiss dialog and return false
                            },
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent, // A distinct color for destructive action
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Rechazar', style: TextStyle(fontSize: 14)),
                            onPressed: () {
                              Navigator.of(dialogContext).pop(true); // Dismiss dialog and return true
                            },
                          ),
                        ],
                      );
                    },
                  );

                  if (confirmReject == true) {
                    try {
                      await viewModel.rechazarSolicitud(solicitudId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Solicitud rechazada.'),
                          backgroundColor: Colors.orange,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al rechazar solicitud: ${e.toString().replaceFirst('Exception: ', '').trim()}'),
                          backgroundColor: Colors.redAccent,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  }
                },
              ),
            ),
          ),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildSeccionAmigos(SocialViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SeccionPlegable(
          titulo: SocialTextos.tituloAmigos,
          estaExpandida: amigosExpanded,
          onTap: () => setState(() => amigosExpanded = !amigosExpanded),
          cardColor: SocialColores.tarjeta.withOpacity(0.9),
          estiloTituloSeccion: SocialTextStyles.tituloSeccion,
          colorTextoClaro: SocialColores.textoSecundario,
          widgetFinal: Text(
            '${viewModel.amigos.length}',
            style: SocialTextStyles.emailUsuario.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: amigosExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: TarjetaContenido(
            cardColor: SocialColores.tarjeta.withOpacity(0.85),
            child: viewModel.amigos.isEmpty
                ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              // --- FIX: Wrap Text with Center widget ---
              child: Center(
                child: Text(
                  SocialTextos.sinAmigos,
                  style: SocialTextStyles.emailUsuario,
                  textAlign: TextAlign.center, // This is already good for internal text alignment
                ),
              ),
            )
                : SizedBox(
              width: double.infinity,
              child: AmigosList(
                amigos: viewModel.amigos,
                onEliminar: (amigoId) async {
                  // --- NEW: Show confirmation dialog ---
                  final bool? confirmDelete = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        backgroundColor: SocialColores.tarjeta, // Use your app's card color
                        title: Text(
                          'Eliminar Amigo',
                          style: SocialTextStyles.tituloSeccion.copyWith(color: SocialColores.textoClaro),
                        ),
                        content: Text(
                          '¿Estás seguro de que quieres eliminar a este amigo?',
                          style: SocialTextStyles.emailUsuario.copyWith(color: SocialColores.textoSecundario),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text(
                              'Cancelar',
                              style: SocialTextStyles.textoBoton.copyWith(color: SocialColores.textoSecundario),
                            ),
                            onPressed: () {
                              Navigator.of(dialogContext).pop(false); // Dismiss dialog and return false
                            },
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent, // A distinct color for destructive action
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Eliminar', style: TextStyle(fontSize: 14)),
                            onPressed: () {
                              Navigator.of(dialogContext).pop(true); // Dismiss dialog and return true
                            },
                          ),
                        ],
                      );
                    },
                  );

                  if (confirmDelete == true) {
                    try {
                      await viewModel.eliminarAmigo(amigoId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Amigo eliminado correctamente.'),
                          backgroundColor: Colors.orange,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al eliminar amigo: ${e.toString().replaceFirst('Exception: ', '').trim()}'),
                          backgroundColor: Colors.redAccent,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  }
                },
              ),
            ),
          ),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildSeccionRanking(SocialViewModel viewModel) {
    return TarjetaContenido(
      cardColor: SocialColores.tarjeta.withOpacity(0.9),
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            SocialTextos.tituloRanking,
            style: SocialTextStyles.tituloSeccion,
          ),
          const SizedBox(height: 10),
          viewModel.ranking.isEmpty
              ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              SocialTextos.sinRanking,
              style: SocialTextStyles.emailUsuario,
              textAlign: TextAlign.center,
            ),
          )
              : SizedBox(
            width: double.infinity,
            child: RankingList(ranking: viewModel.ranking),
          ),
        ],
      ),
    );
  }
}