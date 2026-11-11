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
    return ListTile(
      onTap: onTap,
      leading: const Icon(Icons.album),
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
    );
  }
}
