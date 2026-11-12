import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    this.album = const [],
    this.artistiPerId = const {},
    this.onDatiCambiati,
  });

  final List<Album> album;
  final Map<int, Artista> artistiPerId;
  final Future<void> Function()? onDatiCambiati;

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  List<Album> _albumLocale = const [];
  Map<int, Artista> _artistiPerIdLocale = const {};
  String? _genereSelezionato; // null = tutti i generi

  List<Album> get _album => widget.album.isEmpty ? _albumLocale : widget.album;
  Map<int, Artista> get _artistiPerId =>
      widget.artistiPerId.isEmpty ? _artistiPerIdLocale : widget.artistiPerId;

  @override
  void initState() {
    super.initState();
    _sincronizzaDati();
  }

  @override
  void didUpdateWidget(covariant AlbumPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.album != oldWidget.album ||
        widget.artistiPerId != oldWidget.artistiPerId) {
      _albumLocale = widget.album;
      _artistiPerIdLocale = widget.artistiPerId;
    }
    if (_genereSelezionato != null && !_generi.contains(_genereSelezionato)) {
      _genereSelezionato = null;
    }
  }

  Future<void> _sincronizzaDati() async {
    if (widget.onDatiCambiati != null) {
      if (!mounted) return;
      setState(() {
        _albumLocale = widget.album;
        _artistiPerIdLocale = widget.artistiPerId;
      });
      return;
    }

    try {
      final artisti = await Repo.artisti.elenca();
      final album = await Repo.album.elenca();
      if (!mounted) return;
      setState(() {
        _albumLocale = album;
        _artistiPerIdLocale = {
          for (final a in artisti)
            if (a.id != null) a.id!: a,
        };
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _albumLocale = const [];
        _artistiPerIdLocale = const {};
      });
    }
  }

  Future<void> _ricaricaDati() async {
    if (widget.onDatiCambiati != null) {
      await widget.onDatiCambiati!();
      if (!mounted) return;
      setState(() {
        _albumLocale = widget.album;
        _artistiPerIdLocale = widget.artistiPerId;
      });
      return;
    }
    await _sincronizzaDati();
  }

  /// Generi presenti, senza duplicati, ordinati.
  /// Il Set elimina i doppioni; toList + sort li ordina alfabeticamente.
  List<String> get _generi {
    final insieme = _album
        .map((a) => a.genere)
        .where((g) => g.trim().isNotEmpty)
        .toSet();
    return insieme.toList()..sort();
  }

  List<Album> get _filtrati {
    final lista =
        _album
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
      _artistiPerId[idArtista]?.nome ?? 'Artista sconosciuto';

  Future<void> _apriForm({Album? album}) async {
    if (_artistiPerId.isEmpty) {
      mostraSnackBar(context, 'Prima aggiungi almeno un artista');
      return;
    }
    final salvato = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => AlbumFormSheet(
        album: album,
        artisti: _artistiPerId.values.toList()
          ..sort((a, b) => a.nome.compareTo(b.nome)),
      ),
    );
    if (salvato != true) return;
    await _ricaricaDati();
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
      await _ricaricaDati();
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
              onRefresh: _ricaricaDati,
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
                          onTap: () async {
                            await context.push(
                              '/album/${a.id}',
                            ); // rotta dichiarativa
                            await _ricaricaDati();
                          },
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
