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