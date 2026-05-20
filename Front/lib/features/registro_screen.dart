import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../main.dart';
import '../service/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final repeatPasswordController = TextEditingController();
  bool obscurePassword = true;
  bool obscureRepeat = true;
  bool isLoading = false;

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      final userId = const Uuid().v4();
      await ApiService.createUser(
        userId: userId,
        nombre: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      if (!mounted) return;
      RS.ok(context, "Cuenta creada. Inicia sesión.");
      Navigator.pop(context);
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
                const SizedBox(height: 40),

                // BACK + TÍTULO
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: AppColors.text,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                      Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "NUEVA CUENTA",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          "Únete a RealSteel",
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // NOMBRE
                _label("NOMBRE"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: nameController,
                  style: TextStyle(color: AppColors.text),
                  decoration: _inputDeco("Tu nombre"),
                  validator: (v) =>
                  v == null || v.isEmpty ? "Introduce tu nombre" : null,
                ),
                const SizedBox(height: 20),

                // EMAIL
                _label("EMAIL"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: AppColors.text),
                  decoration: _inputDeco("tucorreo@gmail.com"),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Introduce un email";
                    if (!v.contains("@")) return "Email no válido";
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // CONTRASEÑA
                _label("CONTRASEÑA"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  style: TextStyle(color: AppColors.text),
                  decoration: _inputDeco("Mínimo 6 caracteres").copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => obscurePassword = !obscurePassword),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Introduce la contraseña";
                    if (v.length < 6) return "Mínimo 6 caracteres";
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // REPETIR
                _label("REPITE LA CONTRASEÑA"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: repeatPasswordController,
                  obscureText: obscureRepeat,
                  style: TextStyle(color: AppColors.text),
                  decoration: _inputDeco("Repite la contraseña").copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureRepeat
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => obscureRepeat = !obscureRepeat),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Repite la contraseña";
                    if (v != passwordController.text)
                      return "Las contraseñas no coinciden";
                    return null;
                  },
                ),

                const SizedBox(height: 36),

                // BOTÓN
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.white,
                      disabledBackgroundColor: AppColors.accentDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                        : const Text(
                      "REGISTRARME",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        letterSpacing: 2,
                      ),
                    ),
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

  Widget _label(String text) => Text(
    text,
    style: TextStyle(
      color: AppColors.textSecondary,
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.5,
    ),
  );

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: AppColors.textHint),
    filled: true,
    fillColor: AppColors.card,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: AppColors.accent, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.red),
    ),
    errorStyle: const TextStyle(color: Colors.redAccent),
    contentPadding:
    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}