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

  bool solicitudesExpanded = true;
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
      backgroundColor: SocialColores.fondo,
      body: Consumer<SocialViewModel>(
        builder: (context, viewModel, _) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AgregarAmigo(
                    controller: usernameController,
                    accentColor: SocialColores.boton,
                    cardColor: SocialColores.tarjeta,
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
                  if (viewModel.errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Text(
                        viewModel.errorMessage,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 30),

                  // Solicitudes
                  SeccionPlegable(
                    titulo: SocialTextos.tituloSolicitudes,
                    estaExpandida: solicitudesExpanded,
                    onTap: () {
                      setState(() {
                        solicitudesExpanded = !solicitudesExpanded;
                      });
                    },
                    cardColor: SocialColores.tarjeta,
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
                      cardColor: SocialColores.tarjeta,
                      child: viewModel.solicitudes.isEmpty
                          ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          SocialTextos.sinSolicitudes,
                          style: SocialTextStyles.emailUsuario,
                          textAlign: TextAlign.center,
                        ),
                      )
                          : SolicitudesList(
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
                    secondChild: const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 20),

                  //  Amigos
                  SeccionPlegable(
                    titulo: SocialTextos.tituloAmigos,
                    estaExpandida: amigosExpanded,
                    onTap: () {
                      setState(() {
                        amigosExpanded = !amigosExpanded;
                      });
                    },
                    cardColor: SocialColores.tarjeta,
                    estiloTituloSeccion: SocialTextStyles.tituloSeccion,
                    colorTextoClaro: SocialColores.textoSecundario,
                    widgetFinal: Row(
                      children: [
                        Text(
                          '${viewModel.amigos.length}',
                          style: SocialTextStyles.emailUsuario.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 300),
                    crossFadeState: amigosExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                    firstChild: TarjetaContenido(
                      cardColor: SocialColores.tarjeta,
                      child: viewModel.amigos.isEmpty
                          ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          SocialTextos.sinAmigos,
                          style: SocialTextStyles.emailUsuario,
                          textAlign: TextAlign.center,
                        ),
                      )
                          : AmigosList(amigos: viewModel.amigos),
                    ),
                    secondChild: const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 20),

                  // Ranking
                  Container(
                    decoration: BoxDecoration(
                      color: SocialColores.tarjeta,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(SocialTextos.tituloRanking, style: SocialTextStyles.tituloSeccion),
                        const SizedBox(height: 10),
                        viewModel.ranking.isEmpty
                            ? Text(
                          SocialTextos.sinRanking,
                          style: SocialTextStyles.emailUsuario,
                        )
                            : RankingList(ranking: viewModel.ranking),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
