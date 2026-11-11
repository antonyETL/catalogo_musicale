import '../core/exceptions.dart';

/// Base comune dei repository in memoria.
/// `<T>` è un parametro di tipo: T sarà Artista, Album o Traccia.
abstract class InMemoryRepository<T> {
  /// Riceve i dati di esempio. Assegna a ciascuno un id progressivo,
  /// esattamente come farebbe una colonna AUTO_INCREMENT del database.
  InMemoryRepository(List<T> iniziali) {
    for (final elemento in iniziali) {
      final id = _prossimoId++;
      _dati[id] = conId(elemento, id);
    }
  }

  /// La "tabella": chiave = id, valore = entità.
  /// Un Map rende la ricerca per id immediata (invece di scorrere una lista).
  final Map<int, T> _dati = {};
  int _prossimoId = 1;

  /// Latenza simulata: serve a far vedere loading e CircularProgressIndicator
  /// durante il caricamento dei dati.
  Duration latenza = const Duration(milliseconds: 250);

  // --- Due "ganci" che ogni sottoclasse deve implementare -------------------
  /// Come si legge l'id di un elemento.
  int idDi(T elemento);

  /// Come si crea una copia dell'elemento con un id assegnato.
  T conId(T elemento, int id);
  // -------------------------------------------------------------------------

  Future<void> _attendi() => Future<void>.delayed(latenza);

  Future<List<T>> elenca() async {
    await _attendi();
    // .toList() crea una COPIA: chi chiama non può modificare la nostra mappa.
    return _dati.values.toList();
  }

  Future<T> perId(int id) async {
    await _attendi();
    final elemento = _dati[id];
    if (elemento == null) throw NotFoundException('Elemento $id non trovato');
    return elemento;
  }

  Future<T> crea(T elemento) async {
    await _attendi();
    final id = _prossimoId++;
    final salvato = conId(elemento, id);
    _dati[id] = salvato;
    return salvato;
  }

  Future<T> aggiorna(T elemento) async {
    await _attendi();
    final id = idDi(elemento);
    if (!_dati.containsKey(id)) {
      throw NotFoundException(
        'Impossibile aggiornare: elemento $id inesistente',
      );
    }
    _dati[id] = elemento;
    return elemento;
  }

  Future<void> elimina(int id) async {
    await _attendi();
    if (_dati.remove(id) == null) {
      throw NotFoundException(
        'Impossibile eliminare: elemento $id inesistente',
      );
    }
  }
}
