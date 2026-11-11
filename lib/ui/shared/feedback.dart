import 'package:flutter/material.dart';

/// SnackBar coerente in tutta l'app, con azione opzionale (es. "Annulla").
/// ScaffoldMessenger è il "postino" dei messaggi: vive sopra le pagine,
/// quindi il messaggio resta visibile anche se cambiamo schermata.
void mostraSnackBar(
  BuildContext context,
  String messaggio, {
  String? azioneLabel,
  VoidCallback? onAzione,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar() // non accodiamo dieci messaggi uguali
    ..showSnackBar(
      SnackBar(
        content: Text(messaggio),
        duration: Duration(seconds: onAzione == null ? 3 : 5),
        action: (azioneLabel != null && onAzione != null)
            ? SnackBarAction(label: azioneLabel, onPressed: onAzione)
            : null,
      ),
    );
}
