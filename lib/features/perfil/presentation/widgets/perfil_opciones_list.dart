import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../constantes/perfil_constantes.dart';

class PerfilOpcionesList extends StatelessWidget {
  const PerfilOpcionesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: PerfilConstantes.colorTarjeta,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          _buildOptionTile(
            icon: PerfilConstantes.iconoEditar,
            text: PerfilConstantes.editarPerfil,
            onTap: () => _showNotImplemented(context),
          ),
          const Divider(height: 1, color: PerfilConstantes.colorDivisor),
          _buildOptionTile(
            icon: PerfilConstantes.iconoCambiarContrasena,
            text: PerfilConstantes.cambiarContrasena,
            onTap: () => _mostrarDialogoCambiarContrasena(context),
          ),
          const Divider(height: 1, color: PerfilConstantes.colorDivisor),
          _buildOptionTile(
            icon: PerfilConstantes.iconoNotificaciones,
            text: PerfilConstantes.notificaciones,
            onTap: () => _showNotImplemented(context),
          ),
          const Divider(height: 1, color: PerfilConstantes.colorDivisor),
          _buildOptionTile(
            icon: PerfilConstantes.iconoCreditos,
            text: PerfilConstantes.creditos,
            onTap: () => _showCreditosDialog(context),
          ),
          const Divider(height: 1, color: PerfilConstantes.colorDivisor),
          _buildOptionTile(
            icon: PerfilConstantes.iconoTerminos,
            text: PerfilConstantes.manualUsuario,
            onTap: () => _showNotImplemented(context),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: PerfilConstantes.colorTextoSecundario),
      title: Text(text, style: PerfilConstantes.estiloOpcion),
      trailing: const Icon(
        PerfilConstantes.iconoArrow,
        color: PerfilConstantes.colorTextoSecundario,
        size: 16,
      ),
      onTap: onTap,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      tileColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      visualDensity: VisualDensity.compact,
    );
  }

  void _showNotImplemented(BuildContext context) {
    // Para mensajes de la pantalla principal, usa el ScaffoldMessenger de la pantalla principal
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          PerfilConstantes.funcionNoImplementada,
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.amber[100],
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showCreditosDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: PerfilConstantes.colorTarjeta,
        title: const Text(
          PerfilConstantes.creditos,
          style: PerfilConstantes.estiloUsername,
        ),
        content: const Text(
          PerfilConstantes.textoCreditos,
          style: PerfilConstantes.estiloEmail,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              PerfilConstantes.textoCancelar,
              style: PerfilConstantes.estiloOpcion,
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoCambiarContrasena(BuildContext contextExterno) {
    // No necesitamos ScaffoldMessenger aquí directamente, lo obtendremos en el Builder
    final TextEditingController controladorContrasena = TextEditingController();
    final TextEditingController controladorConfirmar = TextEditingController();
    final ValueNotifier<bool> obscurePasswordNueva = ValueNotifier<bool>(true);
    final ValueNotifier<bool> obscurePasswordConfirmar = ValueNotifier<bool>(true);

    showGeneralDialog(
      context: contextExterno,
      barrierLabel: "Cambiar contraseña",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) {
        // *** IMPORTANTE: Usa un Builder para obtener un BuildContext que es hijo del Scaffold implícito del diálogo ***
        return Builder(
          builder: (dialogInternalContext) { // Este context es el que debes usar para los SnackBars del diálogo
            return Center(
              child: Material(
                color: Colors.transparent, // Asegúrate de que el Material sea transparente para que no bloquee los toques
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: PerfilConstantes.colorTarjeta,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          PerfilConstantes.tituloCambiarContrasena,
                          style: PerfilConstantes.estiloUsername,
                        ),
                        const SizedBox(height: 16),
                        ValueListenableBuilder<bool>(
                          valueListenable: obscurePasswordNueva,
                          builder: (context, isObscure, child) {
                            return TextField(
                              controller: controladorContrasena,
                              obscureText: isObscure,
                              decoration: InputDecoration(
                                labelText: PerfilConstantes.labelNuevaContrasena,
                                hintText: PerfilConstantes.hintNuevaContrasena,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isObscure ? Icons.visibility_off : Icons.visibility,
                                    color: PerfilConstantes.colorTextoSecundario,
                                  ),
                                  onPressed: () => obscurePasswordNueva.value = !isObscure,
                                ),
                                labelStyle: const TextStyle(color: PerfilConstantes.colorTextoPrincipal),
                                hintStyle: const TextStyle(color: PerfilConstantes.colorTextoSecundario),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: PerfilConstantes.colorTextoSecundario),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: PerfilConstantes.colorTextoPrincipal),
                                ),
                              ),
                              style: const TextStyle(color: PerfilConstantes.colorTextoPrincipal),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        ValueListenableBuilder<bool>(
                          valueListenable: obscurePasswordConfirmar,
                          builder: (context, isObscure, child) {
                            return TextField(
                              controller: controladorConfirmar,
                              obscureText: isObscure,
                              decoration: InputDecoration(
                                labelText: 'Confirmar contraseña',
                                hintText: 'Repite tu nueva contraseña',
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isObscure ? Icons.visibility_off : Icons.visibility,
                                    color: PerfilConstantes.colorTextoSecundario,
                                  ),
                                  onPressed: () => obscurePasswordConfirmar.value = !isObscure,
                                ),
                                labelStyle: const TextStyle(color: PerfilConstantes.colorTextoPrincipal),
                                hintStyle: const TextStyle(color: PerfilConstantes.colorTextoSecundario),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: PerfilConstantes.colorTextoSecundario),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: PerfilConstantes.colorTextoPrincipal),
                                ),
                              ),
                              style: const TextStyle(color: PerfilConstantes.colorTextoPrincipal),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogInternalContext), // Usar dialogInternalContext para cerrar
                              child: const Text(
                                PerfilConstantes.textoCancelar,
                                style: PerfilConstantes.estiloOpcion,
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                final nueva = controladorContrasena.text.trim();
                                final confirmar = controladorConfirmar.text.trim();

                                if (nueva.length < 6) {
                                  _mostrarSnackBar(
                                    context: dialogInternalContext, // Usa este context para el SnackBar DENTRO del diálogo
                                    icon: Icons.info_outline_rounded,
                                    message: PerfilConstantes.errorContrasenaCorta,
                                    color: Colors.blue[100],
                                    duration: 3,
                                  );
                                  return;
                                }

                                if (nueva != confirmar) {
                                  _mostrarSnackBar(
                                    context: dialogInternalContext, // Usa este context para el SnackBar DENTRO del diálogo
                                    icon: Icons.error_outline_rounded,
                                    message: 'Las contraseñas no coinciden',
                                    color: Colors.red[100],
                                    duration: 4,
                                  );
                                  return;
                                }

                                try {
                                  await FirebaseAuth.instance.currentUser?.updatePassword(nueva);
                                  Navigator.pop(dialogInternalContext); // Cierra el diálogo primero
                                  _mostrarSnackBar(
                                    context: contextExterno, // Usa contextExterno para el SnackBar de la pantalla principal
                                    icon: Icons.check_circle_outline_rounded,
                                    message: PerfilConstantes.exitoContrasenaActualizada,
                                    color: Colors.green[100],
                                    duration: 3,
                                  );
                                } on FirebaseAuthException catch (e) {
                                  final mensaje = e.code == 'requires-recent-login'
                                      ? 'Debes iniciar sesión recientemente para cambiar la contraseña. Por favor, cierra sesión y vuelve a iniciarla para reautenticarte.'
                                      : PerfilConstantes.errorContrasena;
                                  _mostrarSnackBar(
                                    context: dialogInternalContext, // Usa este context para el SnackBar DENTRO del diálogo
                                    icon: Icons.warning_rounded,
                                    message: mensaje,
                                    color: Colors.orange[100],
                                    duration: 5,
                                  );
                                } catch (e) {
                                  _mostrarSnackBar(
                                    context: dialogInternalContext, // Usa este context para el SnackBar DENTRO del diálogo
                                    icon: Icons.warning_rounded,
                                    message: 'Ocurrió un error inesperado: ${e.toString()}',
                                    color: Colors.orange[100],
                                    duration: 4,
                                  );
                                }
                              },
                              child: const Text(
                                PerfilConstantes.textoGuardar,
                                style: PerfilConstantes.estiloOpcion,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _mostrarSnackBar({
    required BuildContext context,
    required IconData icon,
    required String message,
    required Color? color,
    required int duration,
  }) {
    // Encontrar el Overlay más cercano
    final overlay = Overlay.of(context);

    // Obtener el tamaño del teclado
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // Crear una capa de overlay
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        // Si el teclado está visible, colocamos el mensaje justo encima
        bottom: keyboardHeight > 0 ? keyboardHeight : 20,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(icon, color: Colors.black87, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );


    overlay.insert(overlayEntry);
    Future.delayed(Duration(seconds: duration), () {
      overlayEntry.remove();
    });
  }
}