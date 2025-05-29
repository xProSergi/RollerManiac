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
                    // Widget AgregarAmigo
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
    return Card(
      elevation: 4,
      color: SocialColores.tarjeta.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
                  content: Text('${SocialTextos.errorEnvioSolicitud} ${e.toString().split(':').last.trim()}'),
                  backgroundColor: Colors.redAccent,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildErrorMessage(SocialViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
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
                ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                SocialTextos.sinSolicitudes,
                style: SocialTextStyles.emailUsuario,
                textAlign: TextAlign.center,
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
              child: Text(
                SocialTextos.sinAmigos,
                style: SocialTextStyles.emailUsuario,
                textAlign: TextAlign.center,
              ),
            )
                : SizedBox(
              width: double.infinity,
              child: AmigosList(amigos: viewModel.amigos),
            ),
          ),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildSeccionRanking(SocialViewModel viewModel) {
    return Card(
      elevation: 4,
      color: SocialColores.tarjeta.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
      ),
    );
  }
}