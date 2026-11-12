/// Errore HTTP con uno stato inatteso (500, 403, 409...).
class ApiException implements Exception {
  ApiException(this.statusCode, this.messaggio);
  final int statusCode;
  final String messaggio;

  @override
  String toString() => 'ApiException($statusCode): $messaggio';
}

/// Errore di RETE: server spento, nessuna connessione, timeout.
/// È diverso da un 404: qui la richiesta non è mai arrivata a destinazione.
class NetworkException implements Exception {
  NetworkException(this.messaggio);
  final String messaggio;

  @override
  String toString() => messaggio;
}
