import '../models/album.dart';
import '../models/artista.dart';
import '../models/traccia.dart';
import 'in_memory_repository.dart';
import 'repositories.dart';
import 'seed.dart';

/// `extends` = eredito tutta la logica comune.
/// `implements` = dichiaro di rispettare il contratto pubblico: è questo che
/// permette ai widget di non sapere se stanno parlando con memoria o rete.
class InMemoryArtistaRepository extends InMemoryRepository<Artista>
    implements ArtistaRepository {
  InMemoryArtistaRepository() : super(seedArtisti);

  @override
  int idDi(Artista a) => a.id ?? 0; // 0 = "senza id": non esiste nella mappa

  @override
  Artista conId(Artista a, int id) => a.copyWith(id: id);
}

class InMemoryAlbumRepository extends InMemoryRepository<Album>
    implements AlbumRepository {
  InMemoryAlbumRepository() : super(seedAlbum);

  @override
  int idDi(Album a) => a.id ?? 0;

  @override
  Album conId(Album a, int id) => a.copyWith(id: id);
}

class InMemoryTracciaRepository extends InMemoryRepository<Traccia>
    implements TracciaRepository {
  InMemoryTracciaRepository() : super(seedTracce);

  @override
  int idDi(Traccia t) => t.id ?? 0;

  @override
  Traccia conId(Traccia t, int id) => t.copyWith(id: id);
}
