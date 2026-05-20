class Supplement {
  final String nombre;
  final String descripcion;
  final String link;

  Supplement({
    required this.nombre,
    required this.descripcion,
    required this.link,
  });

  factory Supplement.fromJson(Map<String, dynamic> json) {
    return Supplement(
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      link: json['linkCompra'] ?? '',
    );
  }
}
