import 'package:flutter/material.dart';
import 'login_roller_maniac_widget.dart'; // Asegúrate de que este es el nombre correcto de tu archivo

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
        LoginRollerManiacWidget.routePath: (context) => const LoginRollerManiacWidget(),
      },

    );
  }
}