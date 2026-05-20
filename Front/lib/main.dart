import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ← Esperar a que el tema cargue ANTES de arrancar la app
  await themeController.loadPalette();
  runApp(const MyApp());
}

// ============================================================
// PALETAS DE COLOR
// ============================================================
enum AppPalette {
  steelRed,
  midnightPurple,
  oceanBlue,
  forestGreen,
  burnedOrange,
  pureWhite,
  roseLight,
  skyLight,
}

class PaletteInfo {
  final String nombre;
  final String emoji;
  final bool isDark;
  final Color accent;
  final Color accentDark;
  final Color background;
  final Color card;
  final Color border;
  final Color text;
  final Color textSecondary;
  final Color textHint;

  const PaletteInfo({
    required this.nombre,
    required this.emoji,
    required this.isDark,
    required this.accent,
    required this.accentDark,
    required this.background,
    required this.card,
    required this.border,
    required this.text,
    required this.textSecondary,
    required this.textHint,
  });
}

const Map<AppPalette, PaletteInfo> palettes = {
  AppPalette.steelRed: PaletteInfo(
    nombre: "Steel Red", emoji: "🔴", isDark: true,
    accent: Color(0xFFC0392B), accentDark: Color(0xFF962D22),
    background: Color(0xFF1A1A1A), card: Color(0xFF2A2A2A), border: Color(0xFF3A3A3A),
    text: Color(0xFFE8E8E8), textSecondary: Color(0xFF888888), textHint: Color(0xFF555555),
  ),
  AppPalette.midnightPurple: PaletteInfo(
    nombre: "Midnight Purple", emoji: "🟣", isDark: true,
    accent: Color(0xFF7C3AED), accentDark: Color(0xFF5B21B6),
    background: Color(0xFF13111C), card: Color(0xFF1E1A2E), border: Color(0xFF2E2A42),
    text: Color(0xFFE8E8F0), textSecondary: Color(0xFF8888AA), textHint: Color(0xFF55557A),
  ),
  AppPalette.oceanBlue: PaletteInfo(
    nombre: "Ocean Blue", emoji: "🔵", isDark: true,
    accent: Color(0xFF2563EB), accentDark: Color(0xFF1D4ED8),
    background: Color(0xFF0F1623), card: Color(0xFF1A2235), border: Color(0xFF243048),
    text: Color(0xFFE0E8F8), textSecondary: Color(0xFF7090B0), textHint: Color(0xFF405070),
  ),
  AppPalette.forestGreen: PaletteInfo(
    nombre: "Forest Green", emoji: "🟢", isDark: true,
    accent: Color(0xFF16A34A), accentDark: Color(0xFF15803D),
    background: Color(0xFF0F1A13), card: Color(0xFF162212), border: Color(0xFF1E3320),
    text: Color(0xFFE0F0E8), textSecondary: Color(0xFF70A080), textHint: Color(0xFF406050),
  ),
  AppPalette.burnedOrange: PaletteInfo(
    nombre: "Burned Orange", emoji: "🟠", isDark: true,
    accent: Color(0xFFEA580C), accentDark: Color(0xFFC2410C),
    background: Color(0xFF1A1208), card: Color(0xFF2A1E0F), border: Color(0xFF3A2A18),
    text: Color(0xFFF0E8D8), textSecondary: Color(0xFFAA8860), textHint: Color(0xFF705840),
  ),
  AppPalette.pureWhite: PaletteInfo(
    nombre: "Pure White", emoji: "⚪", isDark: false,
    accent: Color(0xFF7C3AED), accentDark: Color(0xFF5B21B6),
    background: Color(0xFFF5F5F7), card: Color(0xFFFFFFFF), border: Color(0xFFE0E0E8),
    text: Color(0xFF1A1A2E), textSecondary: Color(0xFF666680), textHint: Color(0xFFAAAAC0),
  ),
  AppPalette.roseLight: PaletteInfo(
    nombre: "Rose", emoji: "🌸", isDark: false,
    accent: Color(0xFFDB2777), accentDark: Color(0xFFBE185D),
    background: Color(0xFFFFF5F7), card: Color(0xFFFFFFFF), border: Color(0xFFFFD6E0),
    text: Color(0xFF2D1A20), textSecondary: Color(0xFF806070), textHint: Color(0xFFC0A0A8),
  ),
  AppPalette.skyLight: PaletteInfo(
    nombre: "Sky", emoji: "🌊", isDark: false,
    accent: Color(0xFF0284C7), accentDark: Color(0xFF0369A1),
    background: Color(0xFFF0F7FF), card: Color(0xFFFFFFFF), border: Color(0xFFD0E8F8),
    text: Color(0xFF0F2033), textSecondary: Color(0xFF507090), textHint: Color(0xFF90B0C8),
  ),
};

// ============================================================
// THEME CONTROLLER
// ============================================================
class ThemeController extends ChangeNotifier {
  static const _keyPalette = 'app_palette';
  AppPalette _palette = AppPalette.steelRed;

  AppPalette get palette => _palette;
  PaletteInfo get current => palettes[_palette]!;

  ThemeController();

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_keyPalette);
    if (saved != null) {
      _palette = AppPalette.values.firstWhere(
            (p) => p.name == saved,
        orElse: () => AppPalette.steelRed,
      );
    }
    notifyListeners();
  }

  // Método público para llamar desde main() y splash
  Future<void> loadPalette() async {
    await _load();
  }

  Future<void> setPalette(AppPalette p) async {
    _palette = p;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPalette, p.name);
    notifyListeners();
  }
}

// Instancia global — NO llama _load() en constructor, lo hace main()
final themeController = ThemeController();

// ============================================================
// APPCOLORS — acceso dinámico
// ============================================================
class AppColors {
  static PaletteInfo get _p => themeController.current;

  static Color get background    => _p.background;
  static Color get card          => _p.card;
  static Color get border        => _p.border;
  static Color get accent        => _p.accent;
  static Color get accentDark    => _p.accentDark;
  static Color get text          => _p.text;
  static Color get textSecondary => _p.textSecondary;
  static Color get textHint      => _p.textHint;
  static bool  get isDark        => _p.isDark;

  static const success = Color(0xFF27AE60);
  static const warning = Color(0xFFE67E22);
  static const info    = Color(0xFF2980B9);
  static const white   = Colors.white;
}

// ============================================================
// SNACKBAR GLOBAL
// ============================================================
class RS {
  static void snack(BuildContext context, String message, {Color? color}) {
    final bgColor = color ?? AppColors.info;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 3),
        content: _RSSnack(message: message, color: bgColor),
      ),
    );
  }

  static void ok(BuildContext context, String msg)   => snack(context, msg, color: AppColors.success);
  static void err(BuildContext context, String msg)  => snack(context, msg, color: AppColors.accent);
  static void warn(BuildContext context, String msg) => snack(context, msg, color: AppColors.warning);
  static void info(BuildContext context, String msg) => snack(context, msg, color: AppColors.info);
}

class _RSSnack extends StatefulWidget {
  final String message;
  final Color color;
  const _RSSnack({required this.message, required this.color});
  @override
  State<_RSSnack> createState() => _RSSnackState();
}

class _RSSnackState extends State<_RSSnack> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 320));
    _slide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  IconData get _icon {
    if (widget.color == AppColors.success) return Icons.check_circle_outline_rounded;
    if (widget.color == AppColors.accent)  return Icons.error_outline_rounded;
    if (widget.color == AppColors.warning) return Icons.warning_amber_rounded;
    return Icons.info_outline_rounded;
  }

  String get _label {
    if (widget.color == AppColors.success) return "Éxito";
    if (widget.color == AppColors.accent)  return "Error";
    if (widget.color == AppColors.warning) return "Aviso";
    return "Info";
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: widget.color.withOpacity(0.4), width: 1),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: widget.color.withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(_icon, color: widget.color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_label.toUpperCase(),
                    style: TextStyle(color: widget.color, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                const SizedBox(height: 2),
                Text(widget.message,
                    style: TextStyle(color: AppColors.text, fontSize: 13, fontWeight: FontWeight.w500, height: 1.3)),
              ],
            )),
          ]),
        ),
      ),
    );
  }
}

// ============================================================
// APP — escucha cambios de tema
// ============================================================
class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    themeController.addListener(_onThemeChange);
  }

  void _onThemeChange() {
    setState(() {});
    final isDark = themeController.current.isDark;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));
  }

  @override
  void dispose() {
    themeController.removeListener(_onThemeChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = themeController.current;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RealSteel',
      theme: ThemeData(
        brightness: p.isDark ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: p.background,
        colorScheme: ColorScheme(
          brightness: p.isDark ? Brightness.dark : Brightness.light,
          primary: p.accent,
          onPrimary: Colors.white,
          secondary: p.accent,
          onSecondary: Colors.white,
          error: Colors.red,
          onError: Colors.white,
          surface: p.background,
          onSurface: p.text,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: p.background,
          foregroundColor: p.text,
          elevation: 0,
          titleTextStyle: TextStyle(color: p.text, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: p.card,
          selectedItemColor: p.accent,
          unselectedItemColor: p.textSecondary,
          elevation: 0,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: p.card,
          contentTextStyle: TextStyle(color: p.text),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}