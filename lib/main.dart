import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'login_roller_maniac_widget.dart';
import 'pantalla_principal.dart';
import 'features/tiempos/presentation/viewmodel/tiempos_viewmodel.dart';
import 'features/tiempos/data/repositories/parques_repository_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TiemposViewModel>(
      create: (_) => TiemposViewModel(ParquesRepositoryImpl()),
      child: MaterialApp(
        title: 'RollerManiac',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            primary: Colors.blue,
            secondary: Colors.blueAccent,
            tertiary: Colors.lightBlue,
          ),
          useMaterial3: true,
        ),
        initialRoute: LoginRollerManiacWidget.routePath,
        routes: {
          '/login': (context) => const LoginRollerManiacWidget(),
          '/principal': (context) => const PantallaPrincipal(),
        },
      ),
    );
  }
}
