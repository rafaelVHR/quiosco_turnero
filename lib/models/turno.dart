class Turno {
  final int id;
  final String folio;
  final bool esPrioritario;
  final String tramite;
  final String moduloNombre;
  final int personasEnEspera;
  final int tiempoEstimadoMin;
  final DateTime emitidoEn;

  const Turno({
    required this.id,
    required this.folio,
    required this.esPrioritario,
    required this.tramite,
    required this.moduloNombre,
    required this.personasEnEspera,
    required this.tiempoEstimadoMin,
    required this.emitidoEn,
  });

  factory Turno.fromJson(Map<String, dynamic> json) => Turno(
        id: json['id_turno'] as int,
        folio: json['folio'] as String,
        esPrioritario: json['es_prioritario'] as bool,
        tramite: json['tramite'] as String,
        moduloNombre: json['modulo_nombre'] as String,
        personasEnEspera: json['personas_en_espera'] as int,
        tiempoEstimadoMin: json['tiempo_estimado_min'] as int,
        emitidoEn: DateTime.now(),
      );
}