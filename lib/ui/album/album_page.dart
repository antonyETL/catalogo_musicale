import 'package:flutter/material.dart';

import '../../data/repo.dart';
import '../../models/album.dart';
import '../../models/artista.dart';
import '../shared/dialoghi.dart';
import '../shared/empty_view.dart';
import '../shared/feedback.dart';
import 'album_card.dart';
import 'album_form_sheet.dart';

class AlbumPage extends StatefulWidget {
  const AlbumPage({
    super.key,
    required this.album,
    required this.artistiPerId,
    required this.onDatiCambiati,
  });

  final List<Album> album;
  final Map<int, Artista> artistiPerId;
  final Future<void> Function() onDatiCambiati;

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  String? _genereSelezionato; // null = tutti i generi

  /// Generi presenti, senza duplicati, ordinati.
  /// Il Set elimina i doppioni; toList + sort li ordina alfabeticamente.
  List<String> get _generi {
    final insieme = widget.album
        .map((a) => a.genere)
        .where((g) => g.trim().isNotEmpty)
        .toSet();
    return insieme.toList()..sort();
  }

  /// didUpdateWidget: chiamato quando il PADRE passa dati nuovi.
  /// Caso reale: elimino l'ultimo album "Jazz" e il filtro Jazz resta selezionato
  /// mostrando una lista vuota senza perché. Qui lo resettiamo.
  @override
  void didUpdateWidget(AlbumPage vecchio) {
    super.didUpdateWidget(vecchio);
    if (_genereSelezionato != null && !_generi.contains(_genereSelezionato)) {
      // Attenzione: qui NON si chiama setState (siamo già in un rebuild).
      _genereSelezionato = null;
    }
  }

  List<Album> get _filtrati {
    final lista =
        widget.album
            .where(
              (a) =>
                  _genereSelezionato == null || a.genere == _genereSelezionato,
            )
            .toList()
          ..sort(
            (a, b) => b.dataUscita.compareTo(a.dataUscita),
          ); // dal più recente
    return lista;
  }

  String _nomeArtista(int idArtista) =>
      widget.artistiPerId[idArtista]?.nome ?? 'Artista sconosciuto';

  Future<void> _apriForm({Album? album}) async {
    if (widget.artistiPerId.isEmpty) {
      mostraSnackBar(context, 'Prima aggiungi almeno un artista');
      return;
    }
    final salvato = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => AlbumFormSheet(
        album: album,
        artisti: widget.artistiPerId.values.toList()
          ..sort((a, b) => a.nome.compareTo(b.nome)),
      ),
    );
    if (salvato != true) return;
    await widget.onDatiCambiati();
    if (!mounted) return;
    mostraSnackBar(
      context,
      album == null ? 'Album aggiunto' : 'Album aggiornato',
    );
  }

  Future<void> _elimina(Album album) async {
    final ok = await chiediConferma(
      context,
      titolo: 'Eliminare “${album.titolo}”?',
      messaggio: 'Verranno eliminate anche le tracce collegate.',
      etichettaAzione: 'Elimina',
      distruttiva: true,
    );
    if (!ok) return;
    try {
      await Repo.album.elimina(album.id!);
      await widget.onDatiCambiati();
      if (!mounted) return;
      mostraSnackBar(context, 'Album eliminato');
    } catch (e) {
      if (!mounted) return;
      mostraSnackBar(context, 'Eliminazione non riuscita: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtrati = _filtrati;
    final generi = _generi;

    return Scaffold(
      body: Column(
        children: [
          // Filtro per genere con ChoiceChip: scelta singola, sempre visibile.
          if (generi.isNotEmpty)
            SizedBox(
              height: 56,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                children: [
                  ChoiceChip(
                    label: const Text('Tutti'),
                    selected: _genereSelezionato == null,
                    onSelected: (_) =>
                        setState(() => _genereSelezionato = null),
                  ),
                  for (final g in generi) ...[
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text(g),
                      selected: _genereSelezionato == g,
                      onSelected: (_) => setState(() => _genereSelezionato = g),
                    ),
                  ],
                ],
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: widget.onDatiCambiati,
              child: filtrati.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 48),
                        EmptyView(
                          icona: Icons.album_outlined,
                          messaggio: 'Nessun album presente',
                          suggerimento: _genereSelezionato == null
                              ? 'Aggiungi il primo album del catalogo.'
                              : 'Nessun album nel genere “$_genereSelezionato”.',
                          azioneLabel: 'Aggiungi album',
                          onAzione: () => _apriForm(),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 96),
                      itemCount: filtrati.length,
                      itemBuilder: (_, i) {
                        final a = filtrati[i];
                        return AlbumCard(
                          album: a,
                          nomeArtista: _nomeArtista(a.idArtista),
                          onTap: () => _apriForm(album: a),
                          onModifica: () => _apriForm(album: a),
                          onElimina: () => _elimina(a),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _apriForm(),
        icon: const Icon(Icons.add),
        label: const Text('Album'),
      ),
    );
  }
}
