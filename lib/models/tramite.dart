class Tramite {
  final int id;
  final String nombre;
  final String modulo;
  final String moduloNombre;
  final String moduloDescripcion;

  const Tramite({
    required this.id,
    required this.nombre,
    required this.modulo,
    required this.moduloNombre,
    required this.moduloDescripcion,
  });

  factory Tramite.fromJson(Map<String, dynamic> json) => Tramite(
        id: json['id_tramite'] as int,
        nombre: json['nombre_tramite'] as String,
        modulo: json['modulo'] as String,
        moduloNombre: json['modulo_nombre'] as String,
        moduloDescripcion: json['modulo_descripcion'] as String,
      );
}