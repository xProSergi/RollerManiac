import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/social_viewmodel.dart';
import '../widgets/amigos_list.dart';
import '../widgets/ranking_list.dart';
import '../widgets/solicitudes_list.dart';
import '../widgets/agregar_amigo.dart'; // Importar el nuevo widget
import '../widgets/seccion_plegable.dart'; // Importar el nuevo widget
import '../widgets/tarjeta_contenido.dart'; // Importar el nuevo widget
import 'package:firebase_auth/firebase_auth.dart';

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

    const Color bgColor = Color(0xFF0F172A);
    const Color cardColor = Color(0xFF1E293B);
    const Color accentColor = Color(0xFF64B5F6);
    const Color textColor = Colors.white;
    const Color lightTextColor = Colors.white70;
    const Color dimTextColor = Colors.white54;

    const TextStyle titleStyle = TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: textColor,
      letterSpacing: 0.8,
    );

    const TextStyle sectionTitleStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: lightTextColor,
    );

    const TextStyle dimBodyTextStyle = TextStyle(
      fontSize: 14,
      color: dimTextColor,
    );

    return Scaffold(
      backgroundColor: bgColor,
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
                    accentColor: accentColor,
                    cardColor: cardColor,
                    textColor: textColor,
                    lightTextColor: lightTextColor,
                    onAgregarAmigo: (username) async {
                      try {
                        await viewModel.agregarAmigoPorUsername(username);
                        usernameController.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('¡Solicitud de amistad enviada a $username!'),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al enviar solicitud: ${e.toString().split(':').last.trim()}'),
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

                  // Solicitudes recibidas
                  SeccionPlegable(
                    titulo: 'Solicitudes recibidas',
                    estaExpandida: solicitudesExpanded,
                    onTap: () {
                      setState(() {
                        solicitudesExpanded = !solicitudesExpanded;
                      });
                    },
                    cardColor: cardColor,
                    estiloTituloSeccion: sectionTitleStyle,
                    colorTextoClaro: lightTextColor,
                    widgetFinal: viewModel.solicitudes.isNotEmpty
                        ? CircleAvatar(
                      radius: 12,
                      backgroundColor: accentColor,
                      child: Text(
                        '${viewModel.solicitudes.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    )
                        : null,
                  ),
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 300),
                    crossFadeState: solicitudesExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                    firstChild: TarjetaContenido(
                      cardColor: cardColor,
                      child: viewModel.solicitudes.isEmpty
                          ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'No tienes solicitudes pendientes.',
                          style: dimBodyTextStyle,
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

                  // Amigos
                  SeccionPlegable(
                    titulo: 'Amigos',
                    estaExpandida: amigosExpanded,
                    onTap: () {
                      setState(() {
                        amigosExpanded = !amigosExpanded;
                      });
                    },
                    cardColor: cardColor,
                    estiloTituloSeccion: sectionTitleStyle,
                    colorTextoClaro: lightTextColor,
                    widgetFinal: Row(
                      children: [
                        Text(
                          '${viewModel.amigos.length}',
                          style: dimBodyTextStyle.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 300),
                    crossFadeState: amigosExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                    firstChild: TarjetaContenido(
                      cardColor: cardColor,
                      child: viewModel.amigos.isEmpty
                          ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'Aún no tienes amigos agregados.',
                          style: dimBodyTextStyle,
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
                      color: cardColor,
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
                    child: Text('Ranking entre amigos', style: sectionTitleStyle),
                  ),
                  TarjetaContenido(
                    cardColor: cardColor,
                    margin: const EdgeInsets.only(top: 10, bottom: 30),
                    child: viewModel.ranking.isEmpty
                        ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'No hay datos de ranking disponibles.',
                        style: dimBodyTextStyle,
                        textAlign: TextAlign.center,
                      ),
                    )
                        : RankingList(ranking: viewModel.ranking),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}