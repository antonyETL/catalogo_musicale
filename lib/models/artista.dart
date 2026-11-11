import 'gruppo.dart';

/// Modello di dominio: rispecchia ArtistaRequest/ArtistaResponse del backend.
///
/// È IMMUTABILE (tutti i campi `final`): per "modificare" un artista se ne crea
/// una copia con `copyWith`. Vantaggio: nessuno può cambiare un oggetto che
/// un widget sta mostrando a schermo -> meno bug, confronti più semplici.
class Artista {
  const Artista({
    this.id, // nullable: prima del POST l'id non esiste
    required this.nome, // required: il costruttore non compila senza
    required this.nazione,
    required this.annoInizio,
    required this.gruppo,
  });

  final int? id;
  final String nome;
  final String nazione;
  final int annoInizio;
  final Gruppo gruppo;

  /// Copia con alcune parti sostituite. `??` significa:
  /// "usa il parametro se non è null, altrimenti tieni il valore attuale".
  Artista copyWith({
    int? id,
    String? nome,
    String? nazione,
    int? annoInizio,
    Gruppo? gruppo,
  }) => Artista(
    id: id ?? this.id,
    nome: nome ?? this.nome,
    nazione: nazione ?? this.nazione,
    annoInizio: annoInizio ?? this.annoInizio,
    gruppo: gruppo ?? this.gruppo,
  );

  /// `factory` = costruttore che può contenere logica e restituire un'istanza.
  /// Il JSON di Spring contiene anche `_links` (HATEOAS): qui lo ignoriamo,
  /// leggiamo solo i campi che ci servono. Nessuna errore: le chiavi in più
  /// non danno fastidio.
  factory Artista.fromJson(Map<String, dynamic> json) => Artista(
    id: json['id'] as int?,
    nome: json['nome'] as String,
    nazione: json['nazione'] as String,
    annoInizio: json['annoInizio'] as int,
    gruppo: Gruppo.fromCodice(json['gruppo'] as String),
  );

  /// Verso il server: NON mandiamo l'id (lo assegna il backend con il POST).
  Map<String, dynamic> toJson() => {
    'nome': nome,
    'nazione': nazione,
    'annoInizio': annoInizio,
    'gruppo': gruppo.codice, // l'enum torna a essere 'S' / 'N'
  };

  /// Identità basata sull'id, come l'equals/hashCode delle Response Java.
  ///
  /// ATTENZIONE (dettaglio importante): se scrivessimo solo
  /// `other.id == id`, due artisti NUOVI (id == null) risulterebbero uguali!
  /// Quindi: senza id un oggetto è uguale solo a se stesso.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true; // stesso oggetto in memoria
    if (other is! Artista) return false;
    if (id == null || other.id == null) return false;
    return id == other.id;
  }

  /// Regola: oggetti uguali devono avere lo stesso hashCode.
  /// Con id == null tutti hanno 0: è lecito (peggiora solo le prestazioni dei Set).
  @override
  int get hashCode => id?.hashCode ?? 0;

  @override
  String toString() =>
      'Artista(id: $id, nome: $nome, nazione: $nazione, '
      'annoInizio: $annoInizio, gruppo: ${gruppo.codice})';
}
