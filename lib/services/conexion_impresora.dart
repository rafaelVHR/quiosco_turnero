import 'package:flutter/foundation.dart';

abstract class ConexionImpresora {
  Future<void> enviar(List<int> bytes);
}

class ConexionSimulada implements ConexionImpresora {
  @override
  Future<void> enviar(List<int> bytes) async {
    debugPrint('Impresora simulada: ${bytes.length} bytes enviados');
  }
}