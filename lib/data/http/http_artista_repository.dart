import '../../models/artista.dart';
import '../repositories.dart';
import 'api_client.dart';
import 'hal.dart';

/// STESSA interfaccia del repository in memoria: questo è il punto centrale
/// di tutto. L'UI non cambia di una riga.
class HttpArtistaRepository implements ArtistaRepository {
  HttpArtistaRepository(this._api);

  final ApiClient _api;
  static const String _percorso = '/artisti';

  @override
  Future<List<Artista>> elenca() async {
    final dati = await _api.get(_percorso);
    final lista = estraiLista(dati, 'artisti');
    return lista
        .map((e) => Artista.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Artista> perId(int id) async {
    final dati = await _api.get('$_percorso/$id');
    if (dati is! Map<String, dynamic>) {
      throw const FormatException('Risposta inattesa per un singolo artista');
    }
    return Artista.fromJson(dati);
  }

  @override
  Future<Artista> crea(Artista artista) async {
    // toJson NON contiene l'id: lo assegna il server.
    final dati = await _api.post(_percorso, artista.toJson());
    if (dati is Map<String, dynamic> && dati['id'] != null) {
      return Artista.fromJson(dati);
    }
    // Se il backend risponde 201 senza corpo, va allineato (o si legge
    // l'header Location): è un caso reale frequente.
    throw const FormatException(
      'Il POST non ha restituito l’entità creata con il suo id',
    );
  }

  @override
  Future<Artista> aggiorna(Artista artista) async {
    final id = artista.id;
    if (id == null) {
      throw ArgumentError('Per aggiornare serve un id');
    }
    final dati = await _api.put('$_percorso/$id', artista.toJson());
    if (dati is Map<String, dynamic>) return Artista.fromJson(dati);
    // PUT che risponde 204 senza corpo: ci accontentiamo dell'oggetto inviato.
    return artista;
  }

  @override
  Future<void> elimina(int id) => _api.delete('$_percorso/$id');
}
