import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../models/traccia.dart';
import '../../utils/formattazioni.dart';
import '../theme/colori_catalogo.dart';

/// Widget che incapsula il disegno: i dati entrano, la Semantics esce.
/// Il painter NON deve sapere nulla del contesto/tema: riceve colori e numeri.
class DurataBar extends StatelessWidget {
  const DurataBar({super.key, required this.tracce, this.altezza = 24});

  final List<Traccia> tracce; // già ordinate per numeroTraccia
  final double altezza;

  @override
  Widget build(BuildContext context) {
    final colori = coloriDi(context);
    final totale = tracce.fold<int>(0, (somma, t) => somma + t.durataSecondi);

    if (tracce.isEmpty || totale == 0) {
      // Stato vuoto del grafico: una barra grigia con messaggio, non un crash.
      return Semantics(
        label: 'Nessuna durata disponibile: l’album non ha tracce',
        child: Container(
          height: altezza,
          decoration: BoxDecoration(
            color: colori.sfondoBarra,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      );
    }

    // Semantics: uno screen reader non può "vedere" il Canvas.
    // Gli diamo noi il significato dell'intero grafico.
    return Semantics(
      label:
          'Durata complessiva ${durataLeggibile(totale)}, '
          '${tracce.length} tracce. '
          'Ogni segmento è proporzionale alla durata della traccia.',
      child: CustomPaint(
        size: Size(double.infinity, altezza),
        painter: DurataBarPainter(
          durate: tracce.map((t) => t.durataSecondi).toList(),
          colori: colori.paletteTracce,
          sfondo: colori.sfondoBarra,
        ),
      ),
    );
  }
}

/// Disegna una barra segmentata: ogni segmento è largo in proporzione
/// alla durata della traccia corrispondente.
class DurataBarPainter extends CustomPainter {
  DurataBarPainter({
    required this.durate,
    required this.colori,
    required this.sfondo,
  });

  final List<int> durate;
  final List<Color> colori;
  final Color sfondo;

  @override
  void paint(Canvas canvas, Size size) {
    final totale = durate.fold<int>(0, (a, b) => a + b);

    // Difesa fondamentale: senza questo, con totale 0 otterremmo 0/0 = NaN
    // e Flutter lancerebbe un errore in fase di disegno.
    if (totale <= 0 || size.width <= 0) return;

    // Fondo con angoli arrotondati.
    final rrectFondo = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(6),
    );
    canvas.drawRRect(rrectFondo, Paint()..color = sfondo);

    // ClipRRect "manuale": tutto ciò che disegniamo resta dentro gli angoli.
    canvas.save();
    canvas.clipRRect(rrectFondo);

    const spazio = 2.0; // separazione visiva tra le tracce
    var x = 0.0;
    for (var i = 0; i < durate.length; i++) {
      final larghezza = size.width * durate[i] / totale;
      canvas.drawRect(
        // max(0, ...): un segmento minuscolo non deve avere larghezza negativa.
        Rect.fromLTWH(
          x,
          0,
          (larghezza - spazio).clamp(0.0, size.width),
          size.height,
        ),
        Paint()..color = colori[i % colori.length],
      );
      x += larghezza;
    }
    canvas.restore();
  }

  /// shouldRepaint decide se ridisegnare.
  /// ATTENZIONE: `old.durate != durate` confronta i RIFERIMENTI delle liste,
  /// non i contenuti: due liste diverse con gli stessi numeri risulterebbero
  /// "diverse" (ridisegno inutile) o, peggio, uguali quando non dovrebbero.
  /// listEquals confronta elemento per elemento: è la scelta corretta.
  @override
  bool shouldRepaint(DurataBarPainter old) =>
      !listEquals(old.durate, durate) ||
      !listEquals(old.colori, colori) ||
      old.sfondo != sfondo;
}
