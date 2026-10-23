import 'dart:ui' as ui;

import 'package:flutter/services.dart';

import '../config.dart';

class LogoTicket {
  static List<int>? _cache;

  static Future<List<int>> cargar() async {
    final guardado = _cache;
    if (guardado != null) return guardado;

    final datos = await rootBundle.load(Config.logoTicketAsset);
    final codec = await ui.instantiateImageCodec(
      datos.buffer.asUint8List(),
      targetWidth: Config.logoTicketAnchoPuntos,
    );
    final cuadro = await codec.getNextFrame();
    final imagen = cuadro.image;
    final pixeles =
        await imagen.toByteData(format: ui.ImageByteFormat.rawStraightRgba);
    if (pixeles == null) throw Exception('No se pudo leer el logo');

    final ancho = imagen.width;
    final alto = imagen.height;
    final bytesPorFila = Config.anchoPapelPuntos ~/ 8;
    final izquierda = (Config.anchoPapelPuntos - ancho) ~/ 2;

    final filas = <List<int>>[];
    for (var y = 0; y < alto; y++) {
      final fila = List<int>.filled(bytesPorFila, 0);
      for (var x = 0; x < ancho; x++) {
        final i = (y * ancho + x) * 4;
        final r = pixeles.getUint8(i);
        final g = pixeles.getUint8(i + 1);
        final b = pixeles.getUint8(i + 2);
        final a = pixeles.getUint8(i + 3);
        final luz = (0.299 * r + 0.587 * g + 0.114 * b) * a / 255 +
            255 * (255 - a) / 255;
        if (luz < 128) {
          final px = izquierda + x;
          fila[px >> 3] |= 0x80 >> (px & 7);
        }
      }
      filas.add(fila);
    }

    final salida = <int>[];
    const banda = 128;
    for (var inicio = 0; inicio < alto; inicio += banda) {
      final h = (alto - inicio) < banda ? (alto - inicio) : banda;
      salida.addAll([
        0x1D, 0x76, 0x30, 0x00,
        bytesPorFila & 0xFF, bytesPorFila >> 8,
        h & 0xFF, h >> 8,
      ]);
      for (var y = inicio; y < inicio + h; y++) {
        salida.addAll(filas[y]);
      }
    }

    _cache = salida;
    return salida;
  }
}