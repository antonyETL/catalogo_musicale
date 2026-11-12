import 'package:catalogo_musicale_http/data/http/api_exceptions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/exceptions.dart';
import '../../data/repo.dart';
import '../../models/artista.dart';
import '../shared/dialoghi.dart';
import '../shared/empty_view.dart';
import '../shared/error_view.dart';
import '../shared/feedback.dart';
import 'artista_form_sheet.dart';
import 'artista_tile.dart';

class ArtistiPage extends StatefulWidget {
  const ArtistiPage({super.key});

  @override
  State<ArtistiPage> createState() => _ArtistiPageState();
}

class _ArtistiPageState extends State<ArtistiPage> {
  /// REGOLA FONDAMENTALE di FutureBuilder: il Future si crea in initState
  /// (o in un evento), MAI dentro build. Se lo creassimo in build, ogni
  /// rebuild ripartirebbe da zero -> caricamento infinito.
  late Future<List<Artista>> _futuro;

  final _ricercaCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _futuro = Repo.artisti.elenca();
  }

  @override
  void dispose() {
    _ricercaCtrl.dispose();
    super.dispose();
  }

  void _ricarica() {
    setState(() => _futuro = Repo.artisti.elenca());
  }

  Future<void> _apriForm({Artista? artista}) async {
    final salvato = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => ArtistaFormSheet(artista: artista),
    );
    if (salvato != true) return;
    _ricarica();
    if (!mounted) return;
    mostraSnackBar(
      context,
      artista == null ? 'Artista aggiunto' : 'Artista aggiornato',
    );
  }

  Future<void> _elimina(Artista a) async {
    final ok = await chiediConferma(
      context,
      titolo: 'Eliminare ${a.nome}?',
      messaggio: 'L’eliminazione avviene sul server e non è annullabile.',
      etichettaAzione: 'Elimina',
      distruttiva: true,
    );
    if (!ok) return;
    try {
      await Repo.artisti.elimina(a.id!);
      _ricarica();
      if (!mounted) return;
      mostraSnackBar(context, '${a.nome} eliminato');
    } on NotFoundException {
      if (!mounted) return;
      mostraSnackBar(context, 'L’artista non esiste più: ricarico l’elenco');
      _ricarica();
    } catch (e) {
      if (!mounted) return;
      mostraSnackBar(context, 'Eliminazione non riuscita: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _ricercaCtrl,
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                labelText: 'Cerca per nome',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            // FutureBuilder ascolta il Future e ricostruisce a ogni cambio di stato.
            child: FutureBuilder<List<Artista>>(
              future: _futuro,
              builder: (contesto, snapshot) {
                // 1) in attesa
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                // 2) errore
                if (snapshot.hasError) {
                  return ErrorView(
                    messaggio: _messaggioErrore(snapshot.error!),
                    onRiprova: _ricarica,
                  );
                }
                // 3) dati
                final tutti = snapshot.data ?? const <Artista>[];
                final q = _query.trim().toLowerCase();
                final filtrati =
                    tutti
                        .where((a) => a.nome.toLowerCase().contains(q))
                        .toList()
                      ..sort((a, b) => a.nome.compareTo(b.nome));

                return RefreshIndicator(
                  onRefresh: () async => _ricarica(),
                  child: filtrati.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: 48),
                            EmptyView(
                              icona: Icons.person_search,
                              messaggio: q.isEmpty
                                  ? 'Nessun artista sul server'
                                  : 'Nessun artista corrisponde a “$_query”',
                              azioneLabel: q.isEmpty
                                  ? 'Aggiungi artista'
                                  : null,
                              onAzione: q.isEmpty ? () => _apriForm() : null,
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 96),
                          itemCount: filtrati.length,
                          itemBuilder: (_, i) {
                            final a = filtrati[i];
                            return ArtistaTile(
                              artista: a,
                              // NAVIGAZIONE DICHIARATIVA: passiamo l'id nel path.
                              onTap: () => context.push('/artisti/${a.id}'),
                              onModifica: () => _apriForm(artista: a),
                              onElimina: () => _elimina(a),
                            );
                          },
                        ),
                );
              },
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

  /// Traduciamo le eccezioni in messaggi utili (UX writing).
  String _messaggioErrore(Object errore) {
    if (errore is NetworkException) return errore.messaggio;
    if (errore is ApiException) {
      return 'Il server ha risposto: ${errore.messaggio}';
    }
    if (errore is FormatException) {
      return 'Il server ha risposto in un formato inatteso. '
          'Controlla il formato della lista (array o HAL).';
    }
    return 'Impossibile caricare gli artisti.\n$errore';
  }
}
