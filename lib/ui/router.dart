import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'album/album_dettaglio_page.dart';
import 'album/album_page.dart';
import 'artisti/artista_dettaglio_page.dart';
import 'artisti/artisti_page.dart';
import 'home/scaffold_con_nav.dart';
import 'shared/non_trovato_page.dart';
import 'tracce/tracce_page.dart';

/// Navigator radice: serve quando vogliamo una pagina a SCHERMO INTERO,
/// sopra la barra di navigazione (es. un form a pagina piena).
final GlobalKey<NavigatorState> radiceNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'radice',
);

/// Funzione e non variabile globale: nei test possiamo crearne uno nuovo
/// con initialLocation diversa, senza stato condiviso fra i test.
GoRouter creaRouter({String iniziale = '/artisti'}) {
  return GoRouter(
    navigatorKey: radiceNavigatorKey,
    initialLocation: iniziale,
    debugLogDiagnostics: true, // in console vedi ogni navigazione: utilissimo
    // Errore di routing (percorso che non esiste): pagina nostra, non quella
    // rossa di default di Flutter.
    errorBuilder: (contesto, stato) =>
        NonTrovatoPage(percorso: stato.uri.toString()),

    // redirect: si esegue PRIMA di costruire la pagina.
    // Restituire null = "procedi"; restituire una String = "vai lì invece".
    redirect: (contesto, stato) {
      if (stato.uri.path == '/') return '/artisti';
      return null;
    },

    routes: [
      // ---------------- Navigazione annidata con stato conservato ----------
      StatefulShellRoute.indexedStack(
        builder: (contesto, stato, shell) => ScaffoldConNav(shell: shell),
        branches: [
          // ===== RAMO 1: ARTISTI =====
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/artisti',
                name: 'artisti',
                builder: (contesto, stato) => const ArtistiPage(),
                routes: [
                  // child route -> /artisti/3 resta DENTRO il ramo Artisti
                  // (la barra sotto rimane visibile).
                  GoRoute(
                    path: ':id',
                    name: 'artista-dettaglio',
                    builder: (contesto, stato) {
                      // tryParse e non parse: "/artisti/abc" non deve esplodere.
                      final id = int.tryParse(stato.pathParameters['id'] ?? '');
                      if (id == null || id <= 0) {
                        return NonTrovatoPage(
                          percorso: stato.uri.toString(),
                          messaggio:
                              'L’identificativo dell’artista non è valido.',
                        );
                      }
                      return ArtistaDettaglioPage(idArtista: id);
                    },
                  ),
                ],
              ),
            ],
          ),

          // ===== RAMO 2: ALBUM =====
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/album',
                name: 'album',
                builder: (contesto, stato) => const AlbumPage(),
                routes: [
                  GoRoute(
                    path: ':id',
                    name: 'album-dettaglio',
                    builder: (contesto, stato) {
                      final id = int.tryParse(stato.pathParameters['id'] ?? '');
                      if (id == null || id <= 0) {
                        return NonTrovatoPage(
                          percorso: stato.uri.toString(),
                          messaggio:
                              'L’identificativo dell’album non è valido.',
                        );
                      }
                      return AlbumDettaglioPage(idAlbum: id);
                    },
                    // POMERIGGIO: qui dentro aggiungerete
                    // GoRoute(path: 'tracce', ...) -> /album/:id/tracce
                  ),
                ],
              ),
            ],
          ),

          // ===== RAMO 3: TRACCE =====
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tracce',
                name: 'tracce',
                builder: (contesto, stato) => const TraccePage(),
              ),
            ],
          ),
        ],
      ),

      // ---------------- Rotte fuori dalla shell (schermo intero) ----------
      GoRoute(
        path: '/non-trovato',
        parentNavigatorKey: radiceNavigatorKey,
        builder: (contesto, stato) => NonTrovatoPage(
          messaggio: stato.uri.queryParameters['msg'],
          percorso: stato.uri.queryParameters['da'],
        ),
      ),
    ],
  );
}
