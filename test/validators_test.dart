import 'package:catalogo_musicale_http/validation/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // group raggruppa test affini: l'output è più leggibile.
  group('validaAnnoInizio', () {
    test('accetta un anno dentro l’intervallo', () {
      expect(validaAnnoInizio('1970'), isNull); // null = valido
    });

    test('rifiuta un anno prima del 1900', () {
      expect(validaAnnoInizio('1899'), isNotNull);
    });

    test('rifiuta un testo non numerico', () {
      expect(validaAnnoInizio('mille'), contains('numero intero'));
    });

    test('rifiuta il campo vuoto', () {
      expect(validaAnnoInizio(''), isNotNull);
    });
  });

  group('altri validator del DTO', () {
    test('nome obbligatorio e max 200 caratteri', () {
      expect(validaNome('   '), isNotNull);
      expect(validaNome('A' * 201), isNotNull);
      expect(validaNome('Queen'), isNull);
    });

    test('gruppo: solo S o N', () {
      expect(validaGruppo('S'), isNull);
      expect(validaGruppo('N'), isNull);
      expect(validaGruppo('X'), isNotNull);
    });

    test('numeroTraccia tra 1 e 999', () {
      expect(validaNumeroTraccia('0'), isNotNull);
      expect(validaNumeroTraccia('1000'), isNotNull);
      expect(validaNumeroTraccia('12'), isNull);
    });

    test('durataSecondi tra 1 e 999999', () {
      expect(validaDurataSecondi('0'), isNotNull);
      expect(validaDurataSecondi('1000000'), isNotNull);
      expect(validaDurataSecondi('354'), isNull);
    });
  });
}
