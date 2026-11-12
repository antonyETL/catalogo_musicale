import 'package:flutter/material.dart';

import 'data/repo.dart';
import 'ui/home/home_page.dart';
import 'ui/theme/app_theme.dart';
import 'ui/theme/tema_controller.dart';

void main() {
  Repo.init();
  runApp(const CatalogoApp());
}

class CatalogoApp extends StatelessWidget {
  const CatalogoApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder ricostruisce SOLO MaterialApp quando cambia il tema.
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: modalitaTema,
      builder: (contesto, modo, _) => MaterialApp(
        title: 'Catalogo Musicale',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.chiaro(),
        darkTheme: AppTheme.scuro(),
        themeMode: modo,
        home: const HomePage(),
      ),
    );
  }
}
