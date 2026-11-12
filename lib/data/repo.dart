import 'http/api_client.dart';
import 'http/http_artista_repository.dart';
import 'in_memory_repositories.dart';
import 'repositories.dart';

/// Da dove arrivano i dati di una singola entità.
enum FonteDati { memoria, rete }

class Repo {
  Repo._();

  static late final ArtistaRepository artisti;
  static late final AlbumRepository album;
  static late final TracciaRepository tracce;
  static ApiClient? _api;

  /// Al mattino del Giorno 4 solo gli ARTISTI vanno in rete.
  /// Nel pomeriggio gli studenti porteranno album e tracce su `rete`:
  /// basterà cambiare due parole qui (e scrivere i due repository).
  static void init({
    FonteDati fonteArtisti = FonteDati.rete,
    FonteDati fonteAlbum = FonteDati.memoria,
    FonteDati fonteTracce = FonteDati.memoria,
  }) {
    _api = ApiClient();

    artisti = fonteArtisti == FonteDati.rete
        ? HttpArtistaRepository(_api!)
        : InMemoryArtistaRepository();

    album = fonteAlbum == FonteDati.rete
        ? InMemoryAlbumRepository() // TODO pomeriggio: HttpAlbumRepository(_api!)
        : InMemoryAlbumRepository();

    tracce = fonteTracce == FonteDati.rete
        ? InMemoryTracciaRepository() // TODO pomeriggio: HttpTracciaRepository(_api!)
        : InMemoryTracciaRepository();
  }
}
