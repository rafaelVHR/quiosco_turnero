import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;

import '../services/servicio_impresion.dart';
import '../config.dart';
import '../models/turno.dart';
import '../theme.dart';
import '../utils/fechas.dart';

String _dos(int n) => n.toString().padLeft(2, '0');

class ConfirmacionScreen extends StatefulWidget {
  final Turno turno;

  const ConfirmacionScreen({super.key, required this.turno});

  @override
  State<ConfirmacionScreen> createState() => _ConfirmacionScreenState();
}

class _ConfirmacionScreenState extends State<ConfirmacionScreen> {
  static const _segundosTotales = 20;
  Timer? _timer;
  int _restan = _segundosTotales;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_restan <= 1) {
        t.cancel();
        _volver();
      } else {
        setState(() => _restan--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _volver() {
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.turno;
    final d = t.emitidoEn;
    final fecha = '${_dos(d.day)} / ${_dos(d.month)} / ${d.year}';
    final personas = t.personasEnEspera == 0
        ? 'Ninguna'
        : '${t.personasEnEspera} ${t.personasEnEspera == 1 ? 'turno' : 'turnos'}';
    final tituloEspera = t.personasEnEspera == 0
        ? 'Eres el siguiente en ser atendido'
        : 'Tiempo estimado de espera: ${t.tiempoEstimadoMin} ${t.tiempoEstimadoMin == 1 ? 'minuto' : 'minutos'}';

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -1),
              radius: 1.5,
              colors: [Color(0xFF4F0A8A), Tema.moradoOscuro],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: const BoxDecoration(
                        color: Tema.amarillo,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded,
                          size: 70, color: Tema.moradoOscuro),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '¡Turno generado con éxito!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Config.imprimirTicket
                          ? 'Conserva tu ticket, será llamado en la pantalla de la sala de espera'
                          : 'Tu folio será llamado en la pantalla de la sala de espera',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 19, color: Color(0xFFE3D4F5)),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(36),
                      ),
                      child: Column(
                        children: [
                          if (t.esPrioritario)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Text(
                                'TURNO PRIORITARIO',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2,
                                  color: Tema.morado,
                                ),
                              ),
                            ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              t.folio,
                              style: GoogleFonts.poppins(
                                fontSize: 130,
                                fontWeight: FontWeight.w800,
                                color: Tema.moradoOscuro,
                                height: 1.1,
                              ),
                            ),
                          ),
                          Text(
                            t.moduloNombre,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 26, color: Tema.textoSuave),
                          ),
                          const SizedBox(height: 20),
                          const _LineaPunteada(),
                          const SizedBox(height: 24),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: _Dato(etiqueta: 'FECHA', valor: fecha)),
                              Expanded(
                                  child: _Dato(
                                      etiqueta: 'HORA DE EMISIÓN',
                                      valor: horaCorta(d))),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: _Dato(
                                      etiqueta: 'PERSONAS EN ESPERA',
                                      valor: personas)),
                              Expanded(
                                  child: _Dato(
                                      etiqueta: 'TRÁMITE', valor: t.tramite)),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Tema.lila,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.schedule_rounded,
                                    size: 38, color: Tema.morado),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tituloEspera,
                                        style: const TextStyle(
                                          fontSize: 21,
                                          fontWeight: FontWeight.w700,
                                          color: Tema.morado,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'Basado en el tiempo promedio de atención de hoy',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Tema.textoSuave),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      Config.imprimirTicket
                          ? 'Tu ticket se está imprimiendo. Tómalo de la impresora y toma asiento en la sala de espera.'
                          : 'Recuerda tu folio y toma asiento en la sala de espera.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 19, color: Color(0xFFE3D4F5)),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _volver,
                      style: FilledButton.styleFrom(
                        backgroundColor: Tema.amarillo,
                        foregroundColor: Tema.moradoOscuro,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 48, vertical: 18),
                      ),
                      child: const Text(
                        'Listo',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w700),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    Text(
                      'Volviendo al inicio en $_restan s',
                      style: const TextStyle(
                          fontSize: 15, color: Color(0xFFBFA8DD)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  final String etiqueta;
  final String valor;

  const _Dato({required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          etiqueta,
          style: const TextStyle(
            fontSize: 14,
            letterSpacing: 1.2,
            color: Color(0xFF8A7BA3),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          valor,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Tema.texto,
          ),
        ),
      ],
    );
  }
}

class _LineaPunteada extends StatelessWidget {
  const _LineaPunteada();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const ancho = 8.0;
        const espacio = 6.0;
        final cantidad =
            (constraints.maxWidth / (ancho + espacio)).floor().clamp(1, 500);
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            cantidad,
            (_) => Container(width: ancho, height: 2, color: Tema.lila),
          ),
        );
      },
    );
  }
}