import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../main.dart';
import '../models/exercise.dart';
import '../service/api_service.dart';
import 'exercise_detail_screen.dart';

// ── Proxy de imágenes — funciona en web y APK ──────────────
String _proxyImg(String url) {
  if (url.isEmpty) return '';
  final clean = url.replaceFirst(RegExp(r'^https?://'), '');
  return 'https://wsrv.nl/?url=$clean&w=200&h=200&fit=cover';
}

class ExerciseScreen extends StatefulWidget {
  final String tipo;
  const ExerciseScreen({super.key, required this.tipo});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  List<Exercise> _todos = [];
  List<Exercise> _filtrados = [];
  bool _isLoading = true;
  String _musculoSeleccionado = "Todos";
  final TextEditingController _searchController = TextEditingController();

  final List<String> _musculos = [
    "Todos", "Pecho", "Espalda", "Bíceps", "Tríceps",
    "Hombro", "Pierna", "Abdominales", "Glúteos", "Gemelos",
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data = await ApiService.getExercisesByTipo(widget.tipo);
      setState(() {
        _todos = data;
        _filtrados = data;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _filtrar() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filtrados = _todos.where((e) {
        final matchMusculo = _musculoSeleccionado == "Todos" ||
            e.muscle == _musculoSeleccionado;
        final matchSearch = query.isEmpty ||
            e.nombre.toLowerCase().contains(query);
        return matchMusculo && matchSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          widget.tipo == 'gimnasio' ? "GIMNASIO" : "EN CASA",
          style:  TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            fontSize: 16,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding:  EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _filtrar(),
              style:  TextStyle(color: AppColors.text),
              decoration: InputDecoration(
                hintText: "Buscar ejercicio...",
                hintStyle:  TextStyle(color: AppColors.textHint),
                prefixIcon:  Icon(Icons.search, color: AppColors.textHint, size: 20),
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide:  BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide:  BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide:  BorderSide(color: AppColors.accent, width: 1.5)),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _musculos.length,
              itemBuilder: (_, i) {
                final m = _musculos[i];
                final sel = m == _musculoSeleccionado;
                return GestureDetector(
                  onTap: () { setState(() => _musculoSeleccionado = m); _filtrar(); },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.accent : AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: sel ? AppColors.accent : AppColors.border),
                    ),
                    child: Center(child: Text(m, style: TextStyle(color: sel ? AppColors.white : AppColors.textSecondary, fontSize: 13, fontWeight: sel ? FontWeight.w600 : FontWeight.normal))),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _isLoading
                ? _ShimmerList()
                : _filtrados.isEmpty
                ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
               Icon(Icons.fitness_center, color: AppColors.textHint, size: 40),
              const SizedBox(height: 12),
              Text(
                _searchController.text.isNotEmpty ? "Sin resultados para '${_searchController.text}'" : "Sin ejercicios en este grupo",
                style:  TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ]))
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              itemCount: _filtrados.length,
              itemBuilder: (_, i) => _ExerciseCard(exercise: _filtrados[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.card,
      highlightColor: AppColors.border,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        itemCount: 8,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          height: 90,
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            Container(width: 90, height: 90, decoration: BoxDecoration(color: AppColors.border, borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)))),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(height: 14, width: double.infinity, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(6))),
              const SizedBox(height: 10),
              Container(height: 10, width: 80, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(6))),
            ])),
            const SizedBox(width: 16),
          ]),
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  const _ExerciseCard({required this.exercise});

  @override
  Widget build(BuildContext context) {
    final imgUrl = _proxyImg(exercise.image);
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ExerciseDetailScreen(exercise: exercise))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
        child: Row(children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
            child: imgUrl.isNotEmpty
                ? Image.network(
              imgUrl,
              width: 90, height: 90, fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return Shimmer.fromColors(
                  baseColor: AppColors.card, highlightColor: AppColors.border,
                  child: Container(width: 90, height: 90, color: AppColors.card),
                );
              },
              errorBuilder: (_, __, ___) => _placeholder(),
            )
                : _placeholder(),
          ),
          Expanded(child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(exercise.nombre, style:  TextStyle(color: AppColors.text, fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(exercise.muscle, style:  TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ]),
          )),
           Padding(padding: EdgeInsets.only(right: 12), child: Icon(Icons.chevron_right, color: AppColors.textHint, size: 20)),
        ]),
      ),
    );
  }

  Widget _placeholder() => Container(
    width: 90, height: 90, color: AppColors.background,
    child:  Icon(Icons.fitness_center, color: AppColors.textHint, size: 30),
  );
}