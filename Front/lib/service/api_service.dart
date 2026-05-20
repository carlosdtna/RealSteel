import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/exercise.dart';
import '../models/supplement.dart';
import '../models/routine.dart';

class ApiService {
  static const String baseUrl = "https://apirealsteel.onrender.com";
  static const Duration _timeout = Duration(seconds: 15);
  static const Duration _timeoutEmail = Duration(seconds: 60);

  // ============================================================
  // 👤 USUARIOS
  // ============================================================

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/users/login"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"email": email, "password": password}),
    ).timeout(_timeout);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? "Error al iniciar sesión");
    }
  }

  static Future<void> createUser({
    required String userId,
    required String nombre,
    required String email,
    required String password,
    String? gimnasio,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/users/create"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "userId": userId,
        "nombre": nombre,
        "email": email,
        "password": password,
        "gimnasio": gimnasio,
      }),
    ).timeout(_timeout);

    if (response.statusCode != 200 && response.statusCode != 201) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? "Error al crear usuario");
    }
  }

  static Future<void> updateUser({
    required String userId,
    required String nombre,
    required String email,
    String? password, // ← opcional: solo se envía si el usuario quiere cambiarla
    String? gimnasio,
  }) async {
    // Solo incluir password en el body si se quiere cambiar
    final Map<String, dynamic> body = {
      "userId": userId,
      "nombre": nombre,
      "email": email,
      "gimnasio": gimnasio,
    };

    if (password != null && password.isNotEmpty) {
      body["password"] = password;
    }

    final response = await http.put(
      Uri.parse("$baseUrl/users/$userId"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(body),
    ).timeout(_timeout);

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? "Error al actualizar perfil");
    }
  }

  // ============================================================
  // 🔑 RECUPERACIÓN DE CONTRASEÑA
  // ============================================================

  static Future<void> solicitarCodigoReset(String email) async {
    final response = await http.post(
      Uri.parse("$baseUrl/users/password-reset/request"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"email": email}),
    ).timeout(_timeoutEmail);

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? "Error al enviar el código");
    }
  }

  static Future<void> confirmarResetPassword({
    required String email,
    required String codigo,
    required String nuevaPassword,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/users/password-reset/confirm"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "email": email,
        "codigo": codigo,
        "nuevaPassword": nuevaPassword,
      }),
    ).timeout(_timeoutEmail);

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? "Error al cambiar la contraseña");
    }
  }

  // ============================================================
  // 💪 EJERCICIOS
  // ============================================================

  static Future<List<Exercise>> getExercises() async {
    final response = await http
        .get(Uri.parse("$baseUrl/exercises/getAll"))
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Exercise.fromJson(e)).toList();
    } else {
      throw Exception("Error al cargar ejercicios");
    }
  }

  static Future<List<Exercise>> getExercisesByTipo(String tipo) async {
    final response = await http
        .get(Uri.parse("$baseUrl/exercises/tipo/$tipo"))
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Exercise.fromJson(e)).toList();
    } else {
      throw Exception("Error al cargar ejercicios de tipo $tipo");
    }
  }

  static Future<List<Exercise>> getExercisesByMusculo(String musculo) async {
    final response = await http
        .get(Uri.parse("$baseUrl/exercises/musculo/$musculo"))
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Exercise.fromJson(e)).toList();
    } else {
      throw Exception("Error al cargar ejercicios de $musculo");
    }
  }

  // ============================================================
  // 🧴 SUPLEMENTOS
  // ============================================================

  static Future<List<Supplement>> getSupplements() async {
    final response = await http
        .get(Uri.parse("$baseUrl/supplements/getAll"))
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Supplement.fromJson(e)).toList();
    } else {
      throw Exception("Error al cargar suplementos");
    }
  }

  // ============================================================
  // 📋 RUTINAS
  // ============================================================

  static Future<List<Routine>> getRutinasByUser(String userId) async {
    final response = await http
        .get(Uri.parse("$baseUrl/routines/user/$userId"))
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Routine.fromJson(e)).toList();
    } else {
      throw Exception("Error al cargar rutinas");
    }
  }

  static Future<Routine> createRutina({
    required String userId,
    required String nombre,
    String? descripcion,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/routines"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "userId": userId,
        "nombre": nombre,
        "descripcion": descripcion,
      }),
    ).timeout(_timeout);

    if (response.statusCode == 201) {
      return Routine.fromJson(json.decode(response.body));
    } else {
      throw Exception("Error al crear rutina");
    }
  }

  static Future<void> deleteRutina(int rutinaId) async {
    final response = await http
        .delete(Uri.parse("$baseUrl/routines/$rutinaId"))
        .timeout(_timeout);

    if (response.statusCode != 204) {
      throw Exception("Error al eliminar rutina");
    }
  }

  // ============================================================
  // 📅 EJERCICIOS DE RUTINA
  // ============================================================

  static Future<List<Map<String, dynamic>>> getEjerciciosByRutina(int rutinaId) async {
    final response = await http
        .get(Uri.parse("$baseUrl/routine-exercises/routine/$rutinaId"))
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception("Error al cargar ejercicios de la rutina");
    }
  }

  static Future<List<Map<String, dynamic>>> getEjerciciosByRutinaYDia(int rutinaId, String dia) async {
    final response = await http
        .get(Uri.parse("$baseUrl/routine-exercises/routine/$rutinaId/dia/$dia"))
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception("Error al cargar ejercicios del día");
    }
  }

  static Future<Map<String, dynamic>> addEjercicioARutina({
    required int rutinaId,
    required int ejercicioId,
    required String diaSemana,
    int? orden,
    int? seriesObjetivo,
    int? repsObjetivo,
    double? pesoObjetivo,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/routine-exercises/routine/$rutinaId"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "exerciseId": ejercicioId,
        "diaSemana": diaSemana,
        "orden": orden,
        "seriesObjetivo": seriesObjetivo,
        "repsObjetivo": repsObjetivo,
        "pesoObjetivo": pesoObjetivo,
      }),
    ).timeout(_timeout);

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception("Error al añadir ejercicio a rutina");
    }
  }

  static Future<void> deleteEjercicioDeRutina(int id) async {
    final response = await http
        .delete(Uri.parse("$baseUrl/routine-exercises/$id"))
        .timeout(_timeout);

    if (response.statusCode != 204) {
      throw Exception("Error al eliminar ejercicio de rutina");
    }
  }

  // ============================================================
  // 🏋️ SESIONES
  // ============================================================

  static Future<Map<String, dynamic>> createSesion({
    required String userId,
    required String fecha,
    required String horaInicio,
    int? rutinaId,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/sessions/user/$userId"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "fecha": fecha,
        "horaInicio": horaInicio,
        "rutinaId": rutinaId,
      }),
    ).timeout(_timeout);

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception("Error al crear sesión");
    }
  }

  static Future<void> finalizarSesion({
    required int sessionId,
    required String horaFin,
  }) async {
    final response = await http.patch(
      Uri.parse("$baseUrl/sessions/$sessionId/finalizar?horaFin=$horaFin"),
      headers: {"Content-Type": "application/json"},
    ).timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception("Error al finalizar sesión");
    }
  }

  static Future<List<Map<String, dynamic>>> getSesionesByUser(String userId) async {
    final response = await http
        .get(Uri.parse("$baseUrl/sessions/user/$userId"))
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception("Error al cargar sesiones");
    }
  }

  // ============================================================
  // 📊 RECORDS (series individuales)
  // ============================================================

  static Future<void> createRecord({
    required int sessionId,
    required int exerciseId,
    required int numeroSerie,
    required double peso,
    required int repeticiones,
    required bool completado,
  }) async {
    final now = DateTime.now();
    final horaRegistro =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

    final response = await http.post(
      Uri.parse("$baseUrl/records/session/$sessionId"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "exerciseId": exerciseId,
        "numeroSerie": numeroSerie,
        "peso": peso,
        "repeticiones": repeticiones,
        "horaRegistro": horaRegistro,
        "completado": completado,
      }),
    ).timeout(_timeout);

    if (response.statusCode != 201) {
      throw Exception("Error al guardar serie");
    }
  }

  static Future<List<Map<String, dynamic>>> getHistorialEjercicio({
    required String userId,
    required int exerciseId,
  }) async {
    final response = await http
        .get(Uri.parse("$baseUrl/records/user/$userId/exercise/$exerciseId"))
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception("Error al cargar historial");
    }
  }
}