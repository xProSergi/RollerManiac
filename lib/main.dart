import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'login_roller_maniac_widget.dart';
import 'features/tiempos/presentation/view/pantalla_principal.dart';
import 'features/tiempos/presentation/viewmodel/tiempos_viewmodel.dart';
import 'features/tiempos/data/repositories/parques_repository_impl.dart';
import 'registro_screen.dart';
import 'recuperar_password_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        name: 'RollerManiacApp',
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    runApp(MyApp());
  } catch (e) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Error inicializando: $e', style: const TextStyle(color: Colors.red)),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TiemposViewModel(ParquesRepositoryImpl()),
      child: MaterialApp(
        title: 'RollerManiac',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            primary: Colors.blue,
            secondary: Colors.blueAccent,
          ),
          useMaterial3: true,
        ),
        initialRoute: '/auth-check',
        routes: {
          '/auth-check': (context) => const AuthChecker(),
          '/login': (context) => const LoginRollerManiacWidget(),
          '/principal': (context) => const PantallaPrincipal(),
          '/registro': (context) => const RegistroScreen(),
          '/recuperar': (context) => const RecuperarPasswordScreen(),
        },
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
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const PantallaPrincipal();
        }

        return const LoginRollerManiacWidget();
      },
    );
  }
}