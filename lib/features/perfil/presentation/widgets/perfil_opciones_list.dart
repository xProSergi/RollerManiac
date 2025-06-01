import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/utils/validation_utils.dart';
import '../../constantes/perfil_constantes.dart';
import '../../../../core/utils/validation_utils.dart';

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

  Future<void> _mostrarDialogoCambiarContrasena(BuildContext contextExterno) async {
    final controladorNueva = TextEditingController();
    final controladorConfirmar = TextEditingController();
    final obscurePasswordNueva = ValueNotifier<bool>(true);
    final obscurePasswordConfirmar = ValueNotifier<bool>(true);

    await showDialog(
      context: contextExterno,
      builder: (dialogInternalContext) {
        return AlertDialog(
          backgroundColor: PerfilConstantes.colorFondo,
          title: const Text(
            'Cambiar contraseña',
            style: TextStyle(color: PerfilConstantes.colorTextoPrincipal),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ValueListenableBuilder<bool>(
                  valueListenable: obscurePasswordNueva,
                  builder: (context, isObscure, child) {
                    return TextField(
                      controller: controladorNueva,
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
                        labelText: PerfilConstantes.labelConfirmarContrasena,
                        hintText: PerfilConstantes.hintConfirmarContrasena,
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
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogInternalContext),
              child: const Text(
                PerfilConstantes.textoCancelar,
                style: PerfilConstantes.estiloOpcion,
              ),
            ),
            TextButton(
              onPressed: () async {
                final nueva = controladorNueva.text;
                final confirmar = controladorConfirmar.text;

                // Validar contraseña
                final validacionPassword = ValidationUtils.validatePassword(nueva);
                if (validacionPassword != null) {
                  _mostrarSnackBar(
                    context: dialogInternalContext,
                    icon: Icons.error_outline_rounded,
                    message: validacionPassword,
                    color: Colors.red[100],
                    duration: 4,
                  );
                  return;
                }

                // Validar que las contraseñas coincidan
                if (nueva != confirmar) {
                  _mostrarSnackBar(
                    context: dialogInternalContext,
                    icon: Icons.error_outline_rounded,
                    message: PerfilConstantes.errorContrasenasNoCoinciden,
                    color: Colors.red[100],
                    duration: 4,
                  );
                  return;
                }

                try {
                  await FirebaseAuth.instance.currentUser?.updatePassword(nueva);
                  Navigator.pop(dialogInternalContext);
                  _mostrarSnackBar(
                    context: contextExterno,
                    icon: Icons.check_circle_outline_rounded,
                    message: PerfilConstantes.exitoContrasenaActualizada,
                    color: Colors.green[100],
                    duration: 3,
                  );
                } on FirebaseAuthException catch (e) {
                  final mensaje = e.code == 'requires-recent-login'
                      ? PerfilConstantes.errorReautenticacion
                      : PerfilConstantes.errorContrasena;
                  _mostrarSnackBar(
                    context: dialogInternalContext,
                    icon: Icons.warning_rounded,
                    message: mensaje,
                    color: Colors.orange[100],
                    duration: 5,
                  );
                } catch (e) {
                  _mostrarSnackBar(
                    context: dialogInternalContext,
                    icon: Icons.warning_rounded,
                    message: PerfilConstantes.errorInesperado + e.toString(),
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
                    color: Colors.black.withAlpha(25),
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