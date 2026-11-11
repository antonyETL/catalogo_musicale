import 'package:flutter/material.dart';

import 'data/repo.dart';
import 'ui/home/home_page.dart';

/// Punto di ingresso: 1) preparo le dipendenze, 2) avvio l'interfaccia.
void main() {
  Repo.init();
  runApp(const CatalogoApp());
}

/// CatalogoApp è SENZA stato: la sua unica responsabilità è configurare
/// MaterialApp (tema, titolo, prima schermata).
class CatalogoApp extends StatelessWidget {
  const CatalogoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catalogo Musicale',
      debugShowCheckedModeBanner: false,
      // Material 3 è il default nelle versioni recenti di Flutter.
      // ColorScheme.fromSeed genera una palette coerente da un solo colore.
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const HomePage(),
    );
  }
}
