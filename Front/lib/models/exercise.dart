class Exercise {
  final int id;
  final String nombre;
  final String muscle;
  final String descripcion;
  final String image;
  final String tipo;

  Exercise({
    required this.id,
    required this.nombre,
    required this.muscle,
    required this.descripcion,
    required this.image,
    required this.tipo,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['ejercicioId'] ?? 0,
      nombre: json['nombre'] ?? '',
      muscle: json['grupoMuscular'] ?? '',
      descripcion: json['descripcion'] ?? '',
      image: json['imagenUrl'] ?? '',
      tipo: json['tipo'] ?? 'gimnasio',
    );
  }
}