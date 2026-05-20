import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static String? userId;
  static String? nombre;
  static String? email;
  static String? gimnasio;

  static bool get isLoggedIn => userId != null;

  static void save({
    required String userId,
    required String nombre,
    required String email,
    String? gimnasio,
  }) {
    UserSession.userId = userId;
    UserSession.nombre = nombre;
    UserSession.email = email;
    UserSession.gimnasio = gimnasio;
  }

  // ── Logout: borra memoria Y disco ────────────────────────
  static Future<void> clear() async {
    userId = null;
    nombre = null;
    email = null;
    gimnasio = null;
    await _clearStorage();
  }

  // ── Guardar sesión en disco ───────────────────────────────
  static Future<void> saveToStorage({
    required String userId,
    required String nombre,
    required String email,
    String? gimnasio,
  }) async {
    save(userId: userId, nombre: nombre, email: email, gimnasio: gimnasio);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    await prefs.setString('nombre', nombre);
    await prefs.setString('email', email);
    if (gimnasio != null) {
      await prefs.setString('gimnasio', gimnasio);
    } else {
      await prefs.remove('gimnasio');
    }
  }

  // ── Cargar sesión desde disco ─────────────────────────────
  static Future<bool> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserId = prefs.getString('userId');
    if (savedUserId == null || savedUserId.isEmpty) return false;
    UserSession.userId = savedUserId;
    UserSession.nombre = prefs.getString('nombre');
    UserSession.email = prefs.getString('email');
    UserSession.gimnasio = prefs.getString('gimnasio');
    return true;
  }

  // ── Borrar sesión del disco ───────────────────────────────
  static Future<void> _clearStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('nombre');
    await prefs.remove('email');
    await prefs.remove('gimnasio');
  }
}