import 'dart:async';
import 'package:flutter/material.dart';
import '../main.dart';
import '../providers/user_session.dart';
import 'login_screen.dart';
import 'menu_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnim = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // El tema ya está cargado desde main() antes de runApp
    // Aquí solo cargamos la sesión del usuario + tiempo mínimo del splash
    await Future.wait([
      Future.delayed(const Duration(seconds: 3)),
      _cargarSesion(),
    ]);

    if (!mounted) return;

    if (UserSession.isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MenuScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }



  Future<void> _cargarSesion() async {
    try {
      final result = await UserSession.loadFromStorage();
      debugPrint("=== SESION CARGADA: $result");
      debugPrint("=== userId: ${UserSession.userId}");
      debugPrint("=== nombre: ${UserSession.nombre}");
    } catch (e) {
      debugPrint("=== ERROR cargando sesión: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, child) => Transform.translate(
            offset: Offset(0, _slideAnim.value),
            child: child,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _scaleAnim,
                  child: Image.asset(
                    'assets/images/robotin.jpg',
                    width: 220,
                    height: 220,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  "REALSTEEL",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                    letterSpacing: 6,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "by IronCode",
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 60),
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: AppColors.accent,
                    strokeWidth: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}