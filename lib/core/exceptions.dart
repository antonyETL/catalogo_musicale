/// Eccezione lanciata quando un dato non rispetta i vincoli del dominio
/// (gli stessi vincoli dei DTO Java: @NotBlank, @Size, @Min, @Max...).
///
/// `implements Exception` = "questa classe è un'eccezione": in Dart Exception
/// è un'interfaccia vuota, serve solo come etichetta per il tipo.
class DatoNonValidoException implements Exception {
  DatoNonValidoException(this.campo, this.messaggio);

  final String campo; // es. 'gruppo'
  final String messaggio; // es. 'Valore "X" non ammesso: usa S oppure N'

  @override
  String toString() => 'DatoNonValidoException($campo): $messaggio';
}

/// La risorsa richiesta non esiste (in memoria: id assente; via HTTP: 404).
class NotFoundException implements Exception {
  NotFoundException(this.messaggio);
  final String messaggio;

  @override
  String toString() => 'NotFoundException: $messaggio';
}

/// Errori di validazione che il SERVER ci rimanda con un 400.
/// Li teniamo in una mappa campo -> messaggio, così potremo
/// scrivere ogni messaggio sotto il campo del form corrispondente.
class ValidationException implements Exception {
  ValidationException({
    required this.erroriPerCampo,
    this.messaggioGenerale = 'Alcuni campi non sono validi',
  });

  final Map<String, String>
  erroriPerCampo; // {'annoInizio': 'deve essere >= 1900'}
  final String messaggioGenerale;

  @override
  String toString() =>
      'ValidationException: $messaggioGenerale $erroriPerCampo';
}
