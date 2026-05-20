import 'package:flutter/material.dart';
import '../main.dart';
import '../service/api_service.dart';
import '../providers/user_session.dart';
import 'registro_screen.dart';
import 'menu_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscurePassword = true;
  bool isLoading = false;

  // ── Animación robot ──────────────────────────────────────
  late final AnimationController _robotCtrl;
  late final Animation<double> _robotBounce;
  late final Animation<double> _robotFade;

  @override
  void initState() {
    super.initState();
    _robotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _robotBounce = Tween<double>(begin: 24, end: 0).animate(
      CurvedAnimation(parent: _robotCtrl, curve: Curves.elasticOut),
    );
    _robotFade = CurvedAnimation(parent: _robotCtrl, curve: Curves.easeIn);
    // Lanza la animación al entrar
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _robotCtrl.forward();
    });
  }

  @override
  void dispose() {
    _robotCtrl.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      final data = await ApiService.login(
        emailController.text.trim(),
        passwordController.text,
      );
      await UserSession.saveToStorage(
        userId: data['userId'],
        nombre: data['nombre'],
        email: data['email'],
        gimnasio: data['gimnasio'],
      );
      debugPrint("=== SESION GUARDADA: ${UserSession.userId}");
      debugPrint("=== nombre: ${UserSession.nombre}");
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MenuScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      RS.err(context, e.toString().replaceAll("Exception: ", ""));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),

                // ── ROBOT ANIMADO ───────────────────────────
                AnimatedBuilder(
                  animation: _robotCtrl,
                  builder: (_, __) => FadeTransition(
                    opacity: _robotFade,
                    child: Transform.translate(
                      offset: Offset(0, _robotBounce.value),
                      child: Center(
                        child: Column(children: [
                          Stack(clipBehavior: Clip.none, children: [
                            Container(
                              width: 90, height: 90,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: AppColors.accent, width: 2),
                                boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.25), blurRadius: 20, spreadRadius: 2)],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset('assets/images/robotin.jpg', fit: BoxFit.cover),
                              ),
                            ),
                            // Burbuja de saludo
                            Positioned(
                              top: -14, right: -14,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.accent,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.4), blurRadius: 8)],
                                ),
                                child: const Text("👋 Hola!", style: TextStyle(color: AppColors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ]),
                          const SizedBox(height: 14),
                           Text(
                            "¡Bienvenido de vuelta!",
                            style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                           Text(
                            "Inicia sesión para continuar",
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ]),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // ── EMAIL ───────────────────────────────────
                _label("EMAIL"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style:  TextStyle(color: AppColors.text),
                  decoration: _inputDeco("tucorreo@gmail.com"),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Introduce un email";
                    if (!v.contains("@")) return "Email no válido";
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // ── CONTRASEÑA ──────────────────────────────
                _label("CONTRASEÑA"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  style:  TextStyle(color: AppColors.text),
                  decoration: _inputDeco("••••••••").copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppColors.textSecondary, size: 20,
                      ),
                      onPressed: () => setState(() => obscurePassword = !obscurePassword),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Introduce la contraseña";
                    if (v.length < 6) return "Mínimo 6 caracteres";
                    return null;
                  },
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                    child:  Text("¿Olvidaste tu contraseña?", style: TextStyle(color: AppColors.accent, fontSize: 13)),
                  ),
                ),

                const SizedBox(height: 28),

                // ── BOTÓN ENTRAR ────────────────────────────
                SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.white,
                      disabledBackgroundColor: AppColors.accentDark,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                        : const Text("ENTRAR", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: 2)),
                  ),
                ),

                const SizedBox(height: 24),

                // ── DIVISOR ─────────────────────────────────
                Row(children: [
                  Expanded(child: Divider(color: AppColors.border, thickness: 1)),
                   Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text("¿No tienes cuenta?", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ),
                  Expanded(child: Divider(color: AppColors.border, thickness: 1)),
                ]),

                const SizedBox(height: 20),

                // ── CREAR CUENTA ────────────────────────────
                SizedBox(
                  width: double.infinity, height: 52,
                  child: OutlinedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                    style: OutlinedButton.styleFrom(
                      side:  BorderSide(color: AppColors.border, width: 1),
                      foregroundColor: AppColors.text,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("CREAR CUENTA", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: 1.5)),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style:  TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5));

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint,
    hintStyle:  TextStyle(color: AppColors.textHint),
    filled: true, fillColor: AppColors.card,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide:  BorderSide(color: AppColors.border)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide:  BorderSide(color: AppColors.border)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide:  BorderSide(color: AppColors.accent, width: 1.5)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red)),
    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red)),
    errorStyle: const TextStyle(color: Colors.redAccent),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}