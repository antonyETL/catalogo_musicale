import '../core/exceptions.dart';

/// Il DTO Java usa un `Character` con soli due valori ammessi: 'S' e 'N'.
/// In Dart NON usiamo una String libera (chi potrebbe scrivere 's' o 'si'?):
/// usiamo un enum "evoluto", cioè un enum che porta dati e ha metodi.
enum Gruppo {
  si('S'), // ogni valore chiama il costruttore con il proprio codice
  no('N');

  // Il costruttore di un enum è sempre const: i valori esistono già a compile-time.
  const Gruppo(this.codice);

  /// Il carattere che viaggia nel JSON verso/da Spring Boot.
  final String codice;

  /// Testo per l'interfaccia utente.
  /// `switch` come ESPRESSIONE (Dart 3): restituisce un valore, niente break.
  String get etichetta => switch (this) {
    Gruppo.si => 'Gruppo',
    Gruppo.no => 'Solista',
  };

  /// Da JSON a enum. Se il codice non è riconosciuto lanciamo un'eccezione
  /// nostra invece di far crashare l'app con un errore generico.
  static Gruppo fromCodice(String codice) => values.firstWhere(
    (g) => g.codice == codice,
    orElse: () => throw DatoNonValidoException(
      'gruppo',
      'Valore "$codice" non ammesso: usa S oppure N',
    ),
  );

  /// Versione "morbida": restituisce null invece di lanciare.
  /// Utile quando il campo è opzionale o quando vogliamo solo provare.
  static Gruppo? provaFromCodice(String? codice) {
    if (codice == null) return null;
    for (final g in values) {
      if (g.codice == codice) return g;
    }
    return null;
  }
}
