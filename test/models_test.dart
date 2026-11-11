import 'package:catalogo_musicale_http/core/exceptions.dart';
import 'package:catalogo_musicale_http/models/album.dart';
import 'package:catalogo_musicale_http/models/artista.dart';
import 'package:catalogo_musicale_http/models/gruppo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Artista: round-trip fromJson -> toJson', () {
    final json = {
      'id': 1,
      'nome': 'Queen',
      'nazione': 'Regno Unito',
      'annoInizio': 1970,
      'gruppo': 'S',
      '_links': {
        'self': {'href': 'http://localhost:8080/api/artisti/1'},
      },
    };
    final artista = Artista.fromJson(json);

    expect(artista.gruppo, Gruppo.si);
    // toJson non rimanda né id né _links: sono responsabilità del server.
    expect(artista.toJson(), {
      'nome': 'Queen',
      'nazione': 'Regno Unito',
      'annoInizio': 1970,
      'gruppo': 'S',
    });
  });

  test('Artista: gruppo non valido lancia DatoNonValidoException', () {
    expect(
      () => Artista.fromJson({
        'nome': 'X',
        'nazione': 'Y',
        'annoInizio': 2000,
        'gruppo': 'Z',
      }),
      throwsA(isA<DatoNonValidoException>()),
    );
  });

  test('Artista: uguaglianza basata su id, non sui contenuti', () {
    const a = Artista(
      id: 1,
      nome: 'Queen',
      nazione: 'UK',
      annoInizio: 1970,
      gruppo: Gruppo.si,
    );
    const b = Artista(
      id: 1,
      nome: 'Altro',
      nazione: 'IT',
      annoInizio: 2000,
      gruppo: Gruppo.no,
    );
    const senzaId = Artista(
      nome: 'Nuovo',
      nazione: 'IT',
      annoInizio: 2000,
      gruppo: Gruppo.no,
    );

    expect(a == b, isTrue);
    expect(a.hashCode == b.hashCode, isTrue);
    expect(a == senzaId, isFalse); // id null: nessuno è uguale a un altro
    expect({a, b}.length, 1); // in un Set finiscono come un solo elemento
  });

  test('Album: la data viaggia come yyyy-MM-dd', () {
    final album = Album(
      titolo: 'Discovery',
      dataUscita: DateTime(2001, 3, 12),
      genere: 'Elettronica',
      idArtista: 5,
    );
    expect(album.toJson()['dataUscita'], '2001-03-12');

    final riletto = Album.fromJson(album.toJson());
    expect(riletto.dataUscita, DateTime(2001, 3, 12));
  });

  test('Album: genere assente nel JSON diventa stringa vuota', () {
    final album = Album.fromJson({
      'id': 9,
      'titolo': 'Senza genere',
      'dataUscita': '1999-01-01',
      'idArtista': 1,
    });
    expect(album.genere, '');
  });
}
