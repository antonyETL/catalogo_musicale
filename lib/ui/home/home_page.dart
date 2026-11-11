import 'package:flutter/material.dart';

import '../../data/repo.dart';
import '../../models/album.dart';
import '../../models/artista.dart';
import '../album/album_page.dart';
import '../artisti/artisti_page.dart';
import '../shared/error_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tabCorrente = 0;

  // --- Stato condiviso -------------------------------------------------
  bool _caricamento = true;
  String? _errore;
  List<Artista> _artisti = const [];
  List<Album> _album = const [];

  /// Mappa id -> Artista, per risolvere `idArtista` in O(1) nella lista album.
  /// È costruita con un "collection-for" + "collection-if": niente cicli imperativi.
  /// Il `!` è giustificato: lo usiamo solo dopo aver verificato id != null.
  Map<int, Artista> get _artistiPerId => {
    for (final a in _artisti)
      if (a.id != null) a.id!: a,
  };

  @override
  void initState() {
    super.initState();
    // initState: chiamato UNA volta, prima del primo build.
    // Qui si avviano i caricamenti; NON si usa context per ereditare temi.
    _caricaTutto();
  }

  /// Carica artisti e album IN PARALLELO.
  /// Trucco semplice e tipizzato: faccio partire entrambi i Future (nessun await)
  /// e solo dopo li aspetto. Il tempo totale è il massimo dei due, non la somma.
  Future<void> _caricaTutto() async {
    setState(() {
      _caricamento = true;
      _errore = null;
    });
    try {
      final futArtisti = Repo.artisti.elenca();
      final futAlbum = Repo.album.elenca();
      final artisti = await futArtisti;
      final album = await futAlbum;

      // Dopo un await il widget potrebbe essere stato rimosso (l'utente è
      // tornato indietro): chiamare setState su un widget "smontato" è un errore.
      if (!mounted) return;
      setState(() {
        _artisti = artisti;
        _album = album;
        _caricamento = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errore = 'Impossibile caricare il catalogo.\n$e';
        _caricamento = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogo Musicale'),
        actions: [
          IconButton(
            tooltip: 'Ricarica', // tooltip = etichetta per screen reader
            icon: const Icon(Icons.refresh),
            onPressed: _caricaTutto,
          ),
        ],
      ),
      body: _corpo(),
      // Navigazione volutamente semplice: si può sostituire con go_router.
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabCorrente,
        onTap: (indice) => setState(() => _tabCorrente = indice),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Artisti'),
          BottomNavigationBarItem(icon: Icon(Icons.album), label: 'Album'),
        ],
      ),
    );
  }

  Widget _corpo() {
    if (_caricamento) return const Center(child: CircularProgressIndicator());
    if (_errore != null) {
      return ErrorView(messaggio: _errore!, onRiprova: _caricaTutto);
    }
    // IndexedStack tiene in vita TUTTE le pagine figlie (mostra solo quella
    // attiva): ricerca e posizione di scorrimento si conservano cambiando tab.
    // È esattamente il comportamento che ritroveremo con StatefulShellRoute.
    return IndexedStack(
      index: _tabCorrente,
      children: [
        ArtistiPage(artisti: _artisti, onDatiCambiati: _caricaTutto),
        AlbumPage(
          album: _album,
          artistiPerId: _artistiPerId,
          onDatiCambiati: _caricaTutto,
        ),
      ],
    );
  }
}
