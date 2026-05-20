class Routine {
  final int rutinaId;
  final String nombre;
  final String? descripcion;
  final bool activa;

  Routine({
    required this.rutinaId,
    required this.nombre,
    this.descripcion,
    this.activa = true,
  });

  factory Routine.fromJson(Map<String, dynamic> json) {
    return Routine(
      rutinaId: json['rutinaId'] ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      activa: json['activa'] ?? true,
    );
  }
}
