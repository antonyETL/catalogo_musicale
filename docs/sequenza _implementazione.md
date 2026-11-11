# Ordine sequenziale dei file implementati

## 1. File lib/core/exceptions.dart
Vengono definite le eccezioni che useremo anche con HTTP. Così l'interfaccia dei repository non cambia quando passeremo dai dati in memoria al server: cambiano solo le classi che la implementano.

## 2. File lib/utils/formattazioni.dart
Contengono funzioni di supporto per formattare dati e valori in modo coerente nell'app.

## 3. File lib/models/gruppo.dart
Definisce il modello dei gruppi musicali usato dall'applicazione.

## 4. File lib/models/artista.dart
Definisce il modello degli artisti e i dati relativi a ciascuno di essi.

## 5. File lib/models/album.dart
Definisce il modello degli album e le informazioni principali associati.

## 6. File lib/models/traccia.dart
Definisce il modello delle tracce audio presenti negli album.

## 7. File lib/validation/validators.dart
Contiene i validatori usati per controllare i dati in input e le regole di business.

## 8. File lib/data/repositories.dart
Definisce l'interfaccia dei repository per accedere ai dati in modo uniforme.

## 9. File lib/data/in_memory_repository.dart
Implementa una versione del repository che usa dati in memoria per lo sviluppo e i test.

## 10. File lib/data/in_memory_repositories.dart
Raggruppa e espone i repository in memoria necessari all'applicazione.

## 11. File test/validators_test.dart
Contiene i test che verificano il corretto funzionamento dei validatori.

## 12. File test/models_test.dart
Contiene i test che verificano il corretto comportamento dei modelli del dominio.

## 13. File lib/data/repo.dart
Inizializza e rende disponibili i repository usati dall'app.

## 14. File lib/ui/shared/empty_view.dart
Mostra un messaggio e un'eventuale azione quando non ci sono dati da visualizzare.

## 15. File lib/ui/shared/error_view.dart
Mostra un messaggio di errore e permette di riprovare, se previsto.

## 16. File lib/ui/shared/dialoghi.dart
Contiene il dialogo riutilizzabile per chiedere conferma all'utente.

## 17. File lib/ui/shared/feedback.dart
Mostra messaggi temporanei di feedback, con un'eventuale azione.

## 18. File lib/ui/artisti/artista_tile.dart
Visualizza i dati di un artista e le relative azioni.

## 19. File lib/ui/artisti/artista_form_sheet.dart
Gestisce l'inserimento e la modifica dei dati di un artista.

## 20. File lib/ui/artisti/artisti_page.dart
Mostra e filtra gli artisti e consente di aggiungerli, modificarli o eliminarli.

## 21. File lib/ui/album/album_card.dart
Visualizza le informazioni di un album e le relative azioni.

## 22. File lib/ui/album/album_form_sheet.dart
Gestisce l'inserimento e la modifica dei dati di un album.

## 23. File lib/ui/album/album_page.dart
Mostra e filtra gli album e consente di aggiungerli, modificarli o eliminarli.

## 24. File lib/ui/home/home_page.dart
Lo stato condiviso (liste di artisti e album) sta qui, nel primo antenato comune delle due pagine. Le pagine figlie ricevono i dati e una callback per chiedere il ricaricamento. Così, quando elimino un artista, la lista album mostra subito il nome aggiornato: una sola fonte di verità.

## 12. File lib/main.dart
Configura e avvia l'applicazione Flutter.