import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/perfil_viewmodel.dart';
import '../widgets/perfil_info_card.dart';
import '../widgets/perfil_opciones_list.dart';
import '../../constantes/perfil_constantes.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PerfilViewModel(),
      child: Consumer<PerfilViewModel>(
        builder: (context, viewModel, _) {
          if (!viewModel.isLoaded) {
            return Scaffold(
              body: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  gradient: PerfilConstantes.gradienteFondo,
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: PerfilConstantes.colorTextoPrincipal,
                  ),
                ),
              ),
            );
          }

          return Scaffold(
            body: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: PerfilConstantes.gradienteFondo,
                  ),
                ),
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PerfilInfoCard(
                          username: viewModel.username,
                          email: viewModel.email,
                          creationDate: viewModel.creationDate,
                        ),
                        const SizedBox(height: 24),
                        const PerfilOpcionesList(),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: PerfilConstantes.colorBotonCerrarSesion,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              shadowColor: Colors.black.withValues(alpha: 102),
                              elevation: 6,
                            ),
                            onPressed: () async {
                              await viewModel.signOut();
                              if (context.mounted) {
                                Navigator.of(context).pushReplacementNamed('/login');
                              }
                            },
                            icon: const Icon(
                              PerfilConstantes.iconoCerrarSesion,
                              size: 22,
                              color: PerfilConstantes.colorTextoPrincipal,
                            ),
                            label: const Text(
                              PerfilConstantes.cerrarSesion,
                              style: PerfilConstantes.estiloBotonCerrarSesion,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
