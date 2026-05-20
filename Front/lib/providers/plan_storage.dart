import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_session.dart';

class PlanStorage {
  static String get _key =>
      'plan_semana_${UserSession.userId ?? "guest"}';

  static final Map<String, List<String>> _defaultPlan = {
    "Lunes": [],
    "Martes": [],
    "Miércoles": [],
    "Jueves": [],
    "Viernes": [],
    "Sábado": [],
    "Domingo": [],
  };

  static Future<void> guardar(Map<String, List<String>> plan) async {
    // No guardar si el plan está completamente vacío
    // (evita sobreescribir con datos sin inicializar)
    final tieneAlgo = plan.values.any((v) => v.isNotEmpty);
    if (!tieneAlgo) {
      // Solo guardar vacío si ya existía una clave (el usuario lo borró a propósito)
      final prefs = await SharedPreferences.getInstance();
      final existe = prefs.containsKey(_key);
      if (!existe) return;
    }

    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> json =
    plan.map((dia, grupos) => MapEntry(dia, grupos));
    await prefs.setString(_key, jsonEncode(json));
  }

  static Future<Map<String, List<String>>> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_key);

    if (raw == null) return _copiaDefault();

    try {
      final Map<String, dynamic> json = jsonDecode(raw);
      final plan = json.map(
            (dia, grupos) => MapEntry(dia, List<String>.from(grupos)),
      );
      // Asegurarse de que todos los días existen aunque el JSON sea antiguo
      for (final dia in _defaultPlan.keys) {
        plan.putIfAbsent(dia, () => <String>[]);
      }
      return plan;
    } catch (_) {
      return _copiaDefault();
    }
  }

  static Map<String, List<String>> _copiaDefault() => {
    for (final e in _defaultPlan.entries) e.key: List<String>.from(e.value)
  };
}