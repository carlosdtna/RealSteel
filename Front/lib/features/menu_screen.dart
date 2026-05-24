import 'dart:async';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../main.dart';
import '../providers/user_session.dart';
import '../service/api_service.dart';
import '../models/routine.dart';
import '../models/exercise.dart';
import 'supplements_screen.dart';
import 'login_screen.dart';
import 'exercise_screen.dart';
import 'gym_map_screen.dart';
import '../providers/plan_storage.dart';
import 'profile_screen.dart';
import 'chat_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int _currentIndex = 0;
  bool _planCargado = false;

  Map<String, List<String>> planSemana = {
    "Lunes": [], "Martes": [], "Miércoles": [],
    "Jueves": [], "Viernes": [], "Sábado": [], "Domingo": [],
  };

  @override
  void initState() {
    super.initState();
    _cargarPlan();
    themeController.addListener(_onThemeChange);
  }

  void _onThemeChange() => setState(() {});

  @override
  void dispose() {
    themeController.removeListener(_onThemeChange);
    super.dispose();
  }

  Future<void> _cargarPlan() async {
    final plan = await PlanStorage.cargar();
    setState(() { planSemana = plan; _planCargado = true; });
  }

  void _updatePlan(String dia, List<String> grupos) {
    if (!_planCargado) return;
    setState(() => planSemana[dia] = grupos);
    PlanStorage.guardar(planSemana);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _InicioTab(planSemana: planSemana, onPlanUpdate: _updatePlan),
          _RutinaTab(planSemana: planSemana),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          backgroundColor: AppColors.card,
          selectedItemColor: AppColors.accent,
          unselectedItemColor: AppColors.textSecondary,
          elevation: 0,
          selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: "Inicio"),
            BottomNavigationBarItem(icon: Icon(Icons.fitness_center_outlined), activeIcon: Icon(Icons.fitness_center), label: "Rutina"),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// TEMPORIZADOR DE DESCANSO
// ============================================================
void _mostrarTimer(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _TimerModal(segundosInicio: 60),
  );
}

class _TimerModal extends StatefulWidget {
  final int segundosInicio;
  const _TimerModal({required this.segundosInicio});

  @override
  State<_TimerModal> createState() => _TimerModalState();
}

class _TimerModalState extends State<_TimerModal> with SingleTickerProviderStateMixin {
  late int _segundos;
  late int _total;
  Timer? _timer;
  bool _corriendo = false;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _segundos = widget.segundosInicio;
    _total = widget.segundosInicio;
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _iniciar();
  }

  void _iniciar() {
    setState(() => _corriendo = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_segundos <= 0) { t.cancel(); setState(() => _corriendo = false); _pulseCtrl.stop(); }
      else { setState(() => _segundos--); }
    });
  }

  void _reiniciar() {
    _timer?.cancel();
    setState(() { _segundos = _total; _corriendo = false; });
    _pulseCtrl.reset();
    _iniciar();
    _pulseCtrl.repeat(reverse: true);
  }

  void _ajustar(int delta) {
    setState(() {
      _segundos = (_segundos + delta).clamp(0, 300);
      _total = (_total + delta).clamp(5, 300);
    });
  }

  String _fmt(int s) => "${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}";

  @override
  void dispose() { _timer?.cancel(); _pulseCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final progreso = _total > 0 ? _segundos / _total : 0.0;
    final terminado = _segundos <= 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 36, height: 3, margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
        Row(children: [
          Icon(Icons.timer_outlined, color: AppColors.accent, size: 18),
          const SizedBox(width: 8),
          Text("DESCANSO", style: TextStyle(color: AppColors.text, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 2)),
          const Spacer(),
          GestureDetector(onTap: () => Navigator.pop(context),
              child: Icon(Icons.close, color: AppColors.textSecondary, size: 20)),
        ]),
        const SizedBox(height: 24),
        SizedBox(
          width: 160, height: 160,
          child: Stack(alignment: Alignment.center, children: [
            SizedBox(width: 160, height: 160,
                child: CircularProgressIndicator(
                  value: progreso, strokeWidth: 8,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(terminado ? AppColors.success : AppColors.accent),
                )),
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              terminado
                  ? Text("✓", style: TextStyle(color: AppColors.success, fontSize: 48, fontWeight: FontWeight.w900))
                  : AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, __) => Opacity(
                  opacity: _corriendo ? (0.6 + _pulseCtrl.value * 0.4) : 1.0,
                  child: Text(_fmt(_segundos),
                      style: TextStyle(color: AppColors.text, fontSize: 38, fontWeight: FontWeight.w900, letterSpacing: 2)),
                ),
              ),
              Text(
                terminado ? "¡A por la siguiente!" : "segundos",
                style: TextStyle(color: terminado ? AppColors.success : AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ]),
          ]),
        ),
        const SizedBox(height: 24),
        if (!terminado)
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _AjusteBtn(label: "-15s", onTap: () => _ajustar(-15)),
            const SizedBox(width: 12),
            _AjusteBtn(label: "-5s", onTap: () => _ajustar(-5)),
            const SizedBox(width: 12),
            _AjusteBtn(label: "+5s", onTap: () => _ajustar(5)),
            const SizedBox(width: 12),
            _AjusteBtn(label: "+15s", onTap: () => _ajustar(15)),
          ]),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _reiniciar,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text("Reiniciar", style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: terminado ? AppColors.success : AppColors.accent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(terminado ? "¡Listo!" : "Saltar", style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            ),
          ),
        ]),
      ]),
    );
  }
}

class _AjusteBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _AjusteBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border)),
        child: Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ============================================================
// TAB INICIO
// ============================================================
class _InicioTab extends StatefulWidget {
  final Map<String, List<String>> planSemana;
  final Function(String, List<String>) onPlanUpdate;
  const _InicioTab({required this.planSemana, required this.onPlanUpdate});

  @override
  State<_InicioTab> createState() => _InicioTabState();
}

class _InicioTabState extends State<_InicioTab> {
  int _racha = 0;
  bool _loadingRacha = true;

  @override
  void initState() {
    super.initState();
    _calcularRacha();
    themeController.addListener(_onThemeChange);
  }

  void _onThemeChange() => setState(() {});

  @override
  void dispose() {
    themeController.removeListener(_onThemeChange);
    super.dispose();
  }

  Future<void> _calcularRacha() async {
    if (UserSession.userId == null) { setState(() => _loadingRacha = false); return; }
    try {
      final sesiones = await ApiService.getSesionesByUser(UserSession.userId!.toString());
      // Solo contar sesiones finalizadas (con horaFin no nulo)
      final sesionesFinalizadas = sesiones.where((s) => s['horaFin'] != null).toList();
      final fechas = sesionesFinalizadas.map((s) => s['fecha'] as String? ?? '').where((f) => f.isNotEmpty).toSet().toList()..sort((a, b) => b.compareTo(a));
      int racha = 0;
      DateTime dia = DateTime.now();
      for (int i = 0; i < 365; i++) {
        final diaStr = "${dia.year}-${dia.month.toString().padLeft(2, '0')}-${dia.day.toString().padLeft(2, '0')}";
        if (fechas.contains(diaStr)) { racha++; dia = dia.subtract(const Duration(days: 1)); }
        else { if (i == 0) { dia = dia.subtract(const Duration(days: 1)); continue; } break; }
      }
      setState(() { _racha = racha; _loadingRacha = false; });
    } catch (_) { setState(() => _loadingRacha = false); }
  }

  String _getDiaHoy() {
    const dias = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"];
    return dias[DateTime.now().weekday - 1];
  }

  String _mensajeRacha(int racha) {
    if (racha == 0) return "¡Empieza tu racha hoy!";
    if (racha == 1) return "¡Primer día! Sigue así 💪";
    if (racha < 5) return "¡Vas bien! No lo dejes ahora";
    if (racha < 10) return "¡Imparable! Racha en llamas 🔥";
    if (racha < 30) return "¡Eres una máquina! 🏆";
    return "¡Leyenda del hierro! 🥇";
  }

  @override
  Widget build(BuildContext context) {
    final diaHoy = _getDiaHoy();
    final gruposHoy = widget.planSemana[diaHoy] ?? [];
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background, elevation: 0,
        title: Text("REALSTEEL", style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w800, letterSpacing: 3, fontSize: 18)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: PopupMenuButton<String>(
              color: AppColors.card,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppColors.border)),
              onSelected: (v) {
                if (v == "logout") { UserSession.clear(); Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false); }
                if (v == "perfil") { Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())); }
              },
              itemBuilder: (_) => [
                PopupMenuItem(enabled: false, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(UserSession.nombre ?? "Usuario", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text)),
                  if (UserSession.gimnasio != null) Text(UserSession.gimnasio!, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ])),
                const PopupMenuDivider(),
                PopupMenuItem(value: "perfil", child: Row(children: [Icon(Icons.person_outline, color: AppColors.textSecondary, size: 16), const SizedBox(width: 8), Text("Mi perfil", style: TextStyle(color: AppColors.text, fontSize: 14))])),
                const PopupMenuDivider(),
                PopupMenuItem(value: "logout", child: Row(children: [Icon(Icons.logout, color: AppColors.textSecondary, size: 16), const SizedBox(width: 8), Text("Cerrar sesión", style: TextStyle(color: AppColors.text, fontSize: 14))])),
              ],
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
                child: Center(child: Text((UserSession.nombre ?? "U")[0].toUpperCase(),
                    style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700, fontSize: 15))),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Hola, ${UserSession.nombre ?? 'campeón'}", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.text)),
          const SizedBox(height: 4),
          Text(gruposHoy.isEmpty ? "Planifica tu semana en el calendario" : "Hoy toca — ${gruposHoy.join(' + ')}",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 20),
          _RachaCard(racha: _racha, isLoading: _loadingRacha, mensaje: _mensajeRacha(_racha)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                builder: (_) => _CalendarioModal(planSemana: widget.planSemana, onUpdate: widget.onPlanUpdate)),
            child: Container(
              width: double.infinity, padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
              child: Row(children: [
                Container(width: 44, height: 44,
                    decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.calendar_today, color: AppColors.accent, size: 22)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("MI SEMANA", style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w700, fontSize: 14, letterSpacing: 1)),
                  const SizedBox(height: 3),
                  Text(_resumenSemana(), style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ])),
                Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          _MiniSemana(planSemana: widget.planSemana),
          const SizedBox(height: 28),
          Text("BIBLIOTECA", style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 2)),
          const SizedBox(height: 12),
          _buildCard(context, title: "Gimnasio", subtitle: "Ejercicios con equipamiento", icon: Icons.fitness_center, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExerciseScreen(tipo: 'gimnasio')))),
          const SizedBox(height: 10),
          _buildCard(context, title: "En Casa", subtitle: "Calistenia sin equipamiento", icon: Icons.home_outlined, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExerciseScreen(tipo: 'casa')))),
          const SizedBox(height: 10),
          _buildCard(context, title: "Suplementación", subtitle: "Proteínas, creatina y más", icon: Icons.science_outlined, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SupplementsScreen()))),
          const SizedBox(height: 10),
          _buildCard(context, title: "Gimnasios Cercanos", subtitle: "Encuentra el mejor gimnasio", icon: Icons.location_on_outlined, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GymMapScreen()))),
          const SizedBox(height: 10),
          _buildCard(context, title: "RealSteel AI", subtitle: "Tu asistente de entrenamiento", icon: Icons.psychology_outlined, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()))),
          const SizedBox(height: 40),
        ]),
      ),
    );
  }

  String _resumenSemana() {
    final n = widget.planSemana.values.where((v) => v.isNotEmpty).length;
    return n == 0 ? "Sin planificar — toca para configurar" : "$n días planificados";
  }

  Widget _buildCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(onTap: onTap,
      child: Container(padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
        child: Row(children: [
          Container(width: 42, height: 42,
              decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: AppColors.accent, size: 22)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w600, fontSize: 15)),
            Text(subtitle, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ])),
          Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
        ]),
      ),
    );
  }
}

// ============================================================
// CARD RACHA
// ============================================================
class _RachaCard extends StatelessWidget {
  final int racha; final bool isLoading; final String mensaje;
  const _RachaCard({required this.racha, required this.isLoading, required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.accent.withOpacity(0.15), AppColors.accent.withOpacity(0.05)], begin: Alignment.centerLeft, end: Alignment.centerRight),
        borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: isLoading
          ? SizedBox(height: 40, child: Center(child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2)))
          : Row(children: [
        Stack(clipBehavior: Clip.none, children: [
          ClipRRect(borderRadius: BorderRadius.circular(10),
              child: Image.asset('assets/images/robotin.jpg', width: 56, height: 56, fit: BoxFit.cover)),
          if (racha >= 3) Positioned(top: -8, right: -8,
              child: Container(padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(color: AppColors.background, shape: BoxShape.circle, border: Border.all(color: AppColors.accent.withOpacity(0.3))),
                  child: const Text("🔥", style: TextStyle(fontSize: 14)))),
        ]),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text("$racha", style: TextStyle(color: racha > 0 ? AppColors.accent : AppColors.textSecondary, fontSize: 36, fontWeight: FontWeight.w900, height: 1)),
            const SizedBox(width: 6),
            Padding(padding: const EdgeInsets.only(bottom: 4),
                child: Text("días seguidos", style: TextStyle(color: AppColors.textSecondary, fontSize: 13))),
          ]),
          const SizedBox(height: 4),
          Text(mensaje, style: TextStyle(color: AppColors.text, fontSize: 12, fontWeight: FontWeight.w500)),
        ])),
        Icon(racha > 0 ? Icons.local_fire_department : Icons.fitness_center,
            color: racha > 0 ? AppColors.accent : AppColors.textSecondary, size: 28),
      ]),
    );
  }
}

// ============================================================
// MINI SEMANA HORIZONTAL
// ============================================================
class _MiniSemana extends StatelessWidget {
  final Map<String, List<String>> planSemana;
  const _MiniSemana({required this.planSemana});

  @override
  Widget build(BuildContext context) {
    final hoy = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"][DateTime.now().weekday - 1];
    return SizedBox(height: 64, child: ListView(scrollDirection: Axis.horizontal, children: planSemana.entries.map((e) {
      final isHoy = e.key == hoy; final tiene = e.value.isNotEmpty;
      final texto = tiene ? (e.value.length == 1 ? (e.value[0].length > 5 ? e.value[0].substring(0, 5) : e.value[0]) : "${e.value.length} grupos") : "—";
      return Container(
        margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
            color: isHoy ? AppColors.accent.withOpacity(0.15) : AppColors.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isHoy ? AppColors.accent : AppColors.border, width: isHoy ? 1.5 : 0.5)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(e.key.substring(0, 3).toUpperCase(), style: TextStyle(color: isHoy ? AppColors.accent : AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
          const SizedBox(height: 3),
          Text(texto, style: TextStyle(color: tiene ? AppColors.text : AppColors.textHint, fontSize: 11)),
        ]),
      );
    }).toList()));
  }
}

// ============================================================
// MODAL CALENDARIO
// ============================================================
class _CalendarioModal extends StatefulWidget {
  final Map<String, List<String>> planSemana;
  final Function(String, List<String>) onUpdate;
  const _CalendarioModal({required this.planSemana, required this.onUpdate});

  @override
  State<_CalendarioModal> createState() => _CalendarioModalState();
}

class _CalendarioModalState extends State<_CalendarioModal> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final List<String> grupos = ["Pecho", "Espalda", "Bíceps", "Tríceps", "Pierna", "Hombro", "Abdominales", "Glúteos", "Descanso"];

  String _getDia(DateTime day) {
    const d = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"];
    return d[day.weekday - 1];
  }

  void _editarDia(String dia) async {
    final seleccionados = List<String>.from(widget.planSemana[dia] ?? []);
    final result = await showDialog<List<String>>(context: context,
        builder: (_) => _DialogSeleccionGrupos(dia: dia, grupos: grupos, seleccionados: seleccionados));
    if (result != null) { widget.onUpdate(dia, result); setState(() {}); }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88, minChildSize: 0.5, maxChildSize: 0.95,
      builder: (_, scroll) => Container(
        decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(top: BorderSide(color: AppColors.border))),
        child: Column(children: [
          Container(margin: const EdgeInsets.only(top: 12, bottom: 16), width: 36, height: 3,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          Text("MI SEMANA", style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 2)),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
              child: TableCalendar(
                firstDay: DateTime.utc(2024, 1, 1), lastDay: DateTime.utc(2027, 12, 31), focusedDay: _focusedDay,
                selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
                onDaySelected: (sel, foc) { setState(() { _selectedDay = sel; _focusedDay = foc; }); _editarDia(_getDia(sel)); },
                calendarStyle: CalendarStyle(
                  defaultTextStyle: TextStyle(color: AppColors.text, fontSize: 13),
                  weekendTextStyle: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  selectedDecoration: BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                  todayDecoration: BoxDecoration(color: AppColors.accent.withOpacity(0.2), shape: BoxShape.circle),
                  todayTextStyle: TextStyle(color: AppColors.text), outsideDaysVisible: false,
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false, titleCentered: true,
                  titleTextStyle: TextStyle(color: AppColors.text, fontSize: 15, fontWeight: FontWeight.w600),
                  leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.textSecondary),
                  rightChevronIcon: Icon(Icons.chevron_right, color: AppColors.textSecondary),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  weekendStyle: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(child: ListView(controller: scroll, padding: const EdgeInsets.symmetric(horizontal: 16),
            children: widget.planSemana.entries.map((e) {
              final isHoy = e.key == ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"][DateTime.now().weekday - 1];
              final tiene = e.value.isNotEmpty;
              return GestureDetector(onTap: () => _editarDia(e.key),
                child: Container(margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isHoy ? AppColors.accent : AppColors.border, width: isHoy ? 1.5 : 0.5)),
                  child: Row(children: [
                    SizedBox(width: 90, child: Text(e.key,
                        style: TextStyle(color: isHoy ? AppColors.accent : AppColors.text, fontWeight: isHoy ? FontWeight.w600 : FontWeight.normal, fontSize: 14))),
                    Expanded(child: tiene
                        ? Wrap(spacing: 4, children: e.value.map((g) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                        child: Text(g, style: TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.w600)))).toList())
                        : Text("Sin planificar", style: TextStyle(color: AppColors.textHint, fontSize: 13))),
                    Icon(Icons.edit_outlined, size: 14, color: AppColors.textHint),
                  ]),
                ),
              );
            }).toList(),
          )),
        ]),
      ),
    );
  }
}

// ============================================================
// DIALOG SELECCIÓN MÚLTIPLE DE GRUPOS
// ============================================================
class _DialogSeleccionGrupos extends StatefulWidget {
  final String dia; final List<String> grupos; final List<String> seleccionados;
  const _DialogSeleccionGrupos({required this.dia, required this.grupos, required this.seleccionados});

  @override
  State<_DialogSeleccionGrupos> createState() => _DialogSeleccionGruposState();
}

class _DialogSeleccionGruposState extends State<_DialogSeleccionGrupos> {
  late List<String> _seleccionados;

  @override
  void initState() { super.initState(); _seleccionados = List.from(widget.seleccionados); }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: AppColors.border)),
      title: Text(widget.dia, style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w700, letterSpacing: 1)),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Selecciona uno o más grupos", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: widget.grupos.map((g) {
          final sel = _seleccionados.contains(g);
          return GestureDetector(
            onTap: () { setState(() {
              if (g == "Descanso") { _seleccionados = sel ? [] : ["Descanso"]; }
              else { _seleccionados.remove("Descanso"); if (sel) _seleccionados.remove(g); else _seleccionados.add(g); }
            }); },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                  color: sel ? AppColors.accent : AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: sel ? AppColors.accent : AppColors.border)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                if (sel) ...[Icon(Icons.check, size: 12, color: Colors.white), const SizedBox(width: 4)],
                Text(g, style: TextStyle(color: sel ? Colors.white : AppColors.text, fontSize: 13, fontWeight: sel ? FontWeight.w600 : FontWeight.normal)),
              ]),
            ),
          );
        }).toList()),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, <String>[]),
            child: Text("Limpiar", style: TextStyle(color: AppColors.textSecondary))),
        ElevatedButton(onPressed: () => Navigator.pop(context, _seleccionados),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text("Confirmar")),
      ],
    );
  }
}

// ============================================================
// TAB RUTINA
// ============================================================
class _RutinaTab extends StatefulWidget {
  final Map<String, List<String>> planSemana;
  const _RutinaTab({required this.planSemana});

  @override
  State<_RutinaTab> createState() => _RutinaTabState();
}

class _RutinaTabState extends State<_RutinaTab> {
  List<Routine> rutinas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
    themeController.addListener(_onThemeChange);
  }

  void _onThemeChange() => setState(() {});

  @override
  void dispose() {
    themeController.removeListener(_onThemeChange);
    super.dispose();
  }

  Future<void> _load() async {
    if (UserSession.userId == null) return;
    try {
      final data = await ApiService.getRutinasByUser(UserSession.userId!);
      setState(() { rutinas = data; isLoading = false; });
    } catch (_) { setState(() => isLoading = false); }
  }

  String _getDiaHoy() {
    const d = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"];
    return d[DateTime.now().weekday - 1];
  }

  Future<void> _crearRutina() async {
    final c = TextEditingController();
    final nombre = await showDialog<String>(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: AppColors.border)),
      title: Text("NUEVA RUTINA", style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w700, letterSpacing: 1, fontSize: 16)),
      content: TextField(controller: c, autofocus: true, style: TextStyle(color: AppColors.text),
          decoration: InputDecoration(hintText: "Nombre de la rutina", hintStyle: TextStyle(color: AppColors.textHint),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.accent, width: 1.5)))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancelar", style: TextStyle(color: AppColors.textSecondary))),
        ElevatedButton(onPressed: () => Navigator.pop(context, c.text),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text("Siguiente")),
      ],
    ));
    if (nombre == null || nombre.isEmpty || UserSession.userId == null) return;
    Routine rutina;
    try { rutina = await ApiService.createRutina(userId: UserSession.userId!, nombre: nombre); }
    catch (e) { if (mounted) RS.err(context, "Error: $e"); return; }
    if (!mounted) return;
    await Navigator.push(context, MaterialPageRoute(builder: (_) => _ConfigurarRutinaScreen(rutina: rutina, planSemana: widget.planSemana, onGuardado: _load)));
  }

  @override
  Widget build(BuildContext context) {
    final diaHoy = _getDiaHoy();
    final gruposHoy = widget.planSemana[diaHoy] ?? [];
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background, elevation: 0,
        title: Text("MIS RUTINAS", style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w800, letterSpacing: 2, fontSize: 16)),
        actions: [Padding(padding: const EdgeInsets.only(right: 16), child: GestureDetector(onTap: _crearRutina,
            child: Container(width: 36, height: 36,
                decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.add, color: Colors.white, size: 20))))],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2))
          : SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: double.infinity, padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
            child: Row(children: [
              Container(width: 40, height: 40,
                  decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.today, color: AppColors.accent, size: 20)),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(diaHoy.toUpperCase(), style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 1)),
                Text(gruposHoy.isEmpty ? "Sin grupo asignado" : gruposHoy.join(' + '),
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ]),
            ])),
        const SizedBox(height: 24),
        if (rutinas.isEmpty) _emptyState()
        else ...[
          Text("RUTINAS", style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 2)),
          const SizedBox(height: 12),
          ...rutinas.map((r) => _RutinaCard(
            rutina: r, gruposHoy: gruposHoy, diaHoy: diaHoy,
            onIniciar: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _EntrenamientoScreen(rutina: r, gruposHoy: gruposHoy, diaHoy: diaHoy))).then((_) => _load()),
            onEditar: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _ConfigurarRutinaScreen(rutina: r, planSemana: widget.planSemana, onGuardado: _load))),
            onDelete: () async { await ApiService.deleteRutina(r.rutinaId); _load(); },
          )),
        ],
      ])),
    );
  }

  Widget _emptyState() => Center(child: Column(children: [
    const SizedBox(height: 60),
    Image.asset('assets/images/robotin.jpg', width: 100, height: 100),
    const SizedBox(height: 16),
    Text("Sin rutinas", style: TextStyle(color: AppColors.text, fontSize: 17, fontWeight: FontWeight.w600)),
    const SizedBox(height: 6),
    Text("Pulsa + para crear tu primera rutina", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
    const SizedBox(height: 24),
    ElevatedButton.icon(onPressed: _crearRutina, icon: const Icon(Icons.add, size: 18), label: const Text("Crear rutina"),
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
  ]));
}

// ============================================================
// CARD DE RUTINA
// ============================================================
class _RutinaCard extends StatelessWidget {
  final Routine rutina; final List<String> gruposHoy; final String diaHoy;
  final VoidCallback onIniciar; final VoidCallback onEditar; final VoidCallback onDelete;
  const _RutinaCard({required this.rutina, required this.gruposHoy, required this.diaHoy, required this.onIniciar, required this.onEditar, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(rutina.nombre, style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w700))),
          PopupMenuButton<String>(
            color: AppColors.card,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: AppColors.border)),
            icon: Icon(Icons.more_vert, color: AppColors.textSecondary, size: 20),
            onSelected: (v) { if (v == "editar") onEditar(); if (v == "delete") onDelete(); },
            itemBuilder: (_) => [
              PopupMenuItem(value: "editar", child: Row(children: [Icon(Icons.edit_outlined, color: AppColors.textSecondary, size: 16), const SizedBox(width: 8), Text("Editar ejercicios", style: TextStyle(color: AppColors.text, fontSize: 14))])),
              PopupMenuItem(value: "delete", child: Row(children: [Icon(Icons.delete_outline, color: AppColors.accent, size: 16), const SizedBox(width: 8), Text("Eliminar", style: TextStyle(color: AppColors.accent, fontSize: 14))])),
            ],
          ),
        ]),
        if (rutina.descripcion != null && rutina.descripcion!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(rutina.descripcion!, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ],
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: OutlinedButton.icon(
              onPressed: onEditar,
              icon: Icon(Icons.edit_outlined, size: 16, color: AppColors.textSecondary),
              label: Text("EDITAR", style: TextStyle(color: AppColors.textSecondary, fontSize: 12, letterSpacing: 1)),
              style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.border), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 12)))),
          const SizedBox(width: 10),
          Expanded(flex: 2, child: ElevatedButton.icon(
              onPressed: onIniciar,
              icon: const Icon(Icons.play_arrow, size: 18),
              label: const Text("INICIAR", style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1.5, fontSize: 13)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 12)))),
        ]),
      ]),
    );
  }
}

// ============================================================
// PANTALLA CONFIGURAR RUTINA
// ============================================================
class _ConfigurarRutinaScreen extends StatefulWidget {
  final Routine rutina; final Map<String, List<String>> planSemana; final VoidCallback onGuardado;
  const _ConfigurarRutinaScreen({required this.rutina, required this.planSemana, required this.onGuardado});

  @override
  State<_ConfigurarRutinaScreen> createState() => _ConfigurarRutinaScreenState();
}

class _ConfigurarRutinaScreenState extends State<_ConfigurarRutinaScreen> {
  final List<String> _dias = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"];
  String _diaSeleccionado = "Lunes";
  Map<String, List<Map<String, dynamic>>> _ejerciciosGuardados = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _diaSeleccionado = _dias[DateTime.now().weekday - 1];
    _cargarEjerciciosGuardados();
    themeController.addListener(_onThemeChange);
  }

  void _onThemeChange() => setState(() {});

  @override
  void dispose() {
    themeController.removeListener(_onThemeChange);
    super.dispose();
  }

  Future<void> _cargarEjerciciosGuardados() async {
    setState(() => _isLoading = true);
    try {
      final todos = await ApiService.getEjerciciosByRutina(widget.rutina.rutinaId);
      final Map<String, List<Map<String, dynamic>>> mapa = {};
      for (final dia in _dias) {
        mapa[dia] = todos.where((e) => e['diaSemana'] == dia).map((e) => {
          'routineExerciseId': e['id'], 'id': e['exercise']['ejercicioId'],
          'nombre': e['exercise']['nombre'], 'musculo': e['exercise']['grupoMuscular'],
          'seriesObjetivo': e['seriesObjetivo'], 'repsObjetivo': e['repsObjetivo'],
        }).toList();
      }
      setState(() { _ejerciciosGuardados = mapa; _isLoading = false; });
    } catch (e) { setState(() => _isLoading = false); }
  }

  Future<void> _agregarEjercicio() async {
    final gruposDelDia = widget.planSemana[_diaSeleccionado] ?? [];
    final ejercicio = await showModalBottomSheet<Exercise>(context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
        builder: (_) => _SelectorEjercicioModal(gruposHoy: gruposDelDia));
    if (ejercicio == null) return;
    try {
      await ApiService.addEjercicioARutina(rutinaId: widget.rutina.rutinaId, ejercicioId: ejercicio.id, diaSemana: _diaSeleccionado, seriesObjetivo: 4, repsObjetivo: 10);
      await _cargarEjerciciosGuardados();
    } catch (e) { if (mounted) RS.err(context, "Error: $e"); }
  }

  Future<void> _eliminarEjercicio(int routineExerciseId) async {
    try { await ApiService.deleteEjercicioDeRutina(routineExerciseId); await _cargarEjerciciosGuardados(); }
    catch (e) { if (mounted) RS.err(context, "Error: $e"); }
  }

  @override
  Widget build(BuildContext context) {
    final ejerciciosHoy = _ejerciciosGuardados[_diaSeleccionado] ?? [];
    final gruposDelDia = widget.planSemana[_diaSeleccionado] ?? [];
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background, elevation: 0,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.rutina.nombre.toUpperCase(), style: TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1)),
          Text("Configura tus ejercicios", style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ]),
        actions: [Padding(padding: const EdgeInsets.only(right: 16), child: TextButton(
            onPressed: () { widget.onGuardado(); Navigator.pop(context); },
            child: Text("LISTO", style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700, letterSpacing: 1))))],
      ),
      body: Column(children: [
        SizedBox(height: 44, child: ListView.builder(
          scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: _dias.length,
          itemBuilder: (_, i) {
            final dia = _dias[i]; final sel = dia == _diaSeleccionado; final count = (_ejerciciosGuardados[dia] ?? []).length;
            return GestureDetector(onTap: () => setState(() => _diaSeleccionado = dia),
                child: Container(margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(color: sel ? AppColors.accent : AppColors.card, borderRadius: BorderRadius.circular(22), border: Border.all(color: sel ? AppColors.accent : AppColors.border)),
                    child: Row(children: [
                      Text(dia.substring(0, 3), style: TextStyle(color: sel ? Colors.white : AppColors.textSecondary, fontSize: 13, fontWeight: sel ? FontWeight.w600 : FontWeight.normal)),
                      if (count > 0) ...[const SizedBox(width: 6),
                        Container(width: 18, height: 18,
                            decoration: BoxDecoration(color: sel ? Colors.white.withOpacity(0.3) : AppColors.accent.withOpacity(0.2), shape: BoxShape.circle),
                            child: Center(child: Text("$count", style: TextStyle(color: sel ? Colors.white : AppColors.accent, fontSize: 10, fontWeight: FontWeight.w700)))),
                      ],
                    ])));
          },
        )),
        if (gruposDelDia.isNotEmpty)
          Padding(padding: const EdgeInsets.fromLTRB(16, 10, 16, 0), child: Row(children: [
            Icon(Icons.info_outline, color: AppColors.accent, size: 13), const SizedBox(width: 6),
            Text("Grupos: ${gruposDelDia.join(' + ')}", style: TextStyle(color: AppColors.accent, fontSize: 12)),
          ])),
        const SizedBox(height: 12),
        Expanded(child: _isLoading
            ? Center(child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2))
            : ejerciciosHoy.isEmpty
            ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.add_circle_outline, color: AppColors.textHint, size: 48), const SizedBox(height: 12),
          Text("Sin ejercicios para este día", style: TextStyle(color: AppColors.textSecondary, fontSize: 14)), const SizedBox(height: 8),
          Text("Pulsa + para añadir", style: TextStyle(color: AppColors.textHint, fontSize: 12)),
        ]))
            : ReorderableListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100), itemCount: ejerciciosHoy.length,
          onReorder: (oldIndex, newIndex) { setState(() { if (newIndex > oldIndex) newIndex--; final item = ejerciciosHoy.removeAt(oldIndex); ejerciciosHoy.insert(newIndex, item); }); },
          itemBuilder: (_, i) {
            final e = ejerciciosHoy[i];
            return Container(key: ValueKey(e['routineExerciseId']), margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
                child: Row(children: [
                  Icon(Icons.drag_handle, color: AppColors.textHint, size: 20), const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(e['nombre'], style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 3),
                    Row(children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                          child: Text(e['musculo'], style: TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.w600))),
                      if (e['seriesObjetivo'] != null) ...[const SizedBox(width: 8),
                        Text("${e['seriesObjetivo']}x${e['repsObjetivo']}", style: TextStyle(color: AppColors.textSecondary, fontSize: 11))],
                    ]),
                  ])),
                  IconButton(icon: Icon(Icons.delete_outline, color: AppColors.accent, size: 20), onPressed: () => _eliminarEjercicio(e['routineExerciseId'])),
                ]));
          },
        )),
      ]),
      floatingActionButton: FloatingActionButton(onPressed: _agregarEjercicio, backgroundColor: AppColors.accent, child: const Icon(Icons.add, color: Colors.white)),
    );
  }
}

// ============================================================
// PANTALLA ENTRENAMIENTO EN CURSO
// ============================================================
class _EntrenamientoScreen extends StatefulWidget {
  final Routine rutina; final List<String> gruposHoy; final String diaHoy;
  const _EntrenamientoScreen({required this.rutina, required this.gruposHoy, required this.diaHoy});

  @override
  State<_EntrenamientoScreen> createState() => _EntrenamientoScreenState();
}

class _EntrenamientoScreenState extends State<_EntrenamientoScreen> {
  final DateTime _horaInicio = DateTime.now();
  List<Map<String, dynamic>> _ejercicios = [];
  bool _isLoading = true;
  int? _sessionId;

  int get _seriesCompletadas { int t = 0; for (final e in _ejercicios) { final s = e['series'] as List<Map<String, dynamic>>; t += s.where((s) => s['ok'] == true).length; } return t; }
  int get _seriesTotales { int t = 0; for (final e in _ejercicios) { final s = e['series'] as List<Map<String, dynamic>>; t += s.length; } return t; }

  @override
  void initState() { super.initState(); _iniciarSesionYCargarEjercicios(); }

  Future<void> _iniciarSesionYCargarEjercicios() async {
    try {
      final now = DateTime.now();
      final fecha = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final horaInicio = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:00";
      final sesion = await ApiService.createSesion(userId: UserSession.userId!, fecha: fecha, horaInicio: horaInicio, rutinaId: widget.rutina.rutinaId);
      _sessionId = sesion['sessionId'];
      final ejerciciosGuardados = await ApiService.getEjerciciosByRutinaYDia(widget.rutina.rutinaId, widget.diaHoy);
      setState(() {
        _ejercicios = ejerciciosGuardados.map((e) => {
          'ejercicioId': e['exercise']['ejercicioId'], 'nombre': e['exercise']['nombre'],
          'musculo': e['exercise']['grupoMuscular'], 'seriesObjetivo': e['seriesObjetivo'] ?? 4,
          'repsObjetivo': e['repsObjetivo'] ?? 10, 'series': <Map<String, dynamic>>[],
        }).toList();
        _isLoading = false;
      });
    } catch (_) { setState(() => _isLoading = false); }
  }

  String _fmt(DateTime dt) => "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";

  Future<void> _addEjercicioExtra() async {
    final ejercicio = await showModalBottomSheet<Exercise>(context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
        builder: (_) => _SelectorEjercicioModal(gruposHoy: widget.gruposHoy));
    if (ejercicio != null) setState(() { _ejercicios.add({'ejercicioId': ejercicio.id, 'nombre': ejercicio.nombre, 'musculo': ejercicio.muscle, 'series': <Map<String, dynamic>>[]}); });
  }

  void _addSerie(int i) {
    setState(() {
      final series = _ejercicios[i]["series"] as List<Map<String, dynamic>>;
      series.add({"num": series.length + 1, "peso": TextEditingController(), "reps": TextEditingController(), "ok": false});
    });
  }

  Future<void> _finalizar() async {
    final horaFin = DateTime.now();
    final completadas = _seriesCompletadas;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: AppColors.border)),
        title: Text("FINALIZAR", style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w700, letterSpacing: 1)),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          _infoRow("Entrada", _fmt(_horaInicio)),
          _infoRow("Salida", _fmt(horaFin)),
          _infoRow("Series completadas", "$completadas"),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.accent.withOpacity(0.3))),
            child: Row(children: [
              Icon(Icons.timer_outlined, color: AppColors.accent, size: 16),
              const SizedBox(width: 8),
              Text("${horaFin.difference(_horaInicio).inMinutes} minutos", style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700)),
            ]),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancelar", style: TextStyle(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text("Guardar"),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      if (_sessionId != null) {
        for (final ejercicio in _ejercicios) {
          final series = ejercicio['series'] as List<Map<String, dynamic>>;
          for (final serie in series) {
            if (serie['ok'] == true) {
              final peso = double.tryParse((serie['peso'] as TextEditingController).text) ?? 0.0;
              final reps = int.tryParse((serie['reps'] as TextEditingController).text) ?? 0;
              await ApiService.createRecord(sessionId: _sessionId!, exerciseId: ejercicio['ejercicioId'], numeroSerie: serie['num'], peso: peso, repeticiones: reps, completado: true);
            }
          }
        }
        final horaFinStr = "${horaFin.hour.toString().padLeft(2, '0')}:${horaFin.minute.toString().padLeft(2, '0')}:00";
        await ApiService.finalizarSesion(sessionId: _sessionId!, horaFin: horaFinStr);
      }

      double pesoTotal = 0;
      for (final ejercicio in _ejercicios) {
        final series = ejercicio['series'] as List<Map<String, dynamic>>;
        for (final serie in series) {
          if (serie['ok'] == true) {
            final peso = double.tryParse((serie['peso'] as TextEditingController).text) ?? 0.0;
            final reps = int.tryParse((serie['reps'] as TextEditingController).text) ?? 0;
            pesoTotal += peso * reps;
          }
        }
      }

      if (mounted) {
        await _mostrarCelebracion(context, horaFin.difference(_horaInicio).inMinutes, completadas, pesoTotal);
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) RS.err(context, "Error al guardar: $e");
    }
  }

  Future<void> _mostrarCelebracion(BuildContext context, int minutos, int series, double pesoTotal) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 36, height: 3, margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          Stack(clipBehavior: Clip.none, children: [
            ClipRRect(borderRadius: BorderRadius.circular(16),
                child: Image.asset('assets/images/robotin.jpg', width: 80, height: 80, fit: BoxFit.cover)),
            Positioned(top: -10, right: -10,
                child: Container(padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: AppColors.background, shape: BoxShape.circle, border: Border.all(color: AppColors.success.withOpacity(0.3))),
                    child: const Text("🎉", style: TextStyle(fontSize: 18)))),
          ]),
          const SizedBox(height: 16),
          Text("¡ENTRENAMIENTO COMPLETADO!", style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 6),
          Text("¡Robotín está orgulloso de ti! 💪", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _statCeleb("⏱", "$minutos min", "Duración"),
            const SizedBox(width: 24),
            _statCeleb("✅", "$series", "Series"),
            const SizedBox(width: 24),
            _statCeleb("🏋️", "${pesoTotal.toStringAsFixed(0)} kg", "Peso movido"),
          ]),
          const SizedBox(height: 28),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white, elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
            child: const Text("¡A seguir progresando!", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          )),
        ]),
      ),
    );
  }

  Widget _statCeleb(String emoji, String valor, String label) => Column(children: [
    Text(emoji, style: const TextStyle(fontSize: 24)),
    const SizedBox(height: 4),
    Text(valor, style: TextStyle(color: AppColors.text, fontSize: 22, fontWeight: FontWeight.w900)),
    Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
  ]);

  Widget _infoRow(String label, String value) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
    Text("$label  ", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
    Text(value, style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w600, fontSize: 13)),
  ]));

  @override
  Widget build(BuildContext context) {
    final completadas = _seriesCompletadas; final totales = _seriesTotales;
    final progreso = totales > 0 ? completadas / totales : 0.0;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background, elevation: 0,
        leading: IconButton(icon: Icon(Icons.close, color: AppColors.textSecondary), onPressed: () => Navigator.pop(context)),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.rutina.nombre.toUpperCase(), style: TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1)),
          Text("${widget.diaHoy}  ·  ${_fmt(_horaInicio)}", style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ]),
        actions: [Padding(padding: const EdgeInsets.only(right: 16), child: TextButton(onPressed: _finalizar,
            child: Text("FINALIZAR", style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700, letterSpacing: 1, fontSize: 13))))],
      ),
      body: Column(children: [
        if (!_isLoading)
          Container(margin: const EdgeInsets.fromLTRB(16, 8, 16, 0), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
              child: Row(children: [
                ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset('assets/images/robotin.jpg', width: 36, height: 36, fit: BoxFit.cover)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text("$completadas", style: TextStyle(color: AppColors.accent, fontSize: 22, fontWeight: FontWeight.w900)),
                    Text(" / $totales series completadas", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ]),
                  const SizedBox(height: 6),
                  ClipRRect(borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(value: progreso, backgroundColor: AppColors.border,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent), minHeight: 6)),
                ])),
                const SizedBox(width: 12),
                Text("${(progreso * 100).toInt()}%", style: TextStyle(color: progreso > 0 ? AppColors.accent : AppColors.textHint, fontSize: 16, fontWeight: FontWeight.w800)),
              ])),
        if (widget.gruposHoy.isNotEmpty)
          Container(margin: const EdgeInsets.fromLTRB(16, 8, 16, 0), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.accent.withOpacity(0.3))),
              child: Row(children: [Icon(Icons.info_outline, color: AppColors.accent, size: 15), const SizedBox(width: 8),
                Text("Hoy toca ${widget.gruposHoy.join(' + ')}", style: TextStyle(color: AppColors.accent, fontSize: 13))])),
        Expanded(child: _isLoading
            ? Center(child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2))
            : _ejercicios.isEmpty
            ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 64, height: 64, decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
              child: Icon(Icons.add, color: AppColors.textHint, size: 28)),
          const SizedBox(height: 14),
          Text("No hay ejercicios para hoy", style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 6),
          Text("Pulsa + para añadir un ejercicio extra", style: TextStyle(color: AppColors.textHint, fontSize: 12)),
        ]))
            : ListView.builder(padding: const EdgeInsets.all(16), itemCount: _ejercicios.length,
            itemBuilder: (_, i) => _EjercicioWidget(ejercicio: _ejercicios[i], onAddSerie: () => _addSerie(i),
                onToggle: (si) => setState(() { _ejercicios[i]["series"][si]["ok"] = !_ejercicios[i]["series"][si]["ok"]; })))),
        Container(padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(color: AppColors.background, border: Border(top: BorderSide(color: AppColors.border, width: 0.5))),
            child: SizedBox(width: double.infinity, height: 48,
                child: OutlinedButton.icon(onPressed: _addEjercicioExtra,
                    icon: Icon(Icons.add, color: AppColors.accent, size: 18),
                    label: Text("AÑADIR EJERCICIO EXTRA", style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700, letterSpacing: 1.5, fontSize: 13)),
                    style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.accent), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))))),
      ]),
    );
  }
}

// ============================================================
// MODAL SELECTOR DE EJERCICIOS
// ============================================================
class _SelectorEjercicioModal extends StatefulWidget {
  final List<String> gruposHoy;
  const _SelectorEjercicioModal({required this.gruposHoy});

  @override
  State<_SelectorEjercicioModal> createState() => _SelectorEjercicioModalState();
}

class _SelectorEjercicioModalState extends State<_SelectorEjercicioModal> {
  List<Exercise> _todos = []; List<Exercise> _filtrados = [];
  bool _isLoading = true; String _musculoSeleccionado = "Todos";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() { super.initState(); _load(); }

  @override
  void dispose() { _searchController.dispose(); super.dispose(); }

  Future<void> _load() async {
    try {
      final data = await ApiService.getExercises();
      setState(() {
        _todos = data;
        if (widget.gruposHoy.isNotEmpty && !widget.gruposHoy.contains("Descanso")) {
          _filtrados = data.where((e) => widget.gruposHoy.contains(e.muscle)).toList();
          if (_filtrados.isEmpty) _filtrados = data;
        } else { _filtrados = data; }
        _isLoading = false;
      });
    } catch (_) { setState(() => _isLoading = false); }
  }

  void _filtrar() {
    final query = _searchController.text.toLowerCase();
    setState(() { _filtrados = _todos.where((e) {
      final matchMusculo = _musculoSeleccionado == "Todos" || e.muscle == _musculoSeleccionado;
      final matchSearch = query.isEmpty || e.nombre.toLowerCase().contains(query);
      return matchMusculo && matchSearch;
    }).toList(); });
  }

  List<String> get _musculos {
    final base = ["Todos"];
    if (widget.gruposHoy.isNotEmpty && !widget.gruposHoy.contains("Descanso")) {
      base.addAll(widget.gruposHoy);
      const todos = ["Pecho", "Espalda", "Bíceps", "Tríceps", "Hombro", "Pierna", "Abdominales", "Glúteos", "Gemelos"];
      for (final m in todos) { if (!widget.gruposHoy.contains(m)) base.add(m); }
    } else { base.addAll(["Pecho", "Espalda", "Bíceps", "Tríceps", "Hombro", "Pierna", "Abdominales", "Glúteos", "Gemelos"]); }
    return base;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(initialChildSize: 0.9, minChildSize: 0.5, maxChildSize: 0.95,
      builder: (_, scroll) => Container(
        decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(top: BorderSide(color: AppColors.border))),
        child: Column(children: [
          Container(margin: const EdgeInsets.only(top: 12, bottom: 8), width: 36, height: 3,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Row(children: [
            Expanded(child: Text("ELIGE EJERCICIO", style: TextStyle(color: AppColors.text, fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 1.5))),
            if (widget.gruposHoy.isNotEmpty && !widget.gruposHoy.contains("Descanso"))
              Wrap(spacing: 4, children: widget.gruposHoy.map((g) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                  child: Text(g, style: TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.w600)))).toList()),
          ])),
          Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 8), child: TextField(
            controller: _searchController, onChanged: (_) => _filtrar(), style: TextStyle(color: AppColors.text),
            decoration: InputDecoration(
                hintText: "Buscar ejercicio...", hintStyle: TextStyle(color: AppColors.textHint),
                prefixIcon: Icon(Icons.search, color: AppColors.textHint, size: 20),
                filled: true, fillColor: AppColors.card,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.accent, width: 1.5)),
                contentPadding: const EdgeInsets.symmetric(vertical: 10)),
          )),
          SizedBox(height: 34, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: _musculos.length,
            itemBuilder: (_, i) {
              final m = _musculos[i]; final sel = m == _musculoSeleccionado; final esDeHoy = widget.gruposHoy.contains(m);
              return GestureDetector(onTap: () { setState(() => _musculoSeleccionado = m); _filtrar(); },
                  child: Container(margin: const EdgeInsets.only(right: 6), padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: sel ? AppColors.accent : AppColors.card, borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: sel ? AppColors.accent : esDeHoy ? AppColors.accent.withOpacity(0.5) : AppColors.border, width: esDeHoy && !sel ? 1.5 : 1)),
                      child: Center(child: Text(m, style: TextStyle(color: sel ? Colors.white : esDeHoy ? AppColors.accent : AppColors.textSecondary, fontSize: 12, fontWeight: sel || esDeHoy ? FontWeight.w600 : FontWeight.normal)))));
            },
          )),
          const SizedBox(height: 8),
          Expanded(child: _isLoading
              ? Center(child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2))
              : _filtrados.isEmpty
              ? Center(child: Text("Sin ejercicios", style: TextStyle(color: AppColors.textSecondary, fontSize: 14)))
              : ListView.builder(controller: scroll, padding: const EdgeInsets.fromLTRB(16, 4, 16, 20), itemCount: _filtrados.length,
              itemBuilder: (_, i) {
                final e = _filtrados[i];
                return GestureDetector(onTap: () => Navigator.pop(context, e),
                    child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
                        child: Row(children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(e.nombre, style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w600, fontSize: 14)),
                            const SizedBox(height: 4),
                            Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                child: Text(e.muscle, style: TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.w600))),
                          ])),
                          Icon(Icons.add_circle_outline, color: AppColors.accent, size: 22),
                        ])));
              })),
        ]),
      ),
    );
  }
}

// ============================================================
// WIDGET EJERCICIO CON SERIES + BOTÓN TEMPORIZADOR
// ============================================================
class _EjercicioWidget extends StatelessWidget {
  final Map<String, dynamic> ejercicio;
  final VoidCallback onAddSerie;
  final Function(int) onToggle;
  const _EjercicioWidget({required this.ejercicio, required this.onAddSerie, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final series = ejercicio["series"] as List<Map<String, dynamic>>;
    final seriesObj = ejercicio['seriesObjetivo'];
    final repsObj = ejercicio['repsObjetivo'];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5))),
          child: Row(children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.accent, shape: BoxShape.circle)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(ejercicio["nombre"], style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w700, fontSize: 15)),
              if (seriesObj != null) Text("Objetivo: ${seriesObj}x${repsObj}", style: TextStyle(color: AppColors.textHint, fontSize: 11)),
            ])),
            Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(ejercicio["musculo"] ?? '', style: TextStyle(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.w600))),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(children: [
            Row(children: [
              SizedBox(width: 44, child: Text("SERIE", style: TextStyle(color: AppColors.textHint, fontSize: 10, letterSpacing: 1))),
              const SizedBox(width: 12),
              Expanded(child: Text("KG", style: TextStyle(color: AppColors.textHint, fontSize: 10, letterSpacing: 1))),
              const SizedBox(width: 8),
              Expanded(child: Text("REPS", style: TextStyle(color: AppColors.textHint, fontSize: 10, letterSpacing: 1))),
              const SizedBox(width: 8),
              const SizedBox(width: 74),
            ]),
            const SizedBox(height: 8),
            ...series.asMap().entries.map((e) {
              final i = e.key; final s = e.value; final ok = s["ok"] as bool;
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: ok ? AppColors.accent.withOpacity(0.08) : AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ok ? AppColors.accent.withOpacity(0.4) : AppColors.border, width: 0.5),
                ),
                child: Row(children: [
                  SizedBox(width: 44, child: Text("${s["num"]}", style: TextStyle(color: ok ? AppColors.accent : AppColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 14))),
                  const SizedBox(width: 4),
                  Expanded(child: _serieInput(s["peso"], "0")),
                  const SizedBox(width: 8),
                  Expanded(child: _serieInput(s["reps"], "0")),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => onToggle(i),
                    child: Container(
                      width: 36, height: 32,
                      decoration: BoxDecoration(
                          color: ok ? AppColors.accent : AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: ok ? AppColors.accent : AppColors.border)),
                      child: Icon(Icons.check, size: 16, color: ok ? Colors.white : AppColors.textHint),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => _mostrarTimer(context),
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
                      child: Icon(Icons.timer_outlined, size: 16, color: AppColors.textSecondary),
                    ),
                  ),
                ]),
              );
            }),
            GestureDetector(
              onTap: onAddSerie,
              child: Container(
                margin: const EdgeInsets.only(top: 4), padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.add, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text("Añadir serie", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ]),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _serieInput(TextEditingController c, String hint) => TextField(
    controller: c, keyboardType: const TextInputType.numberWithOptions(decimal: true),
    style: TextStyle(color: AppColors.text, fontSize: 14), textAlign: TextAlign.center,
    decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: AppColors.textHint),
        isDense: true, filled: true, fillColor: AppColors.card,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: AppColors.border, width: 0.5)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: AppColors.border, width: 0.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: AppColors.accent, width: 1)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
  );
}