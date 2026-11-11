import '../utils/formattazioni.dart';

class Album {
  const Album({
    this.id,
    required this.titolo,
    required this.dataUscita, // LocalDate Java -> DateTime Dart
    required this.genere,
    required this.idArtista, // relazione solo per id: niente oggetti annidati
  });

  final int? id;
  final String titolo;
  final DateTime dataUscita;
  final String genere;
  final int idArtista;

  Album copyWith({
    int? id,
    String? titolo,
    DateTime? dataUscita,
    String? genere,
    int? idArtista,
  }) => Album(
    id: id ?? this.id,
    titolo: titolo ?? this.titolo,
    dataUscita: dataUscita ?? this.dataUscita,
    genere: genere ?? this.genere,
    idArtista: idArtista ?? this.idArtista,
  );

  factory Album.fromJson(Map<String, dynamic> json) => Album(
    id: json['id'] as int?,
    titolo: json['titolo'] as String,
    // Il backend manda 'yyyy-MM-dd': DateTime.parse lo capisce da solo.
    dataUscita: DateTime.parse(json['dataUscita'] as String),
    genere: (json['genere'] as String?) ?? '', // campo non obbligatorio
    idArtista: json['idArtista'] as int,
  );

  Map<String, dynamic> toJson() => {
    'titolo': titolo,
    // Attenzione: dataUscita.toIso8601String() produrrebbe
    // '1975-11-21T00:00:00.000' e Spring (LocalDate) risponderebbe 400.
    // Mandiamo SOLO la data.
    'dataUscita': aaaaMmGg(dataUscita),
    'genere': genere,
    'idArtista': idArtista,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Album) return false;
    if (id == null || other.id == null) return false;
    return id == other.id;
  }

  @override
  int get hashCode => id?.hashCode ?? 0;

  @override
  String toString() =>
      'Album(id: $id, titolo: $titolo, dataUscita: ${aaaaMmGg(dataUscita)}, '
      'genere: $genere, idArtista: $idArtista)';
}
