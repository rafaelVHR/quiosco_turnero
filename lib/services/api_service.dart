import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/tramite.dart';
import '../models/turno.dart';

class ApiException implements Exception {
  final String mensaje;
  ApiException(this.mensaje);

  @override
  String toString() => mensaje;
}

class ApiService {
  static const _timeout = Duration(seconds: 10);

  static Map<String, String> get _headers => {
        'X-API-Key': Config.kioscoApiKey,
        'Content-Type': 'application/json',
      };

  static Future<T> _ejecutar<T>(Future<T> Function() accion) async {
    try {
      return await accion();
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException('El servidor tardó demasiado en responder.');
    } on SocketException {
      throw ApiException('No hay conexión a internet.');
    } on http.ClientException {
      throw ApiException('No hay conexión a internet.');
    } catch (e) {
      debugPrint('Error real: $e');
      throw ApiException('No se pudo leer la respuesta del servidor.');
    }
  }

  static Future<List<Tramite>> obtenerTramites() {
    return _ejecutar(() async {
      final resp = await http
          .get(Uri.parse('${Config.apiUrl}/api/tramites'), headers: _headers)
          .timeout(_timeout);

      if (resp.statusCode != 200) {
        throw ApiException(
            'El servidor respondió con un error (${resp.statusCode}).');
      }

      final data =
          jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
      final lista = data['tramites'] as List;
      return lista
          .map((e) => Tramite.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  static Future<Turno> emitirTurno(int idTramite) {
    return _ejecutar(() async {
      final resp = await http
          .post(
            Uri.parse('${Config.apiUrl}/api/turnos'),
            headers: _headers,
            body: jsonEncode({'id_tramite': idTramite, 'es_prioritario': false}),
          )
          .timeout(_timeout);

      if (resp.statusCode != 201) {
        throw ApiException(
            'El servidor respondió con un error (${resp.statusCode}).');
      }

      final data =
          jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
      return Turno.fromJson(data['turno'] as Map<String, dynamic>);
    });
  }
}