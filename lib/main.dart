import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_roller_maniac_widget.dart';
import 'features/tiempos/presentation/view/pantalla_principal.dart';
import 'features/tiempos/presentation/viewmodel/tiempos_viewmodel.dart';
import 'features/tiempos/data/repositories/parques_repository_impl.dart';
import 'registro_screen.dart';
import 'recuperar_password_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
      );
    }
  } catch (e) {
    print('Error inicializando Firebase: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TiemposViewModel(ParquesRepositoryImpl()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Roller Maniac',
        theme: ThemeData.dark(),
        home: const AuthChecker(),
      ),
    );
  }
}

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0F172A),
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.cyanAccent,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: Color(0xFF0F172A),
            body: Center(
              child: Text('Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        final user = snapshot.data;
        if (user != null) {
          // MOSTRAR INFORMACIÓN DEL USUARIO (TEMPORAL PARA DEBUG)
          print('Usuario logueado: ${user.email}');
          print('Email verificado: ${user.emailVerified}');
          print('UID: ${user.uid}');

          if (!user.emailVerified && !user.isAnonymous) {
            return Scaffold(
              backgroundColor: Color(0xFF0F172A),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Usuario: ${user.email}',
                        style: TextStyle(color: Colors.white)),
                    SizedBox(height: 20),
                    Text('Por favor verifica tu email',
                        style: TextStyle(color: Colors.white)),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => user.sendEmailVerification(),
                      child: Text('Reenviar email de verificación'),
                    ),
                  ],
                ),
              ),
            );
          }

          return const PantallaPrincipal();
        }

        return const LoginRollerManiacWidget();
      },
    );
  }
}
