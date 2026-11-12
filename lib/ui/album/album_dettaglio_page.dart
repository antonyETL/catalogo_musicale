import 'dart:ui' show ImageFilter; // per BackdropFilter

import 'package:catalogo_musicale_http/ui/album/album_form_sheet.dart';
import 'package:flutter/material.dart';

import '../../data/repo.dart';
import '../../models/album.dart';
import '../../models/artista.dart';
import '../../models/traccia.dart';
import '../../utils/formattazioni.dart';
import '../shared/dialoghi.dart';
import '../shared/durata_bar.dart';
import '../shared/empty_view.dart';
import '../shared/error_view.dart';
import '../shared/feedback.dart';
import '../theme/colori_catalogo.dart';
import '../tracce/traccia_form_sheet.dart';

/// Schermata "Dettaglio album con tracce".
/// Riceve un ID (non l'oggetto): è la scelta che renderà
/// naturale la rotta /album/:id e il deep link.
class AlbumDettaglioPage extends StatefulWidget {
  const AlbumDettaglioPage({super.key, required this.idAlbum});

  final int idAlbum;

  @override
  State<AlbumDettaglioPage> createState() => _AlbumDettaglioPageState();
}

class _AlbumDettaglioPageState extends State<AlbumDettaglioPage> {
  bool _caricamento = true;
  String? _errore;
  Album? _album;
  Artista? _artista;
  List<Traccia> _tracce = const [];

  /// Id della traccia appena toccata: serve per l'animazione implicita.
  int? _tracciaEvidenziata;

  @override
  void initState() {
    super.initState();
    _carica();
  }

  /// Carichiamo album e tracce in parallelo; l'artista dipende dall'album
  /// (serve idArtista), quindi lo chiediamo dopo: è il problema delle
  /// "relazioni solo per id" dei DTO, da discutere in aula.
  Future<void> _carica() async {
    setState(() {
      _caricamento = true;
      _errore = null;
    });
    try {
      final futAlbum = Repo.album.perId(widget.idAlbum);
      final futTracce = Repo.tracce.elenca();

      final album = await futAlbum;
      final tutte = await futTracce;
      Artista? artista;
      try {
        artista = await Repo.artisti.perId(album.idArtista);
      } catch (_) {
        artista =
            null; // artista eliminato: mostriamo "sconosciuto", non un crash
      }

      if (!mounted) return;
      setState(() {
        _album = album;
        _artista = artista;
        _tracce = tutte.where((t) => t.idAlbum == widget.idAlbum).toList()
          ..sort((a, b) => a.numeroTraccia.compareTo(b.numeroTraccia));
        _caricamento = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errore = 'Impossibile aprire l’album.\n$e';
        _caricamento = false;
      });
    }
  }

  int get _durataTotale =>
      _tracce.fold<int>(0, (somma, t) => somma + t.durataSecondi);

  int get _prossimoNumero => _tracce.isEmpty
      ? 1
      : _tracce.map((t) => t.numeroTraccia).reduce((a, b) => a > b ? a : b) + 1;

  Future<void> _apriForm({Traccia? traccia}) async {
    final salvato = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => TracciaFormSheet(
        idAlbum: widget.idAlbum,
        traccia: traccia,
        numeroSuggerito: _prossimoNumero,
      ),
    );
    if (salvato != true) return;
    await _carica();
    if (!mounted) return;
    mostraSnackBar(
      context,
      traccia == null ? 'Traccia aggiunta' : 'Traccia aggiornata',
    );
  }

  /// Eliminazione con conferma + possibilità di ANNULLA.
  /// Nota: il nostro repository non ha un "ripristina",
  /// quindi ricreiamo la traccia: otterrà un ID NUOVO. Con un backend reale
  /// servirebbe un endpoint di restore o un soft-delete. Per le tracce
  /// (nessun figlio collegato) la ricreazione è comunque sicura.
  Future<void> _elimina(Traccia traccia) async {
    final ok = await chiediConferma(
      context,
      titolo: 'Eliminare “${traccia.titolo}”?',
      messaggio: 'Puoi annullare subito dopo, dal messaggio in basso.',
      etichettaAzione: 'Elimina',
      distruttiva: true,
    );
    if (!ok) return;

    try {
      await Repo.tracce.elimina(traccia.id!);
      await _carica();
      if (!mounted) return;
      mostraSnackBar(
        context,
        'Traccia eliminata',
        azioneLabel: 'Annulla',
        onAzione: () async {
          await Repo.tracce.crea(traccia.copyWith(id: null));
          await _carica();
        },
      );
    } catch (e) {
      if (!mounted) return;
      mostraSnackBar(context, 'Eliminazione non riuscita: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_album?.titolo ?? 'Album'),
        actions: [
          IconButton(
            tooltip: 'Modifica album',
            icon: const Icon(Icons.edit_outlined),
            onPressed: _album == null
                ? null
                : () async {
                    // Riusiamo il form del Giorno 2 (qui solo per l'album).
                    final salvato = await showModalBottomSheet<bool>(
                      context: context,
                      isScrollControlled: true,
                      showDragHandle: true,
                      builder: (_) => AlbumFormSheet(
                        album: _album,
                        artisti: [if (_artista != null) _artista!],
                      ),
                    );
                    if (salvato == true) await _carica();
                  },
          ),
        ],
      ),
      body: _corpo(),
      floatingActionButton: _album == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _apriForm(),
              icon: const Icon(Icons.add),
              label: const Text('Traccia'),
            ),
    );
  }

  Widget _corpo() {
    if (_caricamento) return const Center(child: CircularProgressIndicator());
    if (_errore != null) {
      return ErrorView(messaggio: _errore!, onRiprova: _carica);
    }

    final album = _album!;
    final colori = coloriDi(context);
    final tema = Theme.of(context);

    return RefreshIndicator(
      onRefresh: _carica,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          // ---------------- INTESTAZIONE ----------------
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _copertina(album),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(album.titolo, style: tema.textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(
                        _artista?.nome ?? 'Artista sconosciuto',
                        style: tema.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ggMmAaaa(album.dataUscita),
                        style: tema.textTheme.bodyMedium,
                      ),
                      if (album.genere.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        // Chip "genere" con i colori della nostra ThemeExtension.
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colori.sfondoGenere,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            album.genere,
                            style: tema.textTheme.labelMedium?.copyWith(
                              color: colori.testoGenere,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ---------------- BARRA DELLE DURATE ----------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Durata totale',
                        style: tema.textTheme.titleSmall,
                      ),
                    ),
                    Text(
                      mmSs(_durataTotale),
                      style: tema.textTheme.titleMedium?.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    // cifre tabulari: i numeri non "ballano" quando cambiano
                  ],
                ),
                const SizedBox(height: 8),
                DurataBar(tracce: _tracce),
                const SizedBox(height: 8),
                Text(
                  '${_tracce.length} tracce',
                  style: tema.textTheme.labelMedium,
                ),
              ],
            ),
          ),
          const Divider(height: 32),

          // ---------------- ELENCO TRACCE ----------------
          if (_tracce.isEmpty)
            EmptyView(
              icona: Icons.music_note_outlined,
              messaggio: 'Nessuna traccia',
              suggerimento:
                  'Aggiungi la prima traccia con il pulsante in basso.',
              azioneLabel: 'Aggiungi traccia',
              onAzione: () => _apriForm(),
            )
          else
            for (final t in _tracce) _rigaTraccia(t, colori),
        ],
      ),
    );
  }

  Widget _rigaTraccia(Traccia t, ColoriCatalogo colori) {
    final evidenziata = _tracciaEvidenziata == t.id;
    final tema = Theme.of(context);

    return Semantics(
      // Etichetta completa: numero, titolo, durata parlata.
      label:
          'Traccia ${t.numeroTraccia}: ${t.titolo}, '
          '${durataLeggibile(t.durataSecondi)}',
      button: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        decoration: BoxDecoration(
          color: evidenziata
              ? tema.colorScheme.secondaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          onTap: () async {
            setState(() => _tracciaEvidenziata = t.id);
            await Future<void>.delayed(const Duration(milliseconds: 250));
            if (!mounted) return;
            await _apriForm(traccia: t);
            if (!mounted) return;
            setState(() => _tracciaEvidenziata = null);
          },
          leading: CircleAvatar(
            backgroundColor:
                colori.paletteTracce[(t.numeroTraccia - 1) %
                    colori.paletteTracce.length],
            // Il numero è decorativo (già nella Semantics): lo escludiamo
            // per non far leggere due volte la stessa informazione.
            child: ExcludeSemantics(
              child: Text(
                '${t.numeroTraccia}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          title: Text(t.titolo, maxLines: 2, overflow: TextOverflow.ellipsis),
          trailing: Row(
            mainAxisSize:
                MainAxisSize.min, // la Row non si prende tutto lo spazio
            children: [
              Text(mmSs(t.durataSecondi), style: tema.textTheme.bodyMedium),
              PopupMenuButton<String>(
                tooltip: 'Azioni su ${t.titolo}',
                onSelected: (v) {
                  if (v == 'modifica') _apriForm(traccia: t);
                  if (v == 'elimina') _elimina(t);
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'modifica', child: Text('Modifica')),
                  PopupMenuItem(value: 'elimina', child: Text('Elimina')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Copertina segnaposto: ClipRRect + gradiente + BackdropFilter.
  /// Hero la collega alla card della lista (animazione al passaggio di schermata).
  Widget _copertina(Album album) {
    final schema = Theme.of(context).colorScheme;
    return Hero(
      tag: 'copertina-album-${album.id}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 96,
          height: 96,
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [schema.primary, schema.tertiary],
                  ),
                ),
              ),
              // BackdropFilter sfoca ciò che sta SOTTO: qui la fascia in basso
              // diventa "vetro smerigliato" sopra il gradiente.
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 28,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: Container(
                      color: schema.surface.withValues(alpha: 0.35),
                      alignment: Alignment.center,
                      child: Text(
                        '${album.dataUscita.year}',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ),
                ),
              ),
              // Icona decorativa: Opacity la attenua, ExcludeSemantics la nasconde
              // agli screen reader (non aggiunge informazione).
              ExcludeSemantics(
                child: Opacity(
                  opacity: 0.35,
                  child: Icon(Icons.album, size: 56, color: schema.onPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
