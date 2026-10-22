import 'package:flutter/foundation.dart';

import '../config.dart';
import '../models/turno.dart';
import 'conexion_impresora.dart';
import 'ticket.dart';

class ServicioImpresion {
  static ConexionImpresora conexion = ConexionSimulada();

  static Future<void> imprimir(Turno turno) async {
    try {
      final ticket = ConstructorTicket.construir(turno);
      if (Config.vistaPreviaTicket) {
        debugPrint('\n${ticket.vistaPrevia}');
      }
      await conexion.enviar(ticket.bytes);
    } catch (e) {
      debugPrint('Error al imprimir: $e');
    }
  }
}