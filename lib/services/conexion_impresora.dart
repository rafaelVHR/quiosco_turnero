import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

abstract class ConexionImpresora {
  Future<String> enviar(List<int> bytes, void Function(String) avance);
}

class ConexionSimulada implements ConexionImpresora {
  @override
  Future<String> enviar(List<int> bytes, void Function(String) avance) async {
    debugPrint('Impresora simulada: ${bytes.length} bytes enviados');
    return 'Ticket simulado (${bytes.length} bytes)';
  }
}

class ConexionUsb implements ConexionImpresora {
  static const _canal = MethodChannel('com.redeco.turnero/impresora');

  @override
  Future<String> enviar(List<int> bytes, void Function(String) avance) async {
    avance('Buscando impresora USB...');
    String resumen = 'ninguno';
    try {
      final lista = await _canal.invokeMethod<List<dynamic>>('listar');
      if (lista != null && lista.isNotEmpty) resumen = lista.join(' | ');

      avance('Enviando ticket... USB: $resumen. Acepta el permiso si aparece');
      final r = await _canal.invokeMethod<String>(
        'imprimir',
        {'bytes': Uint8List.fromList(bytes)},
      ).timeout(const Duration(seconds: 40));

      if (r == null || !r.startsWith('OK')) {
        throw Exception(r ?? 'sin respuesta de la impresora');
      }
      return 'Ticket enviado ($r). USB: $resumen';
    } catch (e) {
      throw Exception('$e. USB: $resumen');
    }
  }
}