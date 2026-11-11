import '../models/album.dart';
import '../models/artista.dart';
import '../models/traccia.dart';

/// `abstract interface class` (Dart 3): una classe che NON si può istanziare
/// e che si usa come contratto con `implements`.
///
/// Perché le interfacce?
/// Perché i widget parleranno poi con `ArtistaRepository`, non con
/// `InMemoryArtistaRepository`: si sostituirà l'implementazione con
/// quella HTTP senza toccare una riga di interfaccia grafica.
///
/// Tutti i metodi sono Future: la memoria risponde subito, la rete
/// risponde dopo un tot di ms. Il chiamante non deve sapere la differenza.
abstract interface class ArtistaRepository {
  Future<List<Artista>> elenca();
  Future<Artista> perId(int id); // lancia NotFoundException se assente
  Future<Artista> crea(Artista artista); // restituisce l'entità CON l'id
  Future<Artista> aggiorna(Artista artista);
  Future<void> elimina(int id);
}

abstract interface class AlbumRepository {
  Future<List<Album>> elenca();
  Future<Album> perId(int id);
  Future<Album> crea(Album album);
  Future<Album> aggiorna(Album album);
  Future<void> elimina(int id);
}

abstract interface class TracciaRepository {
  Future<List<Traccia>> elenca();
  Future<Traccia> perId(int id);
  Future<Traccia> crea(Traccia traccia);
  Future<Traccia> aggiorna(Traccia traccia);
  Future<void> elimina(int id);
}
