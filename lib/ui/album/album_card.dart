import 'package:flutter/material.dart';

import '../../models/album.dart';
import '../../utils/formattazioni.dart';

class AlbumCard extends StatelessWidget {
  const AlbumCard({
    super.key,
    required this.album,
    required this.nomeArtista,
    this.onTap,
    this.onModifica,
    this.onElimina,
  });

  final Album album;
  final String nomeArtista; // già risolto dal padre tramite idArtista
  final VoidCallback? onTap;
  final VoidCallback? onModifica;
  final VoidCallback? onElimina;

  @override
  Widget build(BuildContext context) {
    // l'intera card avvolta in Semantics
    return Semantics(
      button: true,
      label:
          '${album.titolo} di $nomeArtista, uscito il ${ggMmAaaa(album.dataUscita)}, '
          '${album.genere.isEmpty ? "genere non indicato" : album.genere}',
      child: ListTile(
        onTap: onTap,
        // leading della ListTile/Card
        leading: Hero(
          tag: 'copertina-album-${album.id}',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 48,
              height: 48,
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.album,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
        title: Text(album.titolo, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          // Data in formato italiano.
          '$nomeArtista · ${ggMmAaaa(album.dataUscita)}'
          '${album.genere.isEmpty ? '' : ' · ${album.genere}'}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton<String>(
          tooltip: 'Azioni su ${album.titolo}',
          onSelected: (v) {
            if (v == 'modifica') onModifica?.call();
            if (v == 'elimina') onElimina?.call();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'modifica', child: Text('Modifica')),
            PopupMenuItem(value: 'elimina', child: Text('Elimina')),
          ],
        ),
      ),
    );
  }
}
