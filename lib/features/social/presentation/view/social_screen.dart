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
      cardColor: SocialColores.tarjeta.withAlpha(230),
      margin: EdgeInsets.zero,
      child: AgregarAmigo(
        controller: usernameController,
        accentColor: SocialColores.boton,
        cardColor: Colors.transparent,
        textColor: SocialColores.textoClaro,
        lightTextColor: SocialColores.textoSecundario,
        onAgregarAmigo: (username) async {
          try {
            await viewModel.agregarAmigoPorUsername(username);
            usernameController.clear();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${SocialTextos.solicitudEnviada} $username!'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
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

  Widget _buildSeccionSolicitudes(SocialViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SeccionPlegable(
          titulo: SocialTextos.tituloSolicitudes,
          estaExpandida: solicitudesExpanded,
          onTap: () => setState(() => solicitudesExpanded = !solicitudesExpanded),
          cardColor: SocialColores.tarjeta.withAlpha(230),
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
            cardColor: SocialColores.tarjeta.withAlpha(217),
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
                        backgroundColor: SocialColores.tarjeta,
                        title: Text(
                          SocialTextos.tituloRechazarSolicitud,
                          style: SocialTextStyles.tituloSeccion.copyWith(color: SocialColores.textoClaro),
                        ),
                        content: Text(
                          SocialTextos.mensajeRechazarSolicitud,
                          style: SocialTextStyles.emailUsuario.copyWith(color: SocialColores.textoSecundario),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text(
                              SocialTextos.botonCancelar,
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
                            child: Text(SocialTextos.botonRechazar, style: const TextStyle(fontSize: 14)),
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
                          content: Text(SocialTextos.solicitudRechazada),
                          backgroundColor: Colors.orange,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${SocialTextos.errorRechazarSolicitud} ${e.toString().replaceFirst('Exception: ', '').trim()}'),
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
          cardColor: SocialColores.tarjeta.withAlpha(230),
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
            cardColor: SocialColores.tarjeta.withAlpha(217),
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
                        backgroundColor: SocialColores.tarjeta,
                        title: Text(
                          SocialTextos.tituloEliminarAmigo,
                          style: SocialTextStyles.tituloSeccion.copyWith(color: SocialColores.textoClaro),
                        ),
                        content: Text(
                          SocialTextos.mensajeEliminarAmigo,
                          style: SocialTextStyles.emailUsuario.copyWith(color: SocialColores.textoSecundario),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text(
                              SocialTextos.botonCancelar,
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
                            child: Text(SocialTextos.botonEliminar, style: const TextStyle(fontSize: 14)),
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
                          content: Text(SocialTextos.amigoEliminado),
                          backgroundColor: Colors.orange,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${SocialTextos.errorEliminarAmigo} ${e.toString().replaceFirst('Exception: ', '').trim()}'),
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
      cardColor: SocialColores.tarjeta.withAlpha(230),
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