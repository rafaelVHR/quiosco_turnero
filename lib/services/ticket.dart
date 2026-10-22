import '../config.dart';
import '../models/turno.dart';
import '../utils/fechas.dart';

class TicketImpreso {
  final List<int> bytes;
  final String vistaPrevia;

  const TicketImpreso(this.bytes, this.vistaPrevia);
}

class ConstructorTicket {
  static const int _columnas = 48;

  static const Map<String, int> _especiales = {
    'á': 0xA0,
    'é': 0x82,
    'í': 0xA1,
    'ó': 0xA2,
    'ú': 0xA3,
    'ñ': 0xA4,
    'Ñ': 0xA5,
    '¿': 0xA8,
    '¡': 0xAD,
    'Á': 0xB5,
    'É': 0x90,
    'Í': 0xD6,
    'Ó': 0xE0,
    'Ú': 0xE9,
    'ü': 0x81,
    'Ü': 0x9A,
  };

  static const Map<String, String> _sinAcento = {
    'á': 'a',
    'é': 'e',
    'í': 'i',
    'ó': 'o',
    'ú': 'u',
    'ñ': 'n',
    'Ñ': 'N',
    '¿': '?',
    '¡': '!',
    'Á': 'A',
    'É': 'E',
    'Í': 'I',
    'Ó': 'O',
    'Ú': 'U',
    'ü': 'u',
    'Ü': 'U',
  };

  final List<int> _bytes = [];
  final StringBuffer _vista = StringBuffer();

  ConstructorTicket._();

  static TicketImpreso construir(Turno turno) {
    return ConstructorTicket._()._armar(turno);
  }

  static String _dos(int n) => n.toString().padLeft(2, '0');

  static String _quitarAcentos(String texto) {
    final sb = StringBuffer();
    for (final r in texto.runes) {
      final ch = String.fromCharCode(r);
      sb.write(_sinAcento[ch] ?? ch);
    }
    return sb.toString();
  }

  static List<int> _codificar(String texto) {
    final salida = <int>[];
    for (final r in texto.runes) {
      if (r < 128) {
        salida.add(r);
      } else {
        salida.add(_especiales[String.fromCharCode(r)] ?? 0x3F);
      }
    }
    return salida;
  }

  void _linea(
    String texto, {
    int alineacion = 1,
    bool negrita = false,
    int tam = 0x00,
  }) {
    final t = Config.ticketSinAcentos ? _quitarAcentos(texto) : texto;
    _bytes.addAll([0x1B, 0x61, alineacion]);
    _bytes.addAll([0x1B, 0x45, negrita ? 1 : 0]);
    _bytes.addAll([0x1D, 0x21, tam]);
    _bytes.addAll(_codificar(t));
    _bytes.add(0x0A);

    var linea = t;
    if (alineacion == 1) {
      final factor = (tam >> 4) + 1;
      final relleno = ((_columnas - t.runes.length * factor) / 2).floor();
      linea = '${' ' * (relleno > 0 ? relleno : 0)}$t';
    }
    _vista.writeln(linea);
  }

  void _salto() {
    _bytes.add(0x0A);
    _vista.writeln();
  }

  void _separador() {
    _linea('-' * (_columnas - 2));
  }

  TicketImpreso _armar(Turno t) {
    final d = t.emitidoEn;
    final fecha = '${_dos(d.day)}/${_dos(d.month)}/${d.year}';
    final personas = t.personasEnEspera == 0
        ? 'Ninguna'
        : '${t.personasEnEspera} ${t.personasEnEspera == 1 ? 'turno' : 'turnos'}';
    final espera = t.personasEnEspera == 0
        ? 'Eres el siguiente'
        : '${t.tiempoEstimadoMin} ${t.tiempoEstimadoMin == 1 ? 'minuto' : 'minutos'}';

    _bytes.addAll([0x1B, 0x40]);
    _bytes.addAll([0x1B, 0x74, Config.ticketTablaCodigos]);

    _linea('RED ECO DE LA MONTAÑA', negrita: true);
    _linea('S.C. de A.P. de R.L. de C.V.');
    _salto();
    _linea('SUCURSAL HUAMUXTITLÁN', negrita: true, tam: 0x10);
    _salto();
    if (t.esPrioritario) {
      _linea('TURNO PRIORITARIO', negrita: true);
    }
    _linea(t.folio, negrita: true, tam: 0x44);
    _linea('FOLIO DEL TURNO');
    _salto();
    _linea(t.moduloNombre, negrita: true, tam: 0x01);
    _separador();
    _linea('Fecha: $fecha', alineacion: 0);
    _linea('Hora: ${horaCorta(d)}', alineacion: 0);
    _linea('Personas en espera: $personas', alineacion: 0);
    _linea('Tiempo estimado: $espera', alineacion: 0);
    _linea('Trámite: ${t.tramite}', alineacion: 0);
    _separador();
    _linea('ESPERE SU TURNO EN LA SALA', negrita: true);
    _linea('Será llamado en la pantalla');

    _bytes.addAll([0x1D, 0x21, 0x00]);
    _bytes.addAll([0x1B, 0x45, 0x00]);
    _bytes.addAll([0x1B, 0x61, 0x00]);
    _bytes.addAll([0x1B, 0x64, 0x04]);
    _bytes.addAll([0x1D, 0x56, 0x41, 0x00]);
    _vista.writeln('- - - - - - - corte - - - - - - -');

    return TicketImpreso(_bytes, _vista.toString());
  }
}