// ============================================================
// RESET PASSWORD SCREEN
// Guarda este archivo como: lib/features/reset_password_screen.dart
// ============================================================
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../main.dart';
import '../service/api_service.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _codigoController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _confirmarReset() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmController.text) {
      RS.err(context, "Las contraseñas no coinciden");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ApiService.confirmarResetPassword(
        email: widget.email,
        codigo: _codigoController.text.trim(),
        nuevaPassword: _passwordController.text,
      );

      if (!mounted) return;
        RS.ok(context, "¡Contraseña actualizada correctamente!");

      // Volver al login
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (r) => false,
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
                  child:  Icon(Icons.verified_outlined, color: AppColors.accent, size: 30),
                ),

                const SizedBox(height: 24),

                 Text(
                  "Introduce el código",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.text, height: 1.2),
                ),
                const SizedBox(height: 12),

                // Email destino
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(children: [
                     Icon(Icons.email_outlined, color: AppColors.accent, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      widget.email,
                      style:  TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ]),
                ),

                const SizedBox(height: 8),
                 Text(
                  "Revisa tu bandeja de entrada y el correo no deseado.",
                  style: TextStyle(color: AppColors.textHint, fontSize: 12),
                ),

                const SizedBox(height: 32),

                // Código
                _label("CÓDIGO DE 6 DÍGITOS"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _codigoController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style:  TextStyle(
                    color: AppColors.text,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 8,
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: "000000",
                    hintStyle:  TextStyle(color: AppColors.textHint, fontSize: 24, letterSpacing: 8),
                    counterText: "",
                    filled: true,
                    fillColor: AppColors.card,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide:  BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide:  BorderSide(color: AppColors.border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide:  BorderSide(color: AppColors.accent, width: 1.5)),
                    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red)),
                    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red)),
                    errorStyle: const TextStyle(color: Colors.redAccent),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Introduce el código";
                    if (v.length != 6) return "El código tiene 6 dígitos";
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Nueva contraseña
                _label("NUEVA CONTRASEÑA"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style:  TextStyle(color: AppColors.text),
                  decoration: InputDecoration(
                    hintText: "Mínimo 6 caracteres",
                    hintStyle:  TextStyle(color: AppColors.textHint),
                    prefixIcon:  Icon(Icons.lock_outline, color: AppColors.textSecondary, size: 18),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.textSecondary, size: 18),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
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
                    if (v == null || v.isEmpty) return "Introduce la nueva contraseña";
                    if (v.length < 6) return "Mínimo 6 caracteres";
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Confirmar contraseña
                _label("CONFIRMAR CONTRASEÑA"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmController,
                  obscureText: _obscureConfirm,
                  style:  TextStyle(color: AppColors.text),
                  decoration: InputDecoration(
                    hintText: "Repite la contraseña",
                    hintStyle:  TextStyle(color: AppColors.textHint),
                    prefixIcon:  Icon(Icons.lock_outline, color: AppColors.textSecondary, size: 18),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.textSecondary, size: 18),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
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
                    if (v == null || v.isEmpty) return "Confirma la contraseña";
                    if (v != _passwordController.text) return "Las contraseñas no coinciden";
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Botón confirmar
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _confirmarReset,
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
                      "CAMBIAR CONTRASEÑA",
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: 1.5),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Reenviar código
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child:  Text(
                      "¿No recibiste el código? Volver a intentarlo",
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
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
    style:  TextStyle(
      color: AppColors.textSecondary,
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.5,
    ),
  );
}