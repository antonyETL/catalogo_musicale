/// Le Response del backend estendono RepresentationModel (Spring HATEOAS).
/// La lista può arrivare in tre forme diverse, a seconda della configurazione:
///
/// 1) array semplice:      [ {...}, {...} ]
/// 2) HAL:                 {"_embedded": {"artisti": [...]}, "_links": {...}}
/// 3) pagina Spring Data:  {"content": [...], "totalElements": 8, ...}
///
/// Questa funzione le normalizza tutte in una List. VA ALLINEATA col backend
/// prima della sessione: è il punto che fa perdere più tempo in aula.
List<dynamic> estraiLista(dynamic dati, String nomeCollezione) {
  if (dati is List) return dati;

  if (dati is Map<String, dynamic>) {
    final embedded = dati['_embedded'];
    if (embedded is Map<String, dynamic>) {
      // cerchiamo la chiave attesa ('artisti', 'album', 'tracce')
      final cercata = embedded[nomeCollezione];
      if (cercata is List) return cercata;
      // in alternativa prendiamo la prima lista disponibile
      for (final valore in embedded.values) {
        if (valore is List) return valore;
      }
    }
    final content = dati['content'];
    if (content is List) return content;
  }

  throw const FormatException('Formato della lista non riconosciuto');
}

/// Legge l'URL di sé stessi invece di concatenarlo.
/// Restituisce null se i link non ci sono.
String? linkSelf(dynamic dati) {
  if (dati is Map<String, dynamic>) {
    final links = dati['_links'];
    if (links is Map<String, dynamic>) {
      final self = links['self'];
      if (self is Map<String, dynamic>) return self['href'] as String?;
    }
  }
  return null;
}
