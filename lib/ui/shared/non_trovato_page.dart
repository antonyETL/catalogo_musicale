import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Pagina unica per tutti i "non trovato": id non numerico, id inesistente,
/// URL digitato male. Ha sempre una via d'uscita.
class NonTrovatoPage extends StatelessWidget {
  const NonTrovatoPage({super.key, this.percorso, this.messaggio});

  final String? percorso;
  final String? messaggio;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Non trovato')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 72),
              const SizedBox(height: 16),
              Text(
                messaggio ?? 'La pagina richiesta non esiste.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (percorso != null) ...[
                const SizedBox(height: 8),
                Text(percorso!, style: Theme.of(context).textTheme.bodySmall),
              ],
              const SizedBox(height: 24),
              FilledButton.icon(
                // go() sostituisce la posizione corrente: non lasciamo
                // l'utente su una pagina morta nella cronologia.
                onPressed: () => context.go('/artisti'),
                icon: const Icon(Icons.home),
                label: const Text('Torna agli artisti'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
