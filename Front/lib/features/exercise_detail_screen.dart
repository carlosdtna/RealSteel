import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../main.dart';
import '../models/exercise.dart';
import '../service/api_service.dart';
import '../providers/user_session.dart';

// ── Proxy de imágenes — funciona en web y APK ──────────────
String _proxyImg(String url) {
  if (url.isEmpty) return '';
  final clean = url.replaceFirst(RegExp(r'^https?://'), '');
  return 'https://wsrv.nl/?url=$clean&w=600&h=400&fit=contain';
}

class ExerciseDetailScreen extends StatefulWidget {
  final Exercise exercise;
  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  List<Map<String, dynamic>> _historial = [];
  bool _isLoadingHistorial = true;
  String _metricaSeleccionada = "peso";

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  Future<void> _cargarHistorial() async {
    debugPrint("=== buscando userId: ${UserSession.userId} exerciseId: ${widget.exercise.id}");
    if (UserSession.userId == null) {
      setState(() => _isLoadingHistorial = false);
      return;
    }
    try {
      final data = await ApiService.getHistorialEjercicio(
        userId: UserSession.userId!,
        exerciseId: widget.exercise.id,
      );
      debugPrint("=== HISTORIAL records: ${data.length}");
      if (data.isNotEmpty) debugPrint("=== PRIMER RECORD: ${data.first}");
      setState(() {
        _historial = data;
        _isLoadingHistorial = false;
      });
    } catch (e) {
      debugPrint("=== ERROR historial: $e");
      setState(() => _isLoadingHistorial = false);
    }
  }

  List<Map<String, dynamic>> get _datosPorSesion {
    final Map<String, Map<String, dynamic>> porSesion = {};
    for (final record in _historial) {
      final sessionId = record['session']?['sessionId']?.toString() ?? '';
      final fecha = record['session']?['fecha'] ?? '';
      final peso = (record['peso'] as num?)?.toDouble() ?? 0.0;
      final reps = (record['repeticiones'] as num?)?.toInt() ?? 0;
      if (!porSesion.containsKey(sessionId)) {
        porSesion[sessionId] = {'fecha': fecha, 'maxPeso': peso, 'maxReps': reps, 'totalSeries': 1};
      } else {
        if (peso > (porSesion[sessionId]!['maxPeso'] as double)) porSesion[sessionId]!['maxPeso'] = peso;
        if (reps > (porSesion[sessionId]!['maxReps'] as int)) porSesion[sessionId]!['maxReps'] = reps;
        porSesion[sessionId]!['totalSeries'] = (porSesion[sessionId]!['totalSeries'] as int) + 1;
      }
    }
    final lista = porSesion.values.toList();
    lista.sort((a, b) => (a['fecha'] as String).compareTo(b['fecha'] as String));
    return lista;
  }

  double get _pesoMax {
    if (_historial.isEmpty) return 0;
    return _historial.map((r) => (r['peso'] as num?)?.toDouble() ?? 0.0).reduce((a, b) => a > b ? a : b);
  }

  int get _repsMax {
    if (_historial.isEmpty) return 0;
    return _historial.map((r) => (r['repeticiones'] as num?)?.toInt() ?? 0).reduce((a, b) => a > b ? a : b);
  }

  int get _totalSesiones => _datosPorSesion.length;

  @override
  Widget build(BuildContext context) {
    final imgUrl = _proxyImg(widget.exercise.image);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(widget.exercise.nombre,
            style:  TextStyle(color: AppColors.text, fontWeight: FontWeight.w700, fontSize: 15),
            overflow: TextOverflow.ellipsis),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Imagen con proxy ───────────────────────────
            Container(
              width: double.infinity, height: 240, color: AppColors.card,
              child: imgUrl.isNotEmpty
                  ? Image.network(
                imgUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Center(child: Image.asset('assets/images/robotin.jpg', width: 100, height: 100, fit: BoxFit.contain)),
              )
                  : Center(child: Image.asset('assets/images/robotin.jpg', width: 100, height: 100, fit: BoxFit.contain)),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.exercise.nombre, style:  TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.text)),
                  const SizedBox(height: 14),
                  Row(children: [
                    _chip(Icons.sports_gymnastics, widget.exercise.muscle),
                    const SizedBox(width: 8),
                    _chip(widget.exercise.tipo == 'casa' ? Icons.home_outlined : Icons.fitness_center,
                        widget.exercise.tipo == 'casa' ? 'En casa' : 'Gimnasio'),
                  ]),
                  if (widget.exercise.descripcion.isNotEmpty) ...[
                    const SizedBox(height: 24),
                     Text("DESCRIPCIÓN", style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
                    const SizedBox(height: 10),
                    Text(widget.exercise.descripcion, style:  TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.6)),
                  ],
                  const SizedBox(height: 32),
                  Row(children: [
                    Container(width: 4, height: 16, decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 8),
                     Text("MI PROGRESO", style: TextStyle(color: AppColors.text, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                  ]),
                  const SizedBox(height: 16),
                  _isLoadingHistorial
                      ?  Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2)))
                      : _historial.isEmpty
                      ? _emptyProgress()
                      : _progresoContenido(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyProgress() => Container(
    width: double.infinity, padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
    child: Column(children: [
      Image.asset('assets/images/robotin.jpg', width: 80, height: 80, fit: BoxFit.contain),
      const SizedBox(height: 12),
       Text("Sin datos de progreso", style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
       Text("Completa un entrenamiento con este ejercicio\npara ver tu evolución aquí.",
          style: TextStyle(color: AppColors.textHint, fontSize: 12), textAlign: TextAlign.center),
    ]),
  );

  Widget _progresoContenido() {
    final datos = _datosPorSesion;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: _statCard("PESO MÁX.", "${_pesoMax.toStringAsFixed(1)} kg", Icons.trending_up)),
        const SizedBox(width: 10),
        Expanded(child: _statCard("REPS MÁX.", "$_repsMax", Icons.repeat)),
        const SizedBox(width: 10),
        Expanded(child: _statCard("SESIONES", "$_totalSesiones", Icons.calendar_today)),
      ]),
      const SizedBox(height: 20),
      Container(
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
        child: Row(children: [
          Expanded(child: GestureDetector(
            onTap: () => setState(() => _metricaSeleccionada = "peso"),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(color: _metricaSeleccionada == "peso" ? AppColors.accent : Colors.transparent, borderRadius: BorderRadius.circular(9)),
              child: Center(child: Text("Peso (kg)", style: TextStyle(color: _metricaSeleccionada == "peso" ? AppColors.white : AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600))),
            ),
          )),
          Expanded(child: GestureDetector(
            onTap: () => setState(() => _metricaSeleccionada = "reps"),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(color: _metricaSeleccionada == "reps" ? AppColors.accent : Colors.transparent, borderRadius: BorderRadius.circular(9)),
              child: Center(child: Text("Repeticiones", style: TextStyle(color: _metricaSeleccionada == "reps" ? AppColors.white : AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600))),
            ),
          )),
        ]),
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
        child: SizedBox(
          height: 200,
          child: datos.length < 2
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Image.asset('assets/images/robotin.jpg', width: 60, height: 60, fit: BoxFit.contain),
            const SizedBox(height: 8),
             Text("Necesitas al menos 2 sesiones\npara ver la gráfica",
                style: TextStyle(color: AppColors.textHint, fontSize: 12), textAlign: TextAlign.center),
          ]))
              : LineChart(LineChartData(
            gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: _calcularIntervalo(datos),
                getDrawingHorizontalLine: (_) => FlLine(color: AppColors.border, strokeWidth: 0.5)),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40,
                  getTitlesWidget: (value, meta) => Text(_metricaSeleccionada == "peso" ? "${value.toInt()}kg" : "${value.toInt()}",
                      style:  TextStyle(color: AppColors.textSecondary, fontSize: 10)))),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28,
                  getTitlesWidget: (value, meta) {
                    final idx = value.toInt();
                    if (idx < 0 || idx >= datos.length) return const SizedBox();
                    final fecha = datos[idx]['fecha'] as String;
                    final parts = fecha.split('-');
                    final label = parts.length >= 3 ? "${parts[2]}/${parts[1]}" : fecha;
                    return Padding(padding: const EdgeInsets.only(top: 6), child: Text(label, style:  TextStyle(color: AppColors.textSecondary, fontSize: 9)));
                  })),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [LineChartBarData(
              spots: datos.asMap().entries.map((e) {
                final valor = _metricaSeleccionada == "peso" ? (e.value['maxPeso'] as double) : (e.value['maxReps'] as int).toDouble();
                return FlSpot(e.key.toDouble(), valor);
              }).toList(),
              isCurved: true, color: AppColors.accent, barWidth: 2.5, isStrokeCapRound: true,
              dotData: FlDotData(show: true, getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(radius: 4, color: AppColors.accent, strokeWidth: 2, strokeColor: AppColors.background)),
              belowBarData: BarAreaData(show: true, color: AppColors.accent.withOpacity(0.08)),
            )],
            lineTouchData: LineTouchData(touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppColors.card,
              tooltipBorder:  BorderSide(color: AppColors.border),
              getTooltipItems: (spots) => spots.map((spot) {
                final idx = spot.x.toInt();
                final fecha = idx < datos.length ? datos[idx]['fecha'] as String : '';
                return LineTooltipItem(
                  "${_metricaSeleccionada == 'peso' ? '${spot.y.toStringAsFixed(1)} kg' : '${spot.y.toInt()} reps'}\n",
                   TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700, fontSize: 13),
                  children: [TextSpan(text: fecha, style:  TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.normal))],
                );
              }).toList(),
            )),
          )),
        ),
      ),
      const SizedBox(height: 16),
       Text("HISTORIAL DE SESIONES", style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
      const SizedBox(height: 10),
      ...datos.reversed.take(5).map((sesion) => Container(
        margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
        child: Row(children: [
          ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset('assets/images/robotin.jpg', width: 40, height: 40, fit: BoxFit.cover)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(sesion['fecha'] as String, style:  TextStyle(color: AppColors.text, fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 2),
            Text("${sesion['totalSeries']} series", style:  TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text("${(sesion['maxPeso'] as double).toStringAsFixed(1)} kg", style:  TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700, fontSize: 14)),
            Text("${sesion['maxReps']} reps", style:  TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ]),
        ]),
      )),
    ]);
  }

  Widget _statCard(String label, String valor, IconData icon) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
    child: Column(children: [
      Icon(icon, color: AppColors.accent, size: 18),
      const SizedBox(height: 6),
      Text(valor, style:  TextStyle(color: AppColors.text, fontWeight: FontWeight.w800, fontSize: 16)),
      const SizedBox(height: 2),
      Text(label, style:  TextStyle(color: AppColors.textSecondary, fontSize: 9, letterSpacing: 0.5)),
    ]),
  );

  double _calcularIntervalo(List<Map<String, dynamic>> datos) {
    if (datos.isEmpty) return 10;
    final valores = datos.map((d) => _metricaSeleccionada == "peso" ? (d['maxPeso'] as double) : (d['maxReps'] as int).toDouble()).toList();
    final max = valores.reduce((a, b) => a > b ? a : b);
    if (max <= 20) return 5;
    if (max <= 50) return 10;
    if (max <= 100) return 20;
    return 25;
  }

  Widget _chip(IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: AppColors.accent),
      const SizedBox(width: 6),
      Text(label, style:  TextStyle(color: AppColors.text, fontSize: 13)),
    ]),
  );
}