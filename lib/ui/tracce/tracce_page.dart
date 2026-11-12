import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/repo.dart';
import '../../models/album.dart';
import '../../models/traccia.dart';
import '../../utils/formattazioni.dart';
import '../shared/empty_view.dart';
import '../shared/error_view.dart';

/// Tutte le tracce del catalogo, con il titolo dell'album risolto tramite idAlbum.
/// Dimostra il caricamento parallelo di due liste con Future.wait, che ha
/// qui una firma semplice perché i due Future sono entrambi di tipo List.
class TraccePage extends StatefulWidget {
  const TraccePage({super.key});

  @override
  State<TraccePage> createState() => _TraccePageState();
}

class _TraccePageState extends State<TraccePage> {
  late Future<_DatiTracce> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = _carica();
  }

  Future<_DatiTracce> _carica() async {
    final futTracce = Repo.tracce.elenca();
    final futAlbum = Repo.album.elenca();
    final tracce = await futTracce;
    final album = await futAlbum;
    tracce.sort((a, b) {
      final perAlbum = a.idAlbum.compareTo(b.idAlbum);
      return perAlbum != 0
          ? perAlbum
          : a.numeroTraccia.compareTo(b.numeroTraccia);
    });
    return _DatiTracce(tracce, {
      for (final a in album)
        if (a.id != null) a.id!: a,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<_DatiTracce>(
        future: _futuro,
        builder: (contesto, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ErrorView(
              messaggio: '${snapshot.error}',
              onRiprova: () => setState(() => _futuro = _carica()),
            );
          }
          final dati = snapshot.data!;
          if (dati.tracce.isEmpty) {
            return const EmptyView(
              icona: Icons.music_note_outlined,
              messaggio: 'Nessuna traccia presente',
              suggerimento: 'Apri un album e aggiungi le sue tracce.',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => setState(() => _futuro = _carica()),
            child: ListView.builder(
              itemCount: dati.tracce.length,
              itemBuilder: (_, i) {
                final t = dati.tracce[i];
                final album = dati.albumPerId[t.idAlbum];
                return ListTile(
                  leading: CircleAvatar(child: Text('${t.numeroTraccia}')),
                  title: Text(
                    t.titolo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    album?.titolo ?? 'Album ${t.idAlbum}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(mmSs(t.durataSecondi)),
                  onTap: () => context.push('/album/${t.idAlbum}'),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// Piccola classe di appoggio: un solo Future, due risultati tipizzati.
/// Alternativa moderna (Dart 3): un record `(List<Traccia>, Map<int, Album>)`.
class _DatiTracce {
  _DatiTracce(this.tracce, this.albumPerId);
  final List<Traccia> tracce;
  final Map<int, Album> albumPerId;
}
