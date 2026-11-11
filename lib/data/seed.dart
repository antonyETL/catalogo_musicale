import '../models/album.dart';
import '../models/artista.dart';
import '../models/gruppo.dart';
import '../models/traccia.dart';

// `const`: questi artisti sono costanti a compile-time (tutti i campi lo sono).
const List<Artista> seedArtisti = [
  Artista(
    nome: 'Queen',
    nazione: 'Regno Unito',
    annoInizio: 1970,
    gruppo: Gruppo.si,
  ),
  Artista(
    nome: 'Pink Floyd',
    nazione: 'Regno Unito',
    annoInizio: 1965,
    gruppo: Gruppo.si,
  ),
  Artista(
    nome: 'Miles Davis',
    nazione: 'Stati Uniti',
    annoInizio: 1944,
    gruppo: Gruppo.no,
  ),
  Artista(
    nome: 'Fabrizio De André',
    nazione: 'Italia',
    annoInizio: 1958,
    gruppo: Gruppo.no,
  ),
  Artista(
    nome: 'Daft Punk',
    nazione: 'Francia',
    annoInizio: 1993,
    gruppo: Gruppo.si,
  ),
];

// `final` e non `const`: DateTime(1975, 11, 21) non è costruibile a compile-time.
// Gli idArtista puntano agli id progressivi 1..5 generati dal repository artisti.
final List<Album> seedAlbum = [
  Album(
    titolo: 'A Night at the Opera',
    dataUscita: DateTime(1975, 11, 21),
    genere: 'Rock',
    idArtista: 1,
  ),
  Album(
    titolo: 'A Day at the Races',
    dataUscita: DateTime(1976, 12, 10),
    genere: 'Rock',
    idArtista: 1,
  ),
  Album(
    titolo: 'The Dark Side of the Moon',
    dataUscita: DateTime(1973, 3, 1),
    genere: 'Progressive rock',
    idArtista: 2,
  ),
  Album(
    titolo: 'Wish You Were Here',
    dataUscita: DateTime(1975, 9, 12),
    genere: 'Progressive rock',
    idArtista: 2,
  ),
  Album(
    titolo: 'Kind of Blue',
    dataUscita: DateTime(1959, 8, 17),
    genere: 'Jazz',
    idArtista: 3,
  ),
  Album(
    titolo: 'Bitches Brew',
    dataUscita: DateTime(1970, 3, 30),
    genere: 'Fusion',
    idArtista: 3,
  ),
  Album(
    titolo: 'La buona novella',
    dataUscita: DateTime(1970, 11, 1),
    genere: 'Cantautorale',
    idArtista: 4,
  ),
  Album(
    titolo: 'Discovery',
    dataUscita: DateTime(2001, 3, 12),
    genere: 'Elettronica',
    idArtista: 5,
  ),
];

// 20 tracce. Gli album 2, 4 e 6 restano volutamente VUOTI:
// serviranno per provare gli "stati vuoti" dell'interfaccia.
const List<Traccia> seedTracce = [
  Traccia(
    titolo: 'Death on Two Legs',
    numeroTraccia: 1,
    durataSecondi: 223,
    idAlbum: 1,
  ),
  Traccia(
    titolo: 'Lazing on a Sunday Afternoon',
    numeroTraccia: 2,
    durataSecondi: 67,
    idAlbum: 1,
  ),
  Traccia(
    titolo: "I'm in Love with My Car",
    numeroTraccia: 3,
    durataSecondi: 185,
    idAlbum: 1,
  ),
  Traccia(
    titolo: "You're My Best Friend",
    numeroTraccia: 4,
    durataSecondi: 170,
    idAlbum: 1,
  ),
  Traccia(
    titolo: 'Bohemian Rhapsody',
    numeroTraccia: 5,
    durataSecondi: 354,
    idAlbum: 1,
  ),
  Traccia(
    titolo: 'Speak to Me',
    numeroTraccia: 1,
    durataSecondi: 90,
    idAlbum: 3,
  ),
  Traccia(
    titolo: 'Breathe (In the Air)',
    numeroTraccia: 2,
    durataSecondi: 163,
    idAlbum: 3,
  ),
  Traccia(
    titolo: 'On the Run',
    numeroTraccia: 3,
    durataSecondi: 216,
    idAlbum: 3,
  ),
  Traccia(titolo: 'Time', numeroTraccia: 4, durataSecondi: 421, idAlbum: 3),
  Traccia(titolo: 'Money', numeroTraccia: 5, durataSecondi: 382, idAlbum: 3),
  Traccia(titolo: 'So What', numeroTraccia: 1, durataSecondi: 562, idAlbum: 5),
  Traccia(
    titolo: 'Freddie Freeloader',
    numeroTraccia: 2,
    durataSecondi: 586,
    idAlbum: 5,
  ),
  Traccia(
    titolo: 'Blue in Green',
    numeroTraccia: 3,
    durataSecondi: 337,
    idAlbum: 5,
  ),
  Traccia(
    titolo: 'All Blues',
    numeroTraccia: 4,
    durataSecondi: 693,
    idAlbum: 5,
  ),
  Traccia(
    titolo: 'Laudate Dominum',
    numeroTraccia: 1,
    durataSecondi: 120,
    idAlbum: 7,
  ),
  Traccia(
    titolo: "L'infanzia di Maria",
    numeroTraccia: 2,
    durataSecondi: 240,
    idAlbum: 7,
  ),
  Traccia(
    titolo: 'Il ritorno di Giuseppe',
    numeroTraccia: 3,
    durataSecondi: 180,
    idAlbum: 7,
  ),
  Traccia(
    titolo: 'One More Time',
    numeroTraccia: 1,
    durataSecondi: 320,
    idAlbum: 8,
  ),
  Traccia(
    titolo: 'Aerodynamic',
    numeroTraccia: 2,
    durataSecondi: 212,
    idAlbum: 8,
  ),
  Traccia(
    titolo: 'Digital Love',
    numeroTraccia: 3,
    durataSecondi: 301,
    idAlbum: 8,
  ),
];
