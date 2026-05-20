class ExternalExercise {
  final String id;
  final String nombre;
  final String descripcion;
  final String musculo;
  final String equipamiento;
  final String gifUrl;
  final List<String> musculosSecundarios;
  final List<String> instrucciones;

  ExternalExercise({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.musculo,
    required this.equipamiento,
    required this.gifUrl,
    required this.musculosSecundarios,
    required this.instrucciones,
  });

  factory ExternalExercise.fromJson(Map<String, dynamic> json) {
    // Buscar traducción: primero español (4), luego inglés (2), luego cualquiera
    final translations = json['translations'] as List? ?? [];
    Map<String, dynamic>? traduccion =
        translations.firstWhere((t) => t['language'] == 4, orElse: () => null) ??
            translations.firstWhere((t) => t['language'] == 2, orElse: () => null) ??
            (translations.isNotEmpty ? translations[0] : null);

    // Imagen principal
    final images = json['images'] as List? ?? [];
    final imagenPrincipal = images.firstWhere(
          (img) => img['is_main'] == true,
      orElse: () => images.isNotEmpty ? images[0] : null,
    );
    final imageUrl = imagenPrincipal != null
        ? 'https://wger.de${imagenPrincipal['image']}'
        : '';

    // Músculo desde category
    final category = json['category'] as Map<String, dynamic>?;
    final musculo = category?['name'] ?? '';

    // Equipamiento
    final equipment = json['equipment'] as List? ?? [];
    final equipamiento = equipment.isNotEmpty
        ? (equipment[0]['name'] ?? '')
        : 'Sin equipamiento';

    // Músculos secundarios desde muscles_secondary
    final musclesSecondary = json['muscles_secondary'] as List? ?? [];
    final musculosSecundarios = musclesSecondary
        .map((m) => (m['name_en'] as String?) ?? (m['name'] as String?) ?? '')
        .where((s) => s.isNotEmpty)
        .toList();

    // Instrucciones desde la descripción (wger no tiene lista, usamos descripción limpia)
    final descripcionRaw = traduccion?['description_source'] as String? ?? '';
    final instrucciones = descripcionRaw.isNotEmpty ? [descripcionRaw] : <String>[];

    return ExternalExercise(
      id: json['id']?.toString() ?? '',
      nombre: traduccion?['name'] ?? '',
      descripcion: descripcionRaw,
      musculo: musculo,
      equipamiento: equipamiento,
      gifUrl: imageUrl,
      musculosSecundarios: musculosSecundarios,
      instrucciones: instrucciones,
    );
  }
}