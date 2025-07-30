import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/tiempos/presentation/view/pantalla_principal.dart';
import '../../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _text1Controller;
  late AnimationController _text2Controller;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _text1Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _text2Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 900), () => _text1Controller.forward());
    Future.delayed(const Duration(milliseconds: 1700), () => _text2Controller.forward());


    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthChecker()),
      );
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _text1Controller.dispose();
    _text2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color1 = Colors.blue[800]!;
    final color2 = Colors.pink[300]!;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color1, color2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _logoController,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Image.asset(
                      'img/logoRoller.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),
              FadeTransition(
                opacity: _text1Controller,
                child: Text(
                  "Bienvenido a RollerManiac",
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 18),
              FadeTransition(
                opacity: _text2Controller,
                child: Text(
                  "¡Tu diario de parques y atracciones!",
                  style: GoogleFonts.montserrat(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}