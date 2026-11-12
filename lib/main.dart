import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'data/repo.dart';
import 'ui/router.dart';
import 'ui/theme/app_theme.dart';
import 'ui/theme/tema_controller.dart';

void main() {
  // Mattina: artisti dal server, album e tracce ancora in memoria.
  Repo.init(
    fonteArtisti: FonteDati.rete,
    fonteAlbum: FonteDati.memoria,
    fonteTracce: FonteDati.memoria,
  );
  runApp(CatalogoApp(router: creaRouter()));
}

class CatalogoApp extends StatelessWidget {
  const CatalogoApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: modalitaTema,
      builder: (_, modo, __) => MaterialApp.router(
        title: 'Catalogo Musicale',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.chiaro(),
        darkTheme: AppTheme.scuro(),
        themeMode: modo,
        routerConfig: router, // <-- al posto di `home:`
      ),
    );
  }
}
