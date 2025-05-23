import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'features/tiempos/presentation/viewmodel/tiempos_viewmodel.dart';

import 'core/injection_container.dart';
import 'login_roller_maniac_widget.dart';
import 'features/tiempos/presentation/view/pantalla_principal.dart';
import 'registro_screen.dart';
import 'recuperar_password_screen.dart';
import 'features/social/presentation/viewmodel/social_viewmodel.dart';


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

  await init(); 

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => getIt<TiemposViewModel>(),
        ),
        ChangeNotifierProvider(
          create: (_) => getIt<SocialViewModel>(),
        ),
      ],

      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Roller Maniac',
        theme: ThemeData.dark(),
        home: const AuthChecker(),
        routes: {
          '/registro': (context) => const RegistroScreen(),
          '/recuperar': (context) => const RecuperarPasswordScreen(),
          '/principal': (context) => const PantallaPrincipal(),
        },
      ),

    );
  }
}

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    // Cerrar sesión al iniciar (se ejecuta cada vez que se reconstruye el widget)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FirebaseAuth.instance.signOut();
    });

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
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        final user = snapshot.data;
        if (user != null) {
          if (!user.emailVerified && !user.isAnonymous) {
            return Scaffold(
              backgroundColor: Color(0xFF0F172A),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Usuario: ${user.email}',
                        style: TextStyle(color: Colors.white)),
                    const SizedBox(height: 20),
                    const Text('Por favor verifica tu email',
                        style: TextStyle(color: Colors.white)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => user.sendEmailVerification(),
                      child: const Text('Reenviar email de verificación'),
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