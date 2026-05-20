import 'package:flutter/material.dart';
import '../main.dart';
import '../providers/user_session.dart';
import '../service/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _emailController;
  late TextEditingController _gimnasioController;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _cambiarPassword = false;

  final List<String> _gimnasios = [
    "CrossFit Mérida", "MetroFit Mérida", "Gym Sport Mérida",
    "Holmes Place Mérida", "Otro",
  ];

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: UserSession.nombre ?? '');
    _emailController = TextEditingController(text: UserSession.email ?? '');
    _gimnasioController = TextEditingController(text: UserSession.gimnasio ?? '');
    themeController.addListener(_onThemeChange);
  }

  void _onThemeChange() => setState(() {});

  @override
  void dispose() {
    themeController.removeListener(_onThemeChange);
    _nombreController.dispose();
    _emailController.dispose();
    _gimnasioController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_cambiarPassword && _passwordController.text != _passwordConfirmController.text) {
      RS.err(context, "Las contraseñas no coinciden");
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ApiService.updateUser(
        userId: UserSession.userId!,
        nombre: _nombreController.text.trim(),
        email: _emailController.text.trim(),
        // ← null si no quiere cambiar contraseña, el backend la ignora
        password: _cambiarPassword && _passwordController.text.isNotEmpty
            ? _passwordController.text
            : null,
        gimnasio: _gimnasioController.text.trim().isEmpty
            ? null
            : _gimnasioController.text.trim(),
      );
      UserSession.save(
        userId: UserSession.userId!,
        nombre: _nombreController.text.trim(),
        email: _emailController.text.trim(),
        gimnasio: _gimnasioController.text.trim().isEmpty
            ? null
            : _gimnasioController.text.trim(),
      );
      if (mounted) {
        RS.ok(context, "Perfil actualizado correctamente");
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) RS.err(context, e.toString().replaceAll("Exception: ", ""));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final iniciales = (UserSession.nombre ?? "U")
        .split(' ').where((p) => p.isNotEmpty).take(2)
        .map((p) => p[0].toUpperCase()).join();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text("MI PERFIL",
            style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w800, letterSpacing: 2, fontSize: 16)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: _isLoading ? null : _guardar,
              child: _isLoading
                  ? SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2))
                  : Text("GUARDAR",
                  style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700, letterSpacing: 1)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── AVATAR ────────────────────────────────────────
              Center(
                child: Column(children: [
                  Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      color: AppColors.accent, shape: BoxShape.circle,
                      border: Border.all(color: AppColors.accent.withOpacity(0.3), width: 3),
                    ),
                    child: Center(child: Text(iniciales,
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800))),
                  ),
                  const SizedBox(height: 10),
                  Text(UserSession.nombre ?? '',
                      style: TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(UserSession.email ?? '',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ]),
              ),

              const SizedBox(height: 32),

              // ── SELECTOR DE PALETA ────────────────────────────
              _seccionTitulo("APARIENCIA"),
              const SizedBox(height: 16),
              _PaletteSelector(),

              const SizedBox(height: 32),

              // ── DATOS PERSONALES ──────────────────────────────
              _seccionTitulo("DATOS PERSONALES"),
              const SizedBox(height: 12),

              _campo(label: "Nombre", controller: _nombreController, icon: Icons.person_outline,
                  validator: (v) => v == null || v.isEmpty ? "El nombre es obligatorio" : null),
              const SizedBox(height: 14),

              _campo(label: "Email", controller: _emailController, icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return "El email es obligatorio";
                    if (!v.contains("@")) return "Email no válido";
                    return null;
                  }),
              const SizedBox(height: 14),

              _label("Gimnasio"),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _gimnasios.contains(_gimnasioController.text) ? _gimnasioController.text : null,
                    hint: Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text("Selecciona tu gimnasio",
                            style: TextStyle(color: AppColors.textHint, fontSize: 14))),
                    isExpanded: true,
                    dropdownColor: AppColors.card,
                    icon: Padding(padding: const EdgeInsets.only(right: 12),
                        child: Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary)),
                    items: _gimnasios.map((g) => DropdownMenuItem(
                      value: g,
                      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(g, style: TextStyle(color: AppColors.text, fontSize: 14))),
                    )).toList(),
                    onChanged: (val) => setState(() => _gimnasioController.text = val ?? ''),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── SEGURIDAD ─────────────────────────────────────
              _seccionTitulo("SEGURIDAD"),
              const SizedBox(height: 12),

              GestureDetector(
                onTap: () => setState(() {
                  _cambiarPassword = !_cambiarPassword;
                  if (!_cambiarPassword) {
                    _passwordController.clear();
                    _passwordConfirmController.clear();
                  }
                }),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _cambiarPassword ? AppColors.accent : AppColors.border),
                  ),
                  child: Row(children: [
                    Icon(Icons.lock_outline,
                        color: _cambiarPassword ? AppColors.accent : AppColors.textSecondary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text("Cambiar contraseña",
                          style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w600, fontSize: 14)),
                      Text("Toca para establecer una nueva contraseña",
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ])),
                    Icon(_cambiarPassword ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: AppColors.textSecondary, size: 20),
                  ]),
                ),
              ),

              if (_cambiarPassword) ...[
                const SizedBox(height: 14),
                _campoPassword(
                  label: "Nueva contraseña", controller: _passwordController,
                  obscure: _obscurePassword,
                  onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                  validator: (v) {
                    if (_cambiarPassword && (v == null || v.isEmpty)) return "Introduce la nueva contraseña";
                    if (_cambiarPassword && v!.length < 6) return "Mínimo 6 caracteres";
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _campoPassword(
                  label: "Confirmar contraseña", controller: _passwordConfirmController,
                  obscure: _obscureConfirm,
                  onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  validator: (v) {
                    if (_cambiarPassword && v != _passwordController.text) return "Las contraseñas no coinciden";
                    return null;
                  },
                ),
              ],

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _guardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text("GUARDAR CAMBIOS",
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: 1.5)),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _seccionTitulo(String titulo) => Row(children: [
    Container(width: 4, height: 14,
        decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 8),
    Text(titulo, style: TextStyle(color: AppColors.text, fontSize: 12,
        fontWeight: FontWeight.w700, letterSpacing: 1.5)),
  ]);

  Widget _label(String text) => Text(text,
      style: TextStyle(color: AppColors.textSecondary, fontSize: 11,
          fontWeight: FontWeight.w600, letterSpacing: 1));

  Widget _campo({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _label(label.toUpperCase()),
    const SizedBox(height: 8),
    TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: AppColors.text),
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 18),
        filled: true, fillColor: AppColors.card,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.accent, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red)),
        errorStyle: const TextStyle(color: Colors.redAccent),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    ),
  ]);

  Widget _campoPassword({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _label(label.toUpperCase()),
    const SizedBox(height: 8),
    TextFormField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: AppColors.text),
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.lock_outline, color: AppColors.textSecondary, size: 18),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: AppColors.textSecondary, size: 18),
          onPressed: onToggle,
        ),
        filled: true, fillColor: AppColors.card,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.accent, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red)),
        errorStyle: const TextStyle(color: Colors.redAccent),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    ),
  ]);
}

// ============================================================
// SELECTOR DE PALETA
// ============================================================
class _PaletteSelector extends StatefulWidget {
  @override
  State<_PaletteSelector> createState() => _PaletteSelectorState();
}

class _PaletteSelectorState extends State<_PaletteSelector> {
  @override
  void initState() {
    super.initState();
    themeController.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    themeController.removeListener(_rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text("MODO OSCURO",
            style: TextStyle(color: AppColors.textHint, fontSize: 10,
                fontWeight: FontWeight.w700, letterSpacing: 1.5)),
      ),
      GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 5,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.75,
        children: [
          AppPalette.steelRed,
          AppPalette.midnightPurple,
          AppPalette.oceanBlue,
          AppPalette.forestGreen,
          AppPalette.burnedOrange,
        ].map((p) => _PaletteChip(palette: p)).toList(),
      ),

      const SizedBox(height: 16),

      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text("MODO CLARO",
            style: TextStyle(color: AppColors.textHint, fontSize: 10,
                fontWeight: FontWeight.w700, letterSpacing: 1.5)),
      ),
      GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 5,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.75,
        children: [
          AppPalette.pureWhite,
          AppPalette.roseLight,
          AppPalette.skyLight,
        ].map((p) => _PaletteChip(palette: p)).toList(),
      ),
    ]);
  }
}

class _PaletteChip extends StatelessWidget {
  final AppPalette palette;
  const _PaletteChip({required this.palette});

  @override
  Widget build(BuildContext context) {
    final info = palettes[palette]!;
    final isSelected = themeController.palette == palette;

    return GestureDetector(
      onTap: () => themeController.setPalette(palette),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: info.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? info.accent : info.border,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: info.accent.withOpacity(0.4), blurRadius: 8, spreadRadius: 1)]
              : [],
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 28, height: 28,
              decoration: BoxDecoration(color: info.accent, shape: BoxShape.circle)),
          const SizedBox(height: 6),
          Text(info.emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            info.nombre.split(' ').first,
            style: TextStyle(
              color: info.text,
              fontSize: 9,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (isSelected) ...[
            const SizedBox(height: 3),
            Container(width: 6, height: 6,
                decoration: BoxDecoration(color: info.accent, shape: BoxShape.circle)),
          ],
        ]),
      ),
    );
  }
}