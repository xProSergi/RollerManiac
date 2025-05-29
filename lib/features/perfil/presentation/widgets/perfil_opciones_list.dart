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
    );
  }

  void _showNotImplemented(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(PerfilConstantes.funcionNoImplementada)),
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

  void _mostrarDialogoCambiarContrasena(BuildContext context) {
    final TextEditingController controladorContrasena = TextEditingController();
    final TextEditingController controladorConfirmar = TextEditingController();
    bool _obscurePassword = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: PerfilConstantes.colorTarjeta,
              title: const Text(
                PerfilConstantes.tituloCambiarContrasena,
                style: PerfilConstantes.estiloUsername,
              ),
              content: SizedBox(
                width: 400,  // Controla ancho máximo del diálogo para que sea más grande
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controladorContrasena,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: PerfilConstantes.labelNuevaContrasena,
                        hintText: PerfilConstantes.hintNuevaContrasena,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: PerfilConstantes.colorTextoSecundario,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        labelStyle: const TextStyle(color: PerfilConstantes.colorTextoPrincipal),
                        hintStyle: const TextStyle(color: PerfilConstantes.colorTextoSecundario),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: PerfilConstantes.colorTextoSecundario),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: PerfilConstantes.colorTextoPrincipal),
                        ),
                      ),
                      style: const TextStyle(color: PerfilConstantes.colorTextoPrincipal),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controladorConfirmar,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Confirmar contraseña',
                        hintText: 'Repite tu nueva contraseña',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: PerfilConstantes.colorTextoSecundario,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        labelStyle: const TextStyle(color: PerfilConstantes.colorTextoPrincipal),
                        hintStyle: const TextStyle(color: PerfilConstantes.colorTextoSecundario),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: PerfilConstantes.colorTextoSecundario),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: PerfilConstantes.colorTextoPrincipal),
                        ),
                      ),
                      style: const TextStyle(color: PerfilConstantes.colorTextoPrincipal),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    PerfilConstantes.textoCancelar,
                    style: PerfilConstantes.estiloOpcion,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final nuevaContrasena = controladorContrasena.text.trim();
                    final confirmarContrasena = controladorConfirmar.text.trim();

                    if (nuevaContrasena.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(PerfilConstantes.errorContrasenaCorta),
                        ),
                      );
                      return;
                    }

                    if (nuevaContrasena != confirmarContrasena) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Las contraseñas no coinciden'),
                        ),
                      );
                      return;
                    }

                    try {
                      await FirebaseAuth.instance.currentUser?.updatePassword(nuevaContrasena);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(PerfilConstantes.exitoContrasenaActualizada),
                        ),
                      );
                    } catch (e) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(PerfilConstantes.errorContrasena)),
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
      },
    );
  }

}
