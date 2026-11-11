class Traccia {
  const Traccia({
    this.id,
    required this.titolo,
    required this.numeroTraccia,
    required this.durataSecondi,
    required this.idAlbum,
  });

  final int? id;
  final String titolo;
  final int numeroTraccia;
  final int durataSecondi;
  final int idAlbum;

  Traccia copyWith({
    int? id,
    String? titolo,
    int? numeroTraccia,
    int? durataSecondi,
    int? idAlbum,
  }) => Traccia(
    id: id ?? this.id,
    titolo: titolo ?? this.titolo,
    numeroTraccia: numeroTraccia ?? this.numeroTraccia,
    durataSecondi: durataSecondi ?? this.durataSecondi,
    idAlbum: idAlbum ?? this.idAlbum,
  );

  factory Traccia.fromJson(Map<String, dynamic> json) => Traccia(
    id: json['id'] as int?,
    titolo: json['titolo'] as String,
    numeroTraccia: json['numeroTraccia'] as int,
    durataSecondi: json['durataSecondi'] as int,
    idAlbum: json['idAlbum'] as int,
  );

  Map<String, dynamic> toJson() => {
    'titolo': titolo,
    'numeroTraccia': numeroTraccia,
    'durataSecondi': durataSecondi,
    'idAlbum': idAlbum,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Traccia) return false;
    if (id == null || other.id == null) return false;
    return id == other.id;
  }

  @override
  int get hashCode => id?.hashCode ?? 0;

  @override
  String toString() =>
      'Traccia(id: $id, n: $numeroTraccia, titolo: $titolo, '
      'durata: ${durataSecondi}s, idAlbum: $idAlbum)';
}
