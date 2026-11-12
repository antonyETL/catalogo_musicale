import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/exceptions.dart';
import '../../data/repo.dart';
import '../../models/artista.dart';
import '../shared/error_view.dart';
import '../shared/non_trovato_page.dart';

/// Dettaglio artista: carica SOLO l'artista.
class ArtistaDettaglioPage extends StatefulWidget {
  const ArtistaDettaglioPage({super.key, required this.idArtista});

  final int idArtista;

  @override
  State<ArtistaDettaglioPage> createState() => _ArtistaDettaglioPageState();
}

class _ArtistaDettaglioPageState extends State<ArtistaDettaglioPage> {
  late Future<Artista> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = Repo.artisti.perId(widget.idArtista);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Artista'),
        // Il pulsante indietro c'è già: go_router lo aggiunge da solo
        // perché questa rotta è una child route.
      ),
      body: FutureBuilder<Artista>(
        future: _futuro,
        builder: (contesto, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final e = snapshot.error!;
            if (e is NotFoundException) {
              return const NonTrovatoPage(
                messaggio: 'Questo artista non esiste sul server.',
              );
            }
            return ErrorView(
              messaggio: '$e',
              onRiprova: () => setState(
                () => _futuro = Repo.artisti.perId(widget.idArtista),
              ),
            );
          }

          final a = snapshot.data!;
          final tema = Theme.of(context);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(a.nome, style: tema.textTheme.headlineSmall),
              const SizedBox(height: 16),
              _riga('Nazione', a.nazione),
              _riga('Anno di inizio', '${a.annoInizio}'),
              _riga('Tipo', a.gruppo.etichetta),
              const SizedBox(height: 24),
              // POMERIGGIO: qui arriverà l'elenco degli album caricato in parallelo.
              OutlinedButton.icon(
                onPressed: () => context.go('/album'),
                icon: const Icon(Icons.album),
                label: const Text('Vai alla sezione Album'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _riga(String etichetta, String valore) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(etichetta, style: Theme.of(context).textTheme.labelLarge),
        ),
        Expanded(child: Text(valore)),
      ],
    ),
  );
}
