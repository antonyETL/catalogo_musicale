import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/exceptions.dart';
import 'api_exceptions.dart';

/// Un solo posto dove si parla HTTP: URL, header, timeout, decodifica, errori.
/// I repository non devono sapere nulla di JSON o di codici di stato.
class ApiClient {
  ApiClient({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      // String.fromEnvironment legge il --dart-define passato a flutter run.
      baseUrl =
          baseUrl ??
          const String.fromEnvironment(
            'API_BASE_URL',
            defaultValue: 'http://10.0.2.2:8080/api',
          );

  final http.Client _client;
  final String baseUrl;

  static const Duration _timeout = Duration(seconds: 10);

  /// Costruisce un Uri corretto (gestisce slash e query string).
  Uri uri(String percorso, [Map<String, String>? query]) {
    final completo = '$baseUrl$percorso';
    return Uri.parse(
      completo,
    ).replace(queryParameters: (query == null || query.isEmpty) ? null : query);
  }

  Future<dynamic> get(String percorso, {Map<String, String>? query}) =>
      _invia('GET', uri(percorso, query));

  Future<dynamic> post(String percorso, Map<String, dynamic> corpo) =>
      _invia('POST', uri(percorso), corpo: corpo);

  Future<dynamic> put(String percorso, Map<String, dynamic> corpo) =>
      _invia('PUT', uri(percorso), corpo: corpo);

  Future<void> delete(String percorso) async {
    await _invia('DELETE', uri(percorso));
  }

  /// Chiude le connessioni. In questa app il client vive per tutta la sessione,
  /// quindi non lo chiudiamo mai; nei test invece è buona pratica farlo.
  void chiudi() => _client.close();

  // ------------------------------------------------------------------ interno
  Future<dynamic> _invia(
    String metodo,
    Uri uri, {
    Map<String, dynamic>? corpo,
  }) async {
    final header = <String, String>{
      'Accept': 'application/json',
      if (corpo != null) 'Content-Type': 'application/json; charset=utf-8',
    };
    final body = corpo == null ? null : jsonEncode(corpo);

    try {
      final http.Response risposta;
      switch (metodo) {
        case 'GET':
          risposta = await _client.get(uri, headers: header).timeout(_timeout);
        case 'POST':
          risposta = await _client
              .post(uri, headers: header, body: body)
              .timeout(_timeout);
        case 'PUT':
          risposta = await _client
              .put(uri, headers: header, body: body)
              .timeout(_timeout);
        case 'DELETE':
          risposta = await _client
              .delete(uri, headers: header)
              .timeout(_timeout);
        default:
          throw ArgumentError('Metodo HTTP non supportato: $metodo');
      }
      return _interpreta(risposta);
    } on SocketException {
      throw NetworkException('Connessione non riuscita: il server è avviato?');
    } on TimeoutException {
      throw NetworkException('Il server non risponde: riprova tra poco.');
    } on http.ClientException catch (e) {
      throw NetworkException('Errore di rete: ${e.message}');
    }
  }

  /// Traduce una risposta HTTP in un valore o in un'eccezione tipizzata.
  dynamic _interpreta(http.Response risposta) {
    // utf8.decode(bodyBytes) e NON risposta.body: `body` può decodificare
    // in latin1 se il server non dichiara il charset -> addii accentate.
    final testo = utf8.decode(risposta.bodyBytes, allowMalformed: true);

    dynamic dati;
    if (testo.isNotEmpty) {
      try {
        dati = jsonDecode(testo);
      } on FormatException {
        dati = null; // corpo non JSON (es. pagina di errore HTML)
      }
    }

    final stato = risposta.statusCode;
    if (stato >= 200 && stato < 300) return dati; // 200, 201, 204...

    if (stato == 400) {
      throw ValidationException(
        erroriPerCampo: _erroriPerCampo(dati),
        messaggioGenerale: _messaggio(dati) ?? 'Controlla i campi evidenziati',
      );
    }
    if (stato == 404) {
      throw NotFoundException('Elemento non trovato sul server');
    }
    throw ApiException(stato, _messaggio(dati) ?? 'Errore del server ($stato)');
  }

  /// Il formato degli errori di validazione dipende dal backend Spring.
  /// Questo parser tollerante copre le tre forme più comuni:
  /// A) {"errors":[{"field":"nome","defaultMessage":"..."}]}   (default Spring)
  /// B) {"errors":{"nome":"..."}}                              (handler custom)
  /// C) {"fieldErrors":{"nome":"..."}}                         (handler custom)
  Map<String, String> _erroriPerCampo(dynamic dati) {
    final mappa = <String, String>{};
    if (dati is! Map<String, dynamic>) return mappa;

    final errors = dati['errors'] ?? dati['fieldErrors'];
    if (errors is List) {
      for (final e in errors) {
        if (e is Map<String, dynamic>) {
          final campo = (e['field'] ?? e['campo']) as String?;
          final msg =
              (e['defaultMessage'] ?? e['message'] ?? e['messaggio'])
                  as String?;
          if (campo != null) mappa[campo] = msg ?? 'Valore non valido';
        }
      }
    } else if (errors is Map<String, dynamic>) {
      errors.forEach((campo, msg) => mappa[campo] = msg.toString());
    }
    return mappa;
  }

  String? _messaggio(dynamic dati) {
    if (dati is Map<String, dynamic>) {
      final m = dati['message'] ?? dati['messaggio'] ?? dati['error'];
      if (m is String && m.isNotEmpty) return m;
    }
    return null;
  }
}
