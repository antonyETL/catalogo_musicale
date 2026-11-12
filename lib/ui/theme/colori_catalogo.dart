import 'package:flutter/material.dart';

@immutable
class ColoriCatalogo extends ThemeExtension<ColoriCatalogo> {
  const ColoriCatalogo({
    required this.paletteTracce,
    required this.sfondoBarra,
    required this.sfondoGenere,
    required this.testoGenere,
  });

  final List<Color> paletteTracce; // un colore per segmento della barra
  final Color sfondoBarra;
  final Color sfondoGenere;
  final Color testoGenere;

  /// Come si crea una variante: obbligatorio per una ThemeExtension.
  @override
  ColoriCatalogo copyWith({
    List<Color>? paletteTracce,
    Color? sfondoBarra,
    Color? sfondoGenere,
    Color? testoGenere,
  }) => ColoriCatalogo(
    paletteTracce: paletteTracce ?? this.paletteTracce,
    sfondoBarra: sfondoBarra ?? this.sfondoBarra,
    sfondoGenere: sfondoGenere ?? this.sfondoGenere,
    testoGenere: testoGenere ?? this.testoGenere,
  );

  /// `lerp` = interpolazione lineare: Flutter lo usa per ANIMARE il passaggio
  /// da tema chiaro a tema scuro. Senza, i colori cambierebbero di scatto.
  @override
  ColoriCatalogo lerp(ThemeExtension<ColoriCatalogo>? altro, double t) {
    if (altro is! ColoriCatalogo) return this;
    return ColoriCatalogo(
      paletteTracce: [
        for (var i = 0; i < paletteTracce.length; i++)
          Color.lerp(paletteTracce[i], altro.paletteTracce[i], t) ??
              paletteTracce[i],
      ],
      sfondoBarra: Color.lerp(sfondoBarra, altro.sfondoBarra, t) ?? sfondoBarra,
      sfondoGenere:
          Color.lerp(sfondoGenere, altro.sfondoGenere, t) ?? sfondoGenere,
      testoGenere: Color.lerp(testoGenere, altro.testoGenere, t) ?? testoGenere,
    );
  }

  // Palette pensata per avere contrasto sia su fondo chiaro sia su fondo scuro.
  static const chiaro = ColoriCatalogo(
    paletteTracce: [
      Color(0xFF1A237E),
      Color(0xFF00695C),
      Color(0xFFAD1457),
      Color(0xFF4527A0),
      Color(0xFFEF6C00),
    ],
    sfondoBarra: Color(0xFFE0E0E0),
    sfondoGenere: Color(0xFFE8EAF6),
    testoGenere: Color(0xFF1A237E),
  );

  static const scuro = ColoriCatalogo(
    paletteTracce: [
      Color(0xFF9FA8DA),
      Color(0xFF80CBC4),
      Color(0xFFF48FB1),
      Color(0xFFB39DDB),
      Color(0xFFFFCC80),
    ],
    sfondoBarra: Color(0xFF424242),
    sfondoGenere: Color(0xFF283593),
    testoGenere: Color(0xFFE8EAF6),
  );
}

/// Accesso senza `!`: se l'estensione mancasse, torniamo alla palette chiara.
ColoriCatalogo coloriDi(BuildContext context) =>
    Theme.of(context).extension<ColoriCatalogo>() ?? ColoriCatalogo.chiaro;
