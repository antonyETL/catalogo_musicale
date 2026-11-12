import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/tema_controller.dart';

/// Il "guscio" (shell) dell'app: AppBar + NavigationBar restano fermi,
/// cambia solo il contenuto del ramo (branch) selezionato.
class ScaffoldConNav extends StatelessWidget {
  const ScaffoldConNav({super.key, required this.shell});

  /// StatefulNavigationShell tiene in vita i tre rami, ognuno con il proprio
  /// Navigator e il proprio stato (scroll, ricerca, form aperti).
  final StatefulNavigationShell shell;

  static const _titoli = ['Artisti', 'Album', 'Tracce'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titoli[shell.currentIndex]),
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: modalitaTema,
            builder: (_, modo, __) => IconButton(
              tooltip: etichettaTema(modo),
              icon: Icon(iconaTema(modo)),
              onPressed: cambiaTema,
            ),
          ),
        ],
      ),
      body: shell, // <-- il contenuto del ramo attivo
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (indice) {
          // Se ritocco la tab già attiva torno alla sua pagina iniziale
          // (comportamento standard delle app: "tap di nuovo = torna su").
          shell.goBranch(indice, initialLocation: indice == shell.currentIndex);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Artisti',
          ),
          NavigationDestination(
            icon: Icon(Icons.album_outlined),
            selectedIcon: Icon(Icons.album),
            label: 'Album',
          ),
          NavigationDestination(
            icon: Icon(Icons.music_note_outlined),
            selectedIcon: Icon(Icons.music_note),
            label: 'Tracce',
          ),
        ],
      ),
    );
  }
}
