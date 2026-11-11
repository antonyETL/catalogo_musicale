/// Funzioni di formattazione manuali: nessuna dipendenza esterna.
/// Esistono alternative professionali come package:intl con
/// DateFormat/NumberFormat, ma richiede l'inizializzazione del locale 'it'.
///
/// 7 -> '07'
String dueCifre(int n) => n.toString().padLeft(2, '0');

/// Secondi -> 'mm:ss'. I minuti possono superare 59 (un album intero può
/// durare 74 minuti): non usiamo l'ora per restare fedeli alla consegna.
String mmSs(int secondi) {
  final minuti = secondi ~/ 60; // ~/ = divisione intera
  final resto = secondi % 60;
  return '${dueCifre(minuti)}:${dueCifre(resto)}';
}

/// DateTime -> '21/11/1975' (formato per l'interfaccia, italiano)
String ggMmAaaa(DateTime d) =>
    '${dueCifre(d.day)}/${dueCifre(d.month)}/${d.year}';

/// DateTime -> '1975-11-21' (formato ISO per il backend: LocalDate)
String aaaaMmGg(DateTime d) =>
    '${d.year}-${dueCifre(d.month)}-${dueCifre(d.day)}';

/// Versione "parlata", utile per le etichette di accessibilità (Giorno 3):
/// uno screen reader legge meglio "3 minuti e 45 secondi" che "03:45".
String durataLeggibile(int secondi) {
  final m = secondi ~/ 60;
  final s = secondi % 60;
  if (m == 0) return '$s secondi';
  if (s == 0) return '$m minuti';
  return '$m minuti e $s secondi';
}
