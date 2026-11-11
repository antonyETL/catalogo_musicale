import 'package:flutter/material.dart';

import '../../data/repo.dart';
import '../../models/artista.dart';
import '../shared/dialoghi.dart';
import '../shared/empty_view.dart';
import '../shared/feedback.dart';
import 'artista_form_sheet.dart';
import 'artista_tile.dart';

class ArtistiPage extends StatefulWidget {
  const ArtistiPage({
    super.key,
    required this.artisti, // dati dal padre (HomePage)
    required this.onDatiCambiati, // callback per chiedere il ricaricamento
  });

  final List<Artista> artisti;
  final Future<void> Function() onDatiCambiati;

  @override
  State<ArtistiPage> createState() => _ArtistiPageState();
}

class _ArtistiPageState extends State<ArtistiPage> {
  // Stato LOCALE di interfaccia: resta qui, non serve al padre.
  final TextEditingController _ricercaCtrl = TextEditingController();
  String _query = '';
  bool _vistaGriglia = false;

  @override
  void dispose() {
    // Ogni controller alloca risorse: va SEMPRE liberato.
    _ricercaCtrl.dispose();
    super.dispose();
  }

  /// Filtro + ordinamento: si ricalcola a ogni build.
  /// Con poche decine di elementi è la scelta più semplice e leggibile.
  List<Artista> get _filtrati {
    final q = _query.trim().toLowerCase();
    final lista =
        widget.artisti.where((a) => a.nome.toLowerCase().contains(q)).toList()
          ..sort(
            (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),
          );
    return lista;
  }

  Future<void> _apriForm({Artista? artista}) async {
    // showModalBottomSheet restituisce il valore passato a Navigator.pop.
    // Il form fa il salvataggio e chiude con `true` solo se tutto è andato bene.
    final salvato = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true, // il foglio può occupare quasi tutto lo schermo
      showDragHandle: true, // la "maniglia" che suggerisce il trascinamento
      builder: (_) => ArtistaFormSheet(artista: artista),
    );
    if (salvato != true) return;

    await widget.onDatiCambiati();
    if (!mounted) return; // controllo obbligatorio dopo un await
    mostraSnackBar(
      context,
      artista == null ? 'Artista aggiunto' : 'Artista aggiornato',
    );
  }

  Future<void> _elimina(Artista artista) async {
    final conferma = await chiediConferma(
      context,
      titolo: 'Eliminare ${artista.nome}?',
      messaggio:
          'L’artista verrà rimosso dal catalogo. '
          'Gli album collegati resteranno senza artista.',
      etichettaAzione: 'Elimina',
      distruttiva: true,
    );
    if (!conferma) return;

    try {
      // `!` giustificato: un artista arrivato dal repository ha sempre l'id.
      await Repo.artisti.elimina(artista.id!);
      await widget.onDatiCambiati();
      if (!mounted) return;
      mostraSnackBar(context, '${artista.nome} eliminato');
    } catch (e) {
      if (!mounted) return;
      mostraSnackBar(context, 'Eliminazione non riuscita: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtrati = _filtrati;

    return Scaffold(
      // La AppBar della pagina sta nel padre: qui usiamo una colonna.
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                // Expanded: il campo prende tutto lo spazio che avanza.
                Expanded(
                  child: TextField(
                    controller: _ricercaCtrl,
                    onChanged: (valore) => setState(() => _query = valore),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      labelText: 'Cerca per nome',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Cancella la ricerca',
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _ricercaCtrl.clear();
                                setState(() => _query = '');
                              },
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: _vistaGriglia
                      ? 'Mostra come lista'
                      : 'Mostra come griglia',
                  isSelected: _vistaGriglia,
                  icon: const Icon(Icons.list),
                  selectedIcon: const Icon(Icons.grid_view),
                  onPressed: () =>
                      setState(() => _vistaGriglia = !_vistaGriglia),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${filtrati.length} artisti',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ),
          // Expanded è OBBLIGATORIO: una lista dentro una Column deve avere
          // un'altezza definita, altrimenti Flutter non sa quanto spazio darle.
          Expanded(
            child: RefreshIndicator(
              onRefresh: widget.onDatiCambiati,
              child: filtrati.isEmpty ? _vuoto() : _elenco(filtrati),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _apriForm(),
        icon: const Icon(Icons.add),
        label: const Text('Artista'),
      ),
    );
  }

  Widget _vuoto() {
    // ListView (non Center) così il "pull to refresh" funziona anche da vuoto.
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 48),
        EmptyView(
          icona: Icons.person_search,
          messaggio: _query.isEmpty
              ? 'Nessun artista presente'
              : 'Nessun artista corrisponde a “$_query”',
          suggerimento: _query.isEmpty
              ? 'Aggiungi il primo artista del catalogo.'
              : 'Prova con un altro nome.',
          azioneLabel: _query.isEmpty ? 'Aggiungi artista' : null,
          onAzione: _query.isEmpty ? () => _apriForm() : null,
        ),
      ],
    );
  }

  Widget _elenco(List<Artista> artisti) {
    if (_vistaGriglia) {
      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        // mainAxisExtent = altezza fissa della cella: molto più robusta di
        // childAspectRatio quando l'utente ingrandisce il testo.
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 168,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: artisti.length,
        itemBuilder: (contesto, i) => _card(artisti[i]),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 96),
      itemCount: artisti.length,
      // builder = costruzione "pigra": si creano solo le righe visibili.
      itemBuilder: (contesto, i) {
        final a = artisti[i];
        return ArtistaTile(
          artista: a,
          onTap: () => _dettaglioRapido(a),
          onModifica: () => _apriForm(artista: a),
          onElimina: () => _elimina(a),
        );
      },
    );
  }

  Widget _card(Artista a) {
    return Card(
      child: InkWell(
        onTap: () => _dettaglioRapido(a),
        // Tap lungo = modifica (bonus del pomeriggio, già implementato).
        onLongPress: () => _apriForm(artista: a),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(child: Text(a.nome.isEmpty ? '?' : a.nome[0])),
              const SizedBox(height: 8),
              Text(
                a.nome,
                style: Theme.of(context).textTheme.titleSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(), // spinge il resto in basso
              Text(
                '${a.nazione}\n${a.annoInizio} · ${a.gruppo.etichetta}',
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Il "dettaglio" è un dialogo. Si può evolvere in una rotta.
  void _dettaglioRapido(Artista a) {
    showDialog<void>(
      context: context,
      builder: (contesto) => AlertDialog(
        title: Text(a.nome),
        content: Text(
          'Nazione: ${a.nazione}\n'
          'Anno di inizio: ${a.annoInizio}\n'
          'Tipo: ${a.gruppo.etichetta}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contesto),
            child: const Text('Chiudi'),
          ),
        ],
      ),
    );
  }
}
