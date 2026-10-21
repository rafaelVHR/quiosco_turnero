import 'dart:async';

import 'package:flutter/material.dart';

import '../models/tramite.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../utils/fechas.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Tramite>> _tramites;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() {
    _tramites = ApiService.obtenerTramites();
  }

  void _reintentar() => setState(_cargar);

  void _alTocar(Tramite t) {
    debugPrint('Tocó: ${t.moduloNombre} (id_tramite ${t.id})');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const _Encabezado(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¿Qué trámite necesitas?',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Tema.texto,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Selecciona el área que corresponde a tu visita',
                    style: TextStyle(fontSize: 17, color: Tema.textoSuave),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: FutureBuilder<List<Tramite>>(
                      future: _tramites,
                      builder: (context, snap) {
                        if (snap.connectionState != ConnectionState.done) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snap.hasError) {
                          final e = snap.error;
                          return _Error(
                            mensaje: e is ApiException
                                ? e.mensaje
                                : 'Ocurrió un problema inesperado.',
                            onReintentar: _reintentar,
                          );
                        }
                        final lista = snap.data!;
                        if (lista.isEmpty) {
                          return _Error(
                            mensaje:
                                'No hay trámites disponibles por el momento.',
                            onReintentar: _reintentar,
                          );
                        }
                        return _Mosaicos(tramites: lista, alTocar: _alTocar);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 4, 24, 28),
            child: Text(
              'Sistema de Gestión de Filas y Turnero Digital  •  Cooperativa Red Eco de la Montaña',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Tema.textoSuave),
            ),
          ),
        ],
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
          24, MediaQuery.of(context).padding.top + 20, 24, 28),
      decoration: const BoxDecoration(
        color: Tema.morado,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/logo_redeco_provisional.png',
                  height: 56,
                ),
              ),
              const _Reloj(),
            ],
          ),
          const SizedBox(height: 28),
          const Text(
            'Bienvenido a tu sucursal Huamuxtitlán',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Toca una opción para generar tu turno. Recibirás un ticket con tu folio y el tiempo estimado de espera.',
            style: TextStyle(fontSize: 18, color: Colors.white, height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _Reloj extends StatefulWidget {
  const _Reloj();

  @override
  State<_Reloj> createState() => _RelojState();
}

class _RelojState extends State<_Reloj> {
  late DateTime _ahora;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _ahora = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      setState(() => _ahora = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          horaCorta(_ahora),
          style: const TextStyle(
              fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        Text(
          fechaLarga(_ahora),
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ],
    );
  }
}

class _Mosaicos extends StatelessWidget {
  final List<Tramite> tramites;
  final void Function(Tramite) alTocar;

  const _Mosaicos({required this.tramites, required this.alTocar});

  @override
  Widget build(BuildContext context) {
    final filas = <Widget>[];
    for (var i = 0; i < tramites.length; i += 2) {
      final a = tramites[i];
      final b = i + 1 < tramites.length ? tramites[i + 1] : null;
      filas.add(
        Expanded(
          child: Row(
            children: [
              Expanded(child: _Mosaico(tramite: a, alTocar: alTocar)),
              const SizedBox(width: 16),
              Expanded(
                child: b == null
                    ? const SizedBox()
                    : _Mosaico(tramite: b, alTocar: alTocar),
              ),
            ],
          ),
        ),
      );
      if (i + 2 < tramites.length) filas.add(const SizedBox(height: 16));
    }
    return Column(children: filas);
  }
}

class _Mosaico extends StatelessWidget {
  final Tramite tramite;
  final void Function(Tramite) alTocar;

  const _Mosaico({required this.tramite, required this.alTocar});

  IconData _icono(String modulo) {
    switch (modulo) {
      case 'cajas':
        return Icons.payments_outlined;
      case 'socios':
        return Icons.groups_outlined;
      case 'creditos':
        return Icons.request_quote_outlined;
      case 'gerencia':
        return Icons.account_balance_outlined;
      default:
        return Icons.confirmation_number_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 3,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => alTocar(tramite),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: Tema.lila,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _icono(tramite.modulo),
                        size: 64,
                        color: Tema.morado,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      tramite.moduloNombre,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: Tema.texto,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      tramite.moduloDescripcion,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 19,
                        color: Tema.textoSuave,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Tema.amarillo,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        'Generar turno',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Tema.moradoOscuro,
                        ),
                      ),
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

class _Error extends StatelessWidget {
  final String mensaje;
  final VoidCallback onReintentar;

  const _Error({required this.mensaje, required this.onReintentar});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 56, color: Tema.textoSuave),
          const SizedBox(height: 16),
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, color: Tema.texto),
          ),
          const SizedBox(height: 8),
          const Text(
            'Por favor, solicita apoyo al personal de la sucursal.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Tema.textoSuave),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onReintentar,
            icon: const Icon(Icons.refresh),
            label: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Text('Reintentar', style: TextStyle(fontSize: 20)),
            ),
          ),
        ],
      ),
    );
  }
}