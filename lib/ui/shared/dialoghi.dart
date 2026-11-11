import 'package:flutter/material.dart';

/// Dialogo di conferma riusabile.
/// Restituisce true se l'utente conferma, false in ogni altro caso.
Future<bool> chiediConferma(
  BuildContext context, {
  required String titolo,
  required String messaggio,
  String etichettaAzione = 'Conferma',
  bool distruttiva = false,
}) async {
  final risposta = await showDialog<bool>(
    context: context,
    builder: (contestoDialogo) => AlertDialog(
      title: Text(titolo),
      content: Text(messaggio),
      actions: [
        // L'azione sicura è quella "neutra": niente colore che attiri il tap.
        TextButton(
          onPressed: () => Navigator.pop(contestoDialogo, false),
          child: const Text('Annulla'),
        ),
        FilledButton(
          style: distruttiva
              ? FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                )
              : null,
          onPressed: () => Navigator.pop(contestoDialogo, true),
          child: Text(etichettaAzione),
        ),
      ],
    ),
  );
  return risposta ?? false;
}
