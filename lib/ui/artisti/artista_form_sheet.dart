import 'package:catalogo_musicale_http/core/exceptions.dart';
import 'package:flutter/material.dart';

import '../../data/repo.dart';
import '../../models/artista.dart';
import '../../models/gruppo.dart';
import '../../validation/validators.dart';
import '../shared/feedback.dart';

/// Foglio modale di inserimento/modifica.
/// Se `artista` è null -> creazione; altrimenti -> modifica (campi precompilati).
class ArtistaFormSheet extends StatefulWidget {
  const ArtistaFormSheet({super.key, this.artista});

  final Artista? artista;

  @override
  State<ArtistaFormSheet> createState() => _ArtistaFormSheetState();
}

class _ArtistaFormSheetState extends State<ArtistaFormSheet> {
  /// `GlobalKey<FormState>`: la "chiave" che ci dà accesso allo stato del Form
  /// (validate(), save(), reset()) da qualunque punto di questo widget.
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nomeCtrl;
  late final TextEditingController _nazioneCtrl;
  late final TextEditingController _annoCtrl;
  late Gruppo _gruppo;
  bool _salvataggio = false;

  bool get _inModifica => widget.artista != null;

  /// Nuovo stato
  /// Errori arrivati dal SERVER (400): campo -> messaggio.
  /// Si sommano ai validator locali, ma hanno la precedenza perché il server
  /// è l'autorità finale.
  Map<String, String> _erroriServer = {};

  @override
  void initState() {
    super.initState();
    // `late final` + initState: creo i controller una volta, con il testo
    // iniziale dell'eventuale artista da modificare.
    _nomeCtrl = TextEditingController(text: widget.artista?.nome ?? '');
    _nazioneCtrl = TextEditingController(text: widget.artista?.nazione ?? '');
    _annoCtrl = TextEditingController(
      text: widget.artista?.annoInizio.toString() ?? '',
    );
    _gruppo = widget.artista?.gruppo ?? Gruppo.no;
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _nazioneCtrl.dispose();
    _annoCtrl.dispose();
    super.dispose();
  }

  Future<void> _salva() async {
    // validate() esegue TUTTI i validator e mostra i messaggi: false se uno fallisce.
    // `!` giustificato: la key è certamente collegata al Form nel build.
    if (!_formKey.currentState!.validate()) return;

    final artista = Artista(
      id: widget
          .artista
          ?.id, // null in creazione: l'id lo assegna il repository
      nome: _nomeCtrl.text.trim(),
      nazione: _nazioneCtrl.text.trim(),
      annoInizio: int.parse(_annoCtrl.text.trim()), // sicuro: validator passato
      gruppo: _gruppo,
    );

    setState(() => _salvataggio = true);
    try {
      if (_inModifica) {
        await Repo.artisti.aggiorna(artista);
      } else {
        await Repo.artisti.crea(artista);
      }
      if (!mounted) return;
      Navigator.pop(context, true); // chiudo il foglio e comunico il successo
    } on ValidationException catch (e) {
      if (!mounted) return;
      setState(() {
        _salvataggio = false;
        _erroriServer = e.erroriPerCampo;
      });
      mostraSnackBar(context, e.messaggioGenerale);
    } catch (e) {
      if (!mounted) return;
      setState(() => _salvataggio = false);
      mostraSnackBar(context, 'Salvataggio non riuscito: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // viewInsets.bottom = altezza della tastiera: senza questo padding
    // i campi finirebbero sotto la tastiera.
    final tastiera = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + tastiera),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _inModifica ? 'Modifica artista' : 'Nuovo artista',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nome *',
                  helperText: 'Massimo 200 caratteri',
                ),
                textInputAction: TextInputAction.next,
                validator: validaNome, // <-- funzione del Giorno 1, riusata
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nazioneCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nazione *',
                  helperText: 'Massimo 100 caratteri',
                ),
                textInputAction: TextInputAction.next,
                validator: validaNazione,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _annoCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Anno di inizio *',
                  helperText: 'Dal 1900 al 9999',
                  // Se il server ha contestato questo campo, mostriamo il SUO messaggio.
                  errorText: _erroriServer['annoInizio'],
                ),
                validator: validaAnnoInizio,
                onChanged: (_) {
                  // Appena l'utente corregge, l'errore del server non è più attuale.
                  if (_erroriServer.containsKey('annoInizio')) {
                    setState(() => _erroriServer.remove('annoInizio'));
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Gruppo>(
                // Nelle versioni recenti il parametro si chiama initialValue
                // (prima era `value`).
                initialValue: _gruppo,
                decoration: const InputDecoration(labelText: 'Tipo *'),
                items: Gruppo.values
                    .map(
                      (g) => DropdownMenuItem(
                        value: g,
                        child: Text('${g.etichetta} (${g.codice})'),
                      ),
                    )
                    .toList(),
                onChanged: (valore) =>
                    setState(() => _gruppo = valore ?? Gruppo.no),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _salvataggio
                          ? null
                          : () => Navigator.pop(context, false),
                      child: const Text('Annulla'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _salvataggio ? null : _salva,
                      child: _salvataggio
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_inModifica ? 'Salva' : 'Aggiungi'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
