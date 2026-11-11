import 'dart:io';

import 'package:catalogo_musicale_http/data/in_memory_repositories.dart';
import 'package:catalogo_musicale_http/models/album.dart';
import 'package:catalogo_musicale_http/models/artista.dart';
import 'package:catalogo_musicale_http/utils/formattazioni.dart';

/// `main` è async: possiamo usare `await` per aspettare i repository.
/// Un Future è "una promessa di un valore che arriverà".
Future<void> main() async {
  final artistiRepo = InMemoryArtistaRepository();
  final albumRepo = InMemoryAlbumRepository();
  final tracceRepo = InMemoryTracciaRepository();

  final artisti = await artistiRepo.elenca();
  final album = await albumRepo.elenca();
  final tracce = await tracceRepo.elenca();

  // --------------------------------------------------------------- 1
  // Album di un artista, ordinati per data di uscita (dal più vecchio).
  final queen = artisti.firstWhere((a) => a.nome == 'Queen');
  final albumQueen = album.where((a) => a.idArtista == queen.id).toList()
    ..sort((a, b) => a.dataUscita.compareTo(b.dataUscita));
  // Il ".." (cascade) applica sort alla lista e restituisce la lista stessa.

  stampa('1) Album di ${queen.nome} in ordine di uscita');
  for (final a in albumQueen) {
    stdout.writeln('   ${ggMmAaaa(a.dataUscita)}  ${a.titolo}  [${a.genere}]');
  }

  // --------------------------------------------------------------- 2
  // Durata totale di un album in mm:ss.
  final darkSide = album.firstWhere((a) => a.titolo.contains('Dark Side'));
  final tracceDarkSide = tracce.where((t) => t.idAlbum == darkSide.id).toList()
    ..sort((a, b) => a.numeroTraccia.compareTo(b.numeroTraccia));

  // fold: parte da 0 e accumula. È il "reduce" degli altri linguaggi.
  final totaleSecondi = tracceDarkSide.fold<int>(
    0,
    (somma, t) => somma + t.durataSecondi,
  );

  stampa('2) ${darkSide.titolo} — ${tracceDarkSide.length} tracce');
  for (final t in tracceDarkSide) {
    stdout.writeln(
      '   ${t.numeroTraccia.toString().padLeft(2)}. '
      '${t.titolo}  (${mmSs(t.durataSecondi)})',
    );
  }
  stdout.writeln('   Durata totale: ${mmSs(totaleSecondi)}');

  // --------------------------------------------------------------- 3
  // Raggruppare gli album per genere: Map<String, List<Album>>.
  final perGenere = <String, List<Album>>{};
  for (final a in album) {
    // putIfAbsent: se la chiave non c'è crea la lista vuota, poi aggiungiamo.
    perGenere.putIfAbsent(a.genere, () => <Album>[]).add(a);
  }

  stampa('3) Album per genere');
  for (final voce in perGenere.entries) {
    stdout.writeln(
      '   ${voce.key} (${voce.value.length}): '
      '${voce.value.map((a) => a.titolo).join(', ')}',
    );
    // map trasforma ogni Album in String, join le unisce con ', '
  }

  // --------------------------------------------------------------- extra
  // Dimostriamo le eccezioni tipizzate e l'uguaglianza basata su id.
  stampa('Extra: errori e identità');
  try {
    await artistiRepo.perId(999);
  } catch (e) {
    stdout.writeln('   perId(999) -> $e');
  }

  final copia = queen.copyWith(nome: 'Queen (rimasterizzato)');
  stdout.writeln('   Stesso id => uguali? ${copia == queen}'); // true
  stdout.writeln('   Nome cambiato: ${copia.nome}'); // immutabilità

  // Bonus: JSON con gruppo non valido -> eccezione personalizzata.
  try {
    Artista.fromJson({
      'id': 99,
      'nome': 'Test',
      'nazione': 'Italia',
      'annoInizio': 2000,
      'gruppo': 'X',
    });
  } catch (e) {
    stdout.writeln('   gruppo "X" -> $e');
  }
}

/// Piccola funzione di servizio per titoli leggibili.
void stampa(String titolo) {
  stdout.writeln('\n=== $titolo ===');
}
