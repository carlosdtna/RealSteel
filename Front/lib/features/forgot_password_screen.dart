// ============================================================
// FORGOT PASSWORD SCREEN
// Guarda este archivo como: lib/features/forgot_password_screen.dart
// ============================================================
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../main.dart';
import '../service/api_service.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _enviarCodigo() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await ApiService.solicitarCodigoReset(_emailController.text.trim());

      if (!mounted) return;
      RS.info(context, "Código enviado a tu email");

      // Navegar a la pantalla de introducir código
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(email: _emailController.text.trim()),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      RS.err(context, e.toString().replaceAll("Exception: ", ""));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon:  Icon(Icons.arrow_back, color: AppColors.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Icono
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.accent.withOpacity(0.5)),
                  ),
                  child:  Icon(Icons.lock_reset, color: AppColors.accent, size: 30),
                ),

                const SizedBox(height: 24),

                 Text(
                  "¿Olvidaste tu\ncontraseña?",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                 Text(
                  "Introduce tu email y te enviaremos un código de 6 dígitos para recuperar tu cuenta.",
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
                ),

                const SizedBox(height: 40),

                // Email
                 Text(
                  "EMAIL",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style:  TextStyle(color: AppColors.text),
                  decoration: InputDecoration(
                    hintText: "tucorreo@gmail.com",
                    hintStyle:  TextStyle(color: AppColors.textHint),
                    prefixIcon:  Icon(Icons.email_outlined, color: AppColors.textSecondary, size: 18),
                    filled: true,
                    fillColor: AppColors.card,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide:  BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide:  BorderSide(color: AppColors.border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide:  BorderSide(color: AppColors.accent, width: 1.5)),
                    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red)),
                    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red)),
                    errorStyle: const TextStyle(color: Colors.redAccent),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Introduce tu email";
                    if (!v.contains("@")) return "Email no válido";
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Botón enviar
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _enviarCodigo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.white,
                      disabledBackgroundColor: AppColors.accentDark,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                        : const Text(
                      "ENVIAR CÓDIGO",
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: 2),
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
}