import 'package:flutter/foundation.dart';

import '../config.dart';
import '../models/turno.dart';
import 'conexion_impresora.dart';
import 'logo_ticket.dart';
import 'ticket.dart';

class ServicioImpresion {
  static ConexionImpresora conexion =
      Config.imprimirTicket ? ConexionUsb() : ConexionSimulada();

  static final ValueNotifier<String> estado = ValueNotifier<String>('');

  static Future<void> imprimir(Turno turno) async {
    estado.value = 'Preparando ticket...';
    try {
      List<int>? logo;
      if (Config.ticketLogo) {
        try {
          logo = await LogoTicket.cargar();
        } catch (e) {
          debugPrint('Ticket sin logo: $e');
        }
      }

      final ticket = ConstructorTicket.construir(turno, logo: logo);
      if (Config.vistaPreviaTicket) {
        debugPrint('\n${ticket.vistaPrevia}');
      }
      final resultado =
          await conexion.enviar(ticket.bytes, (m) => estado.value = m);
      estado.value = resultado;
    } catch (e) {
      debugPrint('Error al imprimir: $e');
      estado.value = 'Error de impresión: $e';
    }
  }
}