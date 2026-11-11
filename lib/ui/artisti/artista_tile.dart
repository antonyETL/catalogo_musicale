import 'package:flutter/material.dart';

import '../../models/artista.dart';

/// Widget SENZA stato: riceve tutto dal padre.
/// Regola d'oro: se un widget può essere StatelessWidget, deve esserlo.
class ArtistaTile extends StatelessWidget {
  const ArtistaTile({
    super.key,
    required this.artista,
    this.onTap,
    this.onModifica,
    this.onElimina,
  });

  final Artista artista;
  final VoidCallback? onTap;
  final VoidCallback? onModifica;
  final VoidCallback? onElimina;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return ListTile(
      onTap: onTap,
      // CircleAvatar con l'iniziale: niente immagini di rete in questa fase.
      leading: CircleAvatar(
        backgroundColor: tema.colorScheme.primaryContainer,
        child: Text(
          artista.nome.isEmpty ? '?' : artista.nome[0].toUpperCase(),
          style: TextStyle(color: tema.colorScheme.onPrimaryContainer),
        ),
      ),
      title: Text(artista.nome, maxLines: 1, overflow: TextOverflow.ellipsis),
      // maxLines + ellipsis: prima difesa contro gli overflow quando il testo
      // è lungo o l'utente ingrandisce i caratteri.
      subtitle: Text(
        '${artista.nazione} · ${artista.annoInizio} · ${artista.gruppo.etichetta}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: PopupMenuButton<String>(
        tooltip: 'Azioni su ${artista.nome}',
        // L'area di tocco del pulsante è già >= 48dp (requisito di accessibilità).
        onSelected: (valore) {
          if (valore == 'modifica') onModifica?.call();
          if (valore == 'elimina') onElimina?.call();
        },
        itemBuilder: (contesto) => const [
          PopupMenuItem(value: 'modifica', child: Text('Modifica')),
          PopupMenuItem(value: 'elimina', child: Text('Elimina')),
        ],
      ),
    );
  }
}
