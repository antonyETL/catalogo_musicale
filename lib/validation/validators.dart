/// FIRMA UNICA: `String? Function(String?)`.
/// - `null`  -> il valore è VALIDO
/// - String  -> è il messaggio d'errore da mostrare
///
/// È esattamente la firma che `TextFormField.validator` si aspetta:
/// scriviamo le regole UNA volta e le riusiamo in tutti i form.
typedef Validator = String? Function(String? valore);

// -- helper privati ---
// Il "_" iniziale rende la funzione privata alla libreria (file).

String? _obbligatorio(String? v, String campo) {
  if (v == null || v.trim().isEmpty) return '$campo è obbligatorio';
  return null;
}

String? _lunghezzaMax(String? v, int max, String campo) {
  final testo = v?.trim() ?? '';
  if (testo.length > max) {
    return '$campo: massimo $max caratteri (ne hai scritti ${testo.length})';
  }
  return null;
}

/// Legge un intero e verifica che sia dentro l'intervallo [min, max].
String? _interoInRange(
  String? v, {
  required int min,
  required int max,
  required String campo,
}) {
  if (v == null || v.trim().isEmpty) return '$campo è obbligatorio';
  final n = int.tryParse(v.trim()); // tryParse: null se non è un numero
  if (n == null) return '$campo: inserisci un numero intero';
  if (n < min || n > max) return '$campo: inserisci un numero tra $min e $max';
  return null;
}

// --- ARTISTA (DTO) ---
// nome: @NotBlank @Size(max 200)
String? validaNome(String? v) =>
    _obbligatorio(v, 'Il nome') ?? _lunghezzaMax(v, 200, 'Il nome');

// nazione: @NotBlank @Size(max 100)
String? validaNazione(String? v) =>
    _obbligatorio(v, 'La nazione') ?? _lunghezzaMax(v, 100, 'La nazione');

// annoInizio: @Min(1900) @Max(9999)
String? validaAnnoInizio(String? v) =>
    _interoInRange(v, min: 1900, max: 9999, campo: "L'anno di inizio");

// gruppo: @AssertTrue, solo 'S' oppure 'N'
String? validaGruppo(String? v) {
  if (v == null || v.trim().isEmpty) {
    return 'Indica se è un gruppo o un solista';
  }
  final c = v.trim().toUpperCase();
  if (c != 'S' && c != 'N') {
    return 'Valore ammesso: S (gruppo) oppure N (solista)';
  }
  return null;
}

// --- ALBUM (DTO) ---
// titolo: @NotBlank @Size(max 300)
String? validaTitolo(String? v) =>
    _obbligatorio(v, 'Il titolo') ?? _lunghezzaMax(v, 300, 'Il titolo');

// genere: @Size(max 100) — il DTO non lo rende obbligatorio
String? validaGenere(String? v) => _lunghezzaMax(v, 100, 'Il genere');

// dataUscita: LocalDate. Nel form il campo è di sola lettura e mostra gg/mm/aaaa:
// qui controlliamo che una data sia stata scelta (il DatePicker la produce valida).
String? validaDataUscita(String? v) =>
    (v == null || v.trim().isEmpty) ? 'Scegli la data di uscita' : null;

// idArtista: @Min(1). Il dropdown però lavora con int?, non con String?:
// ecco perché questa funzione ha una firma diversa.
String? validaArtistaSelezionato(int? id) =>
    (id == null || id <= 0) ? 'Scegli l’artista' : null;

// --- TRACCIA (DTO) ---
// numeroTraccia: @Min(1) @Max(999)
String? validaNumeroTraccia(String? v) =>
    _interoInRange(v, min: 1, max: 999, campo: 'Il numero della traccia');

// durataSecondi: @Min(1) @Max(999999)
String? validaDurataSecondi(String? v) =>
    _interoInRange(v, min: 1, max: 999999, campo: 'La durata in secondi');

String? validaAlbumSelezionato(int? id) =>
    (id == null || id <= 0) ? 'Scegli l’album' : null;
