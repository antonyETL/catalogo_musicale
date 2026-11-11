import 'in_memory_repositories.dart';
import 'repositories.dart';

/// "Contenitore delle dipendenze" fatto a mano (dependency injection a mano).
///
/// Classe che permette di concentrarsi su widget e stato.
/// Successivamente si userà RepositoryProvider/BlocProvider.
class Repo {
  Repo._(); // costruttore privato: nessuno deve creare istanze di Repo

  /// `late final`: la assegno una volta in main(), prima di runApp().
  static late final ArtistaRepository artisti;
  static late final AlbumRepository album;
  static late final TracciaRepository tracce;

  static void init() {
    artisti = InMemoryArtistaRepository();
    album = InMemoryAlbumRepository();
    tracce = InMemoryTracciaRepository();
  }
}
