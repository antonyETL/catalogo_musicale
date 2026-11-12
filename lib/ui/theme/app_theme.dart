import 'package:flutter/material.dart';

import 'colori_catalogo.dart';

/// Un solo posto dove si decide l'aspetto dell'app.
/// Regola: nei widget NON si scrivono colori fissi (`Colors.red`), si legge
/// `Theme.of(context).colorScheme...`: così il tema scuro funziona gratis.
class AppTheme {
  AppTheme._();

  static const Color seme = Color(
    0xFF3F51B5,
  ); // indigo: da qui nasce la palette

  static ThemeData chiaro() => _base(
    ColorScheme.fromSeed(seedColor: seme, brightness: Brightness.light),
  );

  static ThemeData scuro() =>
      _base(ColorScheme.fromSeed(seedColor: seme, brightness: Brightness.dark));

  static ThemeData _base(ColorScheme schema) {
    final temaBase = ThemeData(colorScheme: schema);

    return temaBase.copyWith(
      // --- Testo: gerarchia chiara (titoli grandi, didascalie piccole) ---
      textTheme: temaBase.textTheme.copyWith(
        titleLarge: temaBase.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        titleMedium: temaBase.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),

      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: schema.surface,
        foregroundColor: schema.onSurface,
        elevation: 0,
        scrolledUnderElevation: 2,
      ),

      // ATTENZIONE SDK: oggi si usa CardThemeData (prima CardTheme).
      cardTheme: CardThemeData(
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        color: schema.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: schema.outlineVariant),
        ),
      ),

      // errorMaxLines: i messaggi di errore lunghi non vengono tagliati.
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        errorMaxLines: 3,
        helperMaxLines: 3,
      ),

      // Bersaglio minimo 48dp: requisito di accessibilità, non un dettaglio.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: const Size(64, 48)),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(minimumSize: const Size(64, 48)),
      ),

      navigationBarTheme: const NavigationBarThemeData(
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
      ),

      chipTheme: const ChipThemeData(showCheckmark: true),

      // --- La nostra estensione, coerente con la luminosità ---
      extensions: <ThemeExtension<dynamic>>[
        schema.brightness == Brightness.light
            ? ColoriCatalogo.chiaro
            : ColoriCatalogo.scuro,
      ],
    );
  }
}
